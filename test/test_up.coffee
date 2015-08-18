PushEvernote = require('../lib/pushEvernote')
async = require('async')
Task = require('../models/task')
txErr = require('../lib/txErr')
noteStore = require('../lib/noteStore')
updateNote = require('../lib/updateNote')


updateNote noteStore, 'e17ef426-d9cd-445c-b133-4aa0d8a6ddea',"test-update", "update_body",{}, (err, note) ->

  console.log err, note


