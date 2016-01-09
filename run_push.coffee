PushEvernote = require('./lib/pushEvernote')
async = require('async')
Task = require('./models/task')
txErr = require('./lib/txErr')
noteStore = require('./lib/noteStore')
UpdateEvernote = require('./lib/updateEvernote')
Check = require('./lib/check')
mongoose = require('./models/mongoose')


async.waterfall [
  (cb) ->
    Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
      return txErr {err:err, fun:'TaskFind'}, callback if err

      cb(null, rows)


  (rows, cb) ->
    ### 创建 ###
    async.eachSeries rows, (item, callback) ->
      p = new PushEvernote(item.url, noteStore, item.noteBook)
      p.pushNote callback

    ,() ->
      console.log "#  all do #"
      cb()


  (cb) ->
    ### 更新 ###
    async.waterfall [
      (cb) ->
        Task.find {status:3}, null, {sort: {_id: -1}}, (err, rows) ->
          return txErr {err:err, fun:'TaskFind'}, callback if err

          cb(null, rows)


      (rows) ->
        async.eachSeries rows, (item, callback) ->
          if item.guid
            u = new UpdateEvernote(item.url, noteStore, item.noteBook, item.guid, item)
            u.upNote callback

        ,() ->
          console.log "# all do up #"
          mongoose.connection.close()

    ]

]



