async = require('async')
request = require('request')
Task = require('../models/task')

class Check
  constructor:(@url, @noteBooks) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }

  getList:(cb) ->
    self = @
    op = {
      url:url
      headers:self.headers
      gzip:true
    }

    async.waterfall [
      (callback) ->
        requrest.get op, (err, res, body) ->
          return txErr {err:err,fun:'getList',url:self.url}, cb if err

          data = JSON.parse(body)
          callback(null, data)

      (data, callback) ->
        if data.data.length
          a = 123
    ]


  checkAdd:(data, cb) ->
    self = @
    async.eachSeries data, (item, callback) ->
      Task.findOne {url:item.url}, (err, row) ->
        return txErr {err:err, answer:item.url, fun:'checkAdd'}, cb if err

        if row
          console.log "already exits ==>", item.url
          callback()

        else
          self.addTask item, (err) ->




  addTask:(data, cb) ->
    self = @
    t = Task()
    t.url = data.url
    t.noteBook = self.noteBook
    t.id = data.id
    t.created_time = data.created_time
    t.updated_time = data.updated_time

    t.save (err) ->
      return txErr {err:err, fun:'addTask',url:data.url}, cb if err

      cb()




