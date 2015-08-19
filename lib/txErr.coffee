email = require('./email')()


txErr = (infoJson, cb) ->
  console.log infoJson.err

  logInfo = ""
  for k, v of infoJson
    logInfo +=  k + ": " + v + "\n"

  emailBody = (logInfo)
  email.send(emailBody)

  if cb
    return cb(infoJson.err)


module.exports = txErr


