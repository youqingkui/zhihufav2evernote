email = require('./email')()


txErr = (href, type, infoJson, cb) ->
  console.log infoJson.err

  log = {}
  log.href = href
  log.type = type
  log.info = JSON.stringify(infoJson)

  log.save (err, row) ->
    return console.log err if err

  emailBody = JSON.stringify(log)
  email.send(emailBody)

  if cb
    return cb(infoJson.err)



module.exports = txErr


