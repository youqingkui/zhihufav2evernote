PushEvernote = require('../lib/pushEvernote')
async = require('async')
Task = require('../models/task')
txErr = require('../lib/txErr')
noteStore = require('../lib/noteStore')
UpdateEvernote = require('../lib/updateEvernote')
Check = require('../lib/check')
schedule = require("node-schedule")

rule1 = new schedule.RecurrenceRule()
rule2 = new schedule.RecurrenceRule()

rule1.dayOfWeek = [0, new schedule.Range(1, 6)]
rule1.hour = 18
rule1.minute = 10

rule2.dayOfWeek = [0, new schedule.Range(1, 6)]
rule2.hour = 18
rule2.minute = 15


schedule.scheduleJob rule1, () ->
  # 检查
  col = [
    {
      url:'https://api.zhihu.com/collections/29469118/answers' # 知乎收藏
      noteBook:'f082258a-fd9a-4713-98a0-d85fa838f019'
    }

    {
      url:'https://api.zhihu.com/collections/30429493/answers' # 点赞过万
      noteBook:'ac14ddad-cc5b-439a-82f2-2348afb9f7e0'
    }

    {
      url:'https://api.zhihu.com/collections/29084869/answers' # 提高生活幸福感
      noteBook:'359e0882-b0a7-41bc-8437-38fe1afff418'
    }

    {
      url:'https://api.zhihu.com/collections/41332067/answers' # 梦想的雏形（家居）
      noteBook:'c3c8c27b-c014-4b10-83b2-b98461affaf3'
    }
    {
      url:'https://api.zhihu.com/collections/21017107/answers' # 知乎--带来无穷的智慧
      noteBook:'a8ef249b-aa81-4f66-9d34-645aa79f1183'
    }

  ]

  col.forEach (item) ->
    c = new Check(item.url, item.noteBook)
    c.getList()


schedule.scheduleJob rule2, () ->
  # 创建
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


  # 更新
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
        console.log "# all do #"

]
