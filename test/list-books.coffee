noteStore = require('../lib/noteStore')

noteStore.listNotebooks (err, info) ->
  return console.log err if err

  for k in info
    console.log k.guid  + " => " + k.name