Helper = require("hubot-test-helper")
expect = require("chai").expect
proxyquire = require("proxyquire")

cneStub =
  get: (options) ->
    return new Promise (resolve, reject) ->
      if options.fuelType is "gasolina_95"
        reject(new Error("Server error"))
      else
        resolve({
          id: " te912002",
          fecha: "2015-08-31 10:23:16",
          direccion_calle: "Calle",
          direccion_numero: "1",
          nombre_comuna: "Santiago",
          nombre_distribuidor: "SHELL",
          precio_por_combustible: {
            "gasolina_93": 799,
            "petroleo_diesel": 548,
            "gasolina_95": 842
          }
        })
  fuelTypes: ["gasolina_93", "gasolina_95", "petroleo_diesel"]
  communes: ["Santiago", "Concepción"]

proxyquire("./../src/script.coffee", {"cne": cneStub})

helper = new Helper("./../src/index.coffee")

describe "cne", ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context "ask for a valid commune", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener gasolina_93 en santiago")
      setTimeout(done, 500)

    it "should respond the address and price", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener gasolina_93 en santiago"]
        ["hubot", "En SHELL de Calle 1 Santiago la venden a $799 CLP el litro"]
      ])

  context "ask for a invalid commune", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener gasolina_93 en chuchunco sur")
      setTimeout(done, 500)

    it "should respond a instructions for valid commune", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener gasolina_93 en chuchunco sur"]
        ["hubot", "La comuna *chuchunco sur* no esta disponible"]
        ["hubot", "Estos son las comunas disponibles:"]
        ["hubot", "```Santiago, Concepción```"]
      ])

  context "ask for a invalid fuel type", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener gasolina_69 en santiago")
      setTimeout(done, 500)

    it "should respond a instructions for valid fuel type", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener gasolina_69 en santiago"]
        ["hubot", "El combustible *gasolina_69* no esta disponible"]
        ["hubot", "Estos son los combustibles disponibles:"]
        ["hubot", "```gasolina_93, gasolina_95, petroleo_diesel```"]
      ])

  context "server error", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne obtener gasolina_95")
      setTimeout(done, 500)

    it "should respond a error", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne obtener gasolina_95"]
        ["hubot", "@alice ocurrio un error al consultar el combustible"]
      ])

  context "getFuelTypes", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne listar combustibles")
      setTimeout(done, 500)

    it "should respond a list of fuel types", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne listar combustibles"]
        ["hubot", "```gasolina_93, gasolina_95, petroleo_diesel```"]
      ])

  context "getCommunes", ->

    beforeEach (done) ->
      room.user.say("alice", "hubot cne listar comunas")
      setTimeout(done, 500)

    it "should respond a list of communes", ->
      expect(room.messages).to.eql([
        ["alice", "hubot cne listar comunas"]
        ["hubot", "```Santiago, Concepción```"]
      ])
