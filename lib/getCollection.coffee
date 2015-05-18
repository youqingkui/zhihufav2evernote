requrest = require('request')
fs = require('fs')
path = require('path')
queue = require('./getAnswers')
async = require('async')
txErr = require('./txErr')
Task = require('../models/task')



class GetCol
  constructor:(@noteStore, @noteBook) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }



  getColList:(url) ->
    self = @
    op = {
      url:url
      headers:self.headers
      gzip:true
    }

    async.auto
      getList:(cb) ->
        requrest.get op, (err, res, body) ->
          return txErr op.url, 1, {err:err,fun:'getList'} if err

          data = JSON.parse(body)
          cb(null, data)

      checkList:['getList', (cb, result) ->
        data = result.getList
        if data.data.length
          async.eachSeries data.data, (item, callback) ->
            Task.findOne {url:item.url}, (err, row) ->
              return txErr url, 5, {err:err, answer:item.url, fun:'checkList'} if err

              if row
                console.log "already exits ==>", item.url
                callback()

              else
                self.addDB item.url, callback


          ,() ->
            self.getColList(data.paging.next)

        else
          console.log data
          cb()

      ]


      getTasks:['checkList', (cb) ->
        Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
          return txErr url, 5, {err:err, fun:'getTasks'} if err

          cb(null, rows)
      ]

      addDo:['getTasks', (cb, result) ->
        tasks = result.getTasks
        async.eachSeries tasks, (item, callback) ->
          queue.push {url:item.url, noteStore:self.noteStore, noteBook:self.noteBook}, (err) ->
            if err
              return txErr item.url, 6, {err:err, fun:'addDo'}

            self.changeStatus(item.url, 2)


          callback()

      ]



  addDB:(url, callback) ->
    task = new Task
    task.url = url
    task.save (err, row) ->
      return txErr url, 5, {err:err, fun:'addDB'} if err

      callback()

#  addTask:(url) ->
#    self = @
#    async.auto
#      addDB:(callback) ->
#        task = new Task
#        task.url = url
#        task.save (err, row) ->
#          return txErr url, 5, {err:err, fun:'addDB'} if err
#
#          callback()
#
#      addDo:['addDB', (callback) ->
#        queue.push {url:url, noteStore:self.noteStore, noteBook:self.noteBook}, (err) ->
#          if err
#            return txErr url, 6, {err:err, fun:'addDo'}
#
#      ]

  changeStatus: (url, status) ->
    async.auto
      findUrl:(callback) ->
        Task.findOne {url:url}, (err, row) ->
          return txErr url, 5, {err:err, fun:'changeStatus-findUrl'} if err

          if not row
            return txErr url, 7, {err:"没有找到url", fun:'changeStatus-findUrl'}

          else
            callback(null, row)


      change:['findUrl', (callback, result) ->
        row = result.findUrl
        row.status = status
        row.save (err, row) ->
          return txErr "", 5, {err:err, fun:"changeStatus-change"} if err

      ]







  getColInfo:() ->


module.exports = GetCol
