async = require('async')
Task = require('../models/task')
noteStore = require('../lib/noteStore')
UpdateEvernote = require('../lib/updateEvernote')


async.waterfall [
  (cb) ->
    Task.find {status:3}, null, {sort: {_id: -1}}, (err, rows) ->
      return txErr {err:err, fun:'TaskFind'}, callback if err

      cb(null, rows)


  (rows, cb) ->
    async.eachSeries rows, (item, callback) ->
      if item.guid
        u = new UpdateEvernote(item.url, noteStore, item.noteBook, item.guid, item)
        u.upNote callback

    ,() ->
      console.log "# all do #"

  ]






