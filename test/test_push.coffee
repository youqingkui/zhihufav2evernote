PushEvernote = require('../lib/pushEvernote')
async = require('async')
Task = require('../models/task')
txErr = require('../lib/txErr')
noteStore = require('../lib/noteStore')

async.waterfall [
  (cb) ->
    Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
      return txErr {err:err, fun:'TaskFind'}, callback if err

      cb(null, rows)


  (rows, cb) ->
    async.eachSeries rows, (item, callback) ->
      p = new PushEvernote(item.url, noteStore, item.noteBook)
      p.pushNote callback

    ,() ->
      console.log "#  all do #"
]