async = require('async')
request = require('request')
Task = require('../models/task')
txErr = require('../lib/txErr')

class Check
  constructor:(@url, @noteBook) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }

  getList:(url) ->
    self = @
    if not url
      url = self.url
    op = {
      url:url
      headers:self.headers
      gzip:true
    }

    async.waterfall [
      (callback) ->
        request.get op, (err, res, body) ->
          return txErr {err:err,fun:'getList',url:self.url}, cb if err

          data = JSON.parse(body)
          callback(null, data)

      (data, callback) ->
        if data.data.length
          self.checkAdd data, callback

        else
          console.log data
    ]


  checkAdd:(data, cb) ->
    self = @
    async.eachSeries data.data, (item, callback) ->
      Task.findOne {url:item.url}, (err, row) ->
        return txErr {err:err, answer:item.url, fun:'checkAdd'}, cb if err

        if row
          self.upTask item, row, callback

        else
          self.addTask item, callback

    ,(err) ->
      return cb(err) if err

      self.getList(data.paging.next)


  addTask:(data, cb) ->
    self = @
    t = Task()
    t.url = data.url
    t.noteBook = self.noteBook
    t.id = data.id
    t.created_time = data.created_time
    t.updated_time = data.updated_time
    t.title = data.question.title

    t.save (err) ->
      return txErr {err:err, fun:'addTask',url:data.url}, cb if err

      console.log "+++++++++++++++++++++++"
      console.log "添加成功", t.url, t.title
      console.log "+++++++++++++++++++++++"
      cb()


  upTask:(data, row, cb) ->
    console.log "already exits ==>", data.url, data.question.title

    if row.updated_time and data.updated_time != row.updated_time
        row.updated_time = data.updated_time
        if row.status == 2
          row.status = 3
        row.save (err) ->
          return txErr {err:err, fun:'upTask',url:data.url}, cb if err

          console.log "######################################"
          console.log "need update ", data.question.title
          console.log "######################################"
          cb()

      else
        cb()


url = 'https://api.zhihu.com/collections/29469118/answers'
noteBook = '44fcb5a8-e24c-406e-aa84-fc67354fb630'
c = new Check(url, noteBook)
c.getList()

