// Description:
//   Obtiene la estación de servicio con el precio mas barato de un combustible
//
// Dependencies:
//   "cne": "^1.0.1"
//
// Commands:
//   hubot cne obtener <combustible> - Obtiene la estación de servicio con el precio mas barato
//   hubot cne obtener <combustible> en <comuna> - Obtiene la estación de servicio con el precio mas barato en una determinada comuna
//   hubot cne listar combustibles - Obtiene el listado de combustibles disponibles
//   hubot cne listar comunas - Obtiene el listado de comunas disponibles
//
// Author:
//   lgaticaq

const cne = require('cne')

module.exports = robot => {
  const getFuelTypes = res =>
    res.send(`\`\`\`${cne.fuelTypes.join(', ')}\`\`\``)

  const getCommunes = res => res.send(`\`\`\`${cne.communes.join(', ')}\`\`\``)

  robot.respond(/cne listar combustibles/i, getFuelTypes)
  robot.respond(/cne listar comunas/i, getCommunes)

  robot.respond(/cne obtener (\w+)( en ([\w\sñáéíóúñÁÉÍÓÚÑ]+))?/i, res => {
    const fuelType = res.match[1].trim()
    const commune = res.match[3] ? res.match[3].trim() : ''
    const communes = Array.from(cne.communes).map(x => x.toLowerCase())

    if (!cne.fuelTypes.includes(fuelType)) {
      res.send(`El combustible *${fuelType}* no esta disponible`)
      res.send('Estos son los combustibles disponibles:')
      return res.send(`\`\`\`${cne.fuelTypes.join(', ')}\`\`\``)
    } else if (!communes.includes(commune.toLowerCase()) && commune !== '') {
      res.send(`La comuna *${commune}* no esta disponible`)
      res.send('Estos son las comunas disponibles:')
      return res.send(`\`\`\`${cne.communes.join(', ')}\`\`\``)
    } else {
      const options = { fuelType }
      if (commune !== '') options.commune = commune
      return cne
        .get(options)
        .then(data => {
          const price = data.precio_por_combustible[fuelType]
          const street = data.direccion_calle
          const number = data.direccion_numero
          const dist = data.nombre_distribuidor
          const addr = `${street} ${number} ${data.nombre_comuna}`
          res.send(`En ${dist} de ${addr} la venden a $${price} CLP el litro`)
        })
        .catch(err => {
          res.reply('ocurrio un error al consultar el combustible')
          robot.emit('error', err)
        })
    }
  })
}
