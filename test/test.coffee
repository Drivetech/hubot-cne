Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")
cne = require("cne")

helper = new Helper("./../src/index.coffee")

describe "cne", ->
  room = null
  price = 799
  street = "ISABEL RIQUELME"
  number = "403"
  commune = "Santiago"
  dist = "SHELL"
  addr = "#{street} #{number} #{commune}"
  fuelType = "gasolina_93"
  invalidFuelType = "gasolina_69"
  valid = "santiago"
  invalid = "chuchunco norte"
  data = {
    estado: "OK",
    data: [
      {
        id: " te912002",
        fecha: "2015-08-31 10:23:16",
        direccion_calle: street,
        direccion_numero: number,
        nombre_comuna: commune,
        nombre_distribuidor: dist,
        precio_por_combustible: {
          "gasolina_93": price,
          "petroleo_diesel": 548,
          "gasolina_95": 842
        }
      }
    ]
  }

  beforeEach ->
    room = helper.createRoom()
    nock.disableNetConnect()

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context "ask for a valid commune", ->

    beforeEach (done) ->
      nock("http://api.cne.cl")
        .get("/api/listaInformacion/6M5jaVAzPS")
        .reply(200, data)
      room.user.say("alice", "hubot cne obtener #{fuelType} en #{valid}")
      setTimeout(done, 500)

    it "should respond the address and price", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{fuelType} en #{valid}"]
        ["hubot", "En #{dist} de #{addr} la venden a $#{price} CLP el litro"]
      ])

  context "ask for a invalid commune", ->

    beforeEach (done) ->
      nock("http://api.cne.cl")
        .get("/api/listaInformacion/6M5jaVAzPS")
        .reply(200, data)
      room.user.say("alice", "hubot cne obtener #{fuelType} en #{invalid}")
      setTimeout(done, 500)

    it "should respond a instructions for valid commune", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{fuelType} en #{invalid}"]
        ["hubot", "La comuna *#{invalid}* no esta disponible"]
        ["hubot", "Estos son las comunas disponibles:"]
        ["hubot", "```#{cne.communes.join(", ")}```"]
      ])

  context "ask for a invalid fuel type", ->

    beforeEach (done) ->
      nock("http://api.cne.cl")
        .get("/api/listaInformacion/6M5jaVAzPS")
        .reply(200, data)
      room.user.say("alice", "hubot cne obtener #{invalidFuelType} en #{valid}")
      setTimeout(done, 500)

    it "should respond a instructions for valid fuel type", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{invalidFuelType} en #{valid}"]
        ["hubot", "El combustible *#{invalidFuelType}* no esta disponible"]
        ["hubot", "Estos son los combustibles disponibles:"]
        ["hubot", "```#{cne.fuelTypes.join(", ")}```"]
      ])

  context "server error", ->

    beforeEach (done) ->
      nock("http://api.cne.cl")
        .get("/api/listaInformacion/6M5jaVAzPS")
        .replyWithError("something awful happened")
      room.user.say("alice", "hubot cne obtener #{fuelType} en #{valid}")
      setTimeout(done, 500)

    it "should respond a error", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{fuelType} en #{valid}"]
        ["hubot", "@alice ocurrio un error al consultar el combustible"]
      ])
