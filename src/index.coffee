# Description:
#   Obtiene la estación de servicio con el precio mas barato de un combustible
#
# Dependencies:
#   "cne": "^0.3.2"
#
# Commands:
#   hubot cne obtener <combustible> - Obtiene la estación de servicio con el precio mas barato
#   hubot cne obtener <combustible> en <comuna> - Obtiene la estación de servicio con el precio mas barato en una determinada comuna
#   hubot cne listar combustibles - Obtiene el listado de combustibles disponibles
#   hubot cne listar comunas - Obtiene el listado de comunas disponibles
#
# Author:
#   lgaticaq

cne = require "cne"

module.exports = (robot) ->
  getFuelTypes = (res) ->
    res.send "```#{cne.fuelTypes.join(", ")}```"

  getCommunes = (res) ->
    res.send "```#{cne.communes.join(", ")}```"

  robot.respond /cne listar combustibles/i, getFuelTypes
  robot.respond /cne listar comunas/i, getCommunes

  robot.respond /cne obtener (\w+)( en ([\w\sñáéíóúñÁÉÍÓÚÑ]+))?/i, (res) ->
    fuelType = res.match[1].trim()
    commune = if res.match[3] then res.match[3].trim() else ""
    communes = (x.toLowerCase() for x in cne.communes)

    if fuelType not in cne.fuelTypes
      res.send "El combustible *#{fuelType}* no esta disponible"
      res.send "Estos son los combustibles disponibles:"
      res.send "```#{cne.fuelTypes.join(", ")}```"
    else if (commune.toLowerCase() not in communes) and (commune isnt "")
      res.send "La comuna *#{commune}* no esta disponible"
      res.send "Estos son las comunas disponibles:"
      res.send "```#{cne.communes.join(", ")}```"
    else
      options =
        fuelType: fuelType
      options.commune = commune if commune isnt ""
      cne.get(options)
        .then (data) ->
          price = data.precio_por_combustible[fuelType]
          street = data.direccion_calle
          number = data.direccion_numero
          commune = data.nombre_comuna
          dist = data.nombre_distribuidor
          addr = "#{street} #{number} #{commune}"
          res.send "En #{dist} de #{addr} la venden a $#{price} CLP el litro"
        .fail (err) ->
          res.reply "ocurrio un error al consultar el combustible"
          robot.emit "error", err
