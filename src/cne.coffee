# Description:
#   Te dice en donde venden la gasolina mas barata.
#
# Dependencies:
#   cne
#
# Commands:
#   @pudu cne help
#   @pudu cne obtener <tipo-de-combustible> <comuna>
#   @pudu cne listar combustibles
#   @pudu cne listar comunas
#
# Author:
#   @lgaticaq

cne = require "cne"

module.exports = (robot) ->
  help = (msg) ->
    msg.send "`pudu cne obtener <combustible> en <comuna>`"
    msg.send "`pudu cne listar combustibles`"
    msg.send "`pudu cne listar comunas`"

  getFuelTypes = (msg) ->
    msg.send "```#{cne.fuelTypes.join(", ")}```"

  getCommunes = (msg) ->
    msg.send "```#{cne.communes.join(", ")}```"

  robot.respond /cne help/i, help
  robot.respond /cne listar combustibles/i, getFuelTypes
  robot.respond /cne listar comunas/i, getCommunes

  robot.respond /cne obtener (\w+) en ([\w\sñáéíóúñÁÉÍÓÚÑ]+)/i, (msg) ->
    fuelType = msg.match[1].trim()
    if fuelType not in cne.fuelTypes
      msg.send "En el servicentro no tenemos #{fuelType} ni tampoco criptonita"
      msg.send "Estos son los tipos de combustibles:"
      msg.send "```#{fuelTypes.join(", ")}```"
    else
      options =
        fuelType: fuelType
      options.commune = msg.match[2].trim()
      cne.get(options)
        .then (data) ->
          price = data.precio_por_combustible[fuelType]
          street = data.direccion_calle
          number = data.direccion_numero
          commune = data.nombre_comuna
          dist = data.nombre_distribuidor
          addr = "#{street} #{number} #{commune}"
          msg.send "En #{dist} de #{addr} la venden a $#{price} CLP el litro"
        .fail (err) ->
          msg.send "No hay servicentro en #{options.commune}"
