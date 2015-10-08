Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")

helper = new Helper("./../src/cne.coffee")

describe "cne", ->
  room = null
  price = 799
  street = "ISABEL RIQUELME"
  number = "403"
  commune = "Santiago"
  dist = "SHELL"
  addr = "#{street} #{number} #{commune}"
  fuelType = "gasolina_93"
  valid = "santiago"
  invalid = "chuchunco norte"

  beforeEach ->
    room = helper.createRoom()
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
    do nock.disableNetConnect
    nock("http://api.cne.cl")
      .get("/api/listaInformacion/6M5jaVAzPS")
      .reply(200, data)

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context "ask for a valid commune", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener #{fuelType} en #{valid}")
      setTimeout(done, 100)

    it "should respond the address and price", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{fuelType} en #{valid}"]
        ["hubot", "En #{dist} de #{addr} la venden a $#{price} CLP el litro"]
      ])

  context "ask for a invalid commune", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener #{fuelType} en #{invalid}")
      setTimeout(done, 100)

    it "should respond a warning", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener #{fuelType} en #{invalid}"]
        ["hubot", "No hay servicentro en chuchunco norte"]
      ])
