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
rule1.hour = 0
rule1.minute = 25

rule2.dayOfWeek = [0, new schedule.Range(1, 6)]
rule2.hour = 0
rule2.minute = 25


#schedule.scheduleJob rule1, () ->
## 检查
#  col = [
#    {
#      url:'https://api.zhihu.com/collections/29469118/answers' # 知乎收藏
#      noteBook:'f082258a-fd9a-4713-98a0-d85fa838f019'
#    }
#
#    {
#      url:'https://api.zhihu.com/collections/30429493/answers' # 点赞过万
#      noteBook:'ac14ddad-cc5b-439a-82f2-2348afb9f7e0'
#    }
#
#    {
#      url:'https://api.zhihu.com/collections/29084869/answers' # 提高生活幸福感
#      noteBook:'359e0882-b0a7-41bc-8437-38fe1afff418'
#    }
#
#    {
#      url:'https://api.zhihu.com/collections/41332067/answers' # 梦想的雏形（家居）
#      noteBook:'c3c8c27b-c014-4b10-83b2-b98461affaf3'
#    }
#
#    {
#      url:'https://api.zhihu.com/collections/21017107/answers' # 知乎--带来无穷的智慧
#      noteBook:'a8ef249b-aa81-4f66-9d34-645aa79f1183'
#    }
#
## 匪风 的收藏
#
#    {
#      url:'https://api.zhihu.com/collections/71977517/answers' # 知乎骗照三百问
#      noteBook:'ae1c443e-8b29-4952-b485-1a874423854a'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/72869497/answers' # 望眼欲穿的痴情
#      noteBook:'d4fb8c31-466a-466e-90c5-97a85ba0757f'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/71964508/answers' # 回眸一笑百媚生
#      noteBook:'7274ba2b-aec2-4704-92b0-95300d127ec9'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/72869482/answers' # 无限风光在险峰
#      noteBook:'fd6ab906-1f5e-43bf-8caf-d79689be274e'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/71964476/answers' # 万水千山不能没你
#      noteBook:'ec5ab000-9615-4e78-b415-d761e1d90be3'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/72871358/answers' # 老虎摸不得的禁忌
#      noteBook:'f8cee834-1e3e-45f3-9524-fb26b01d2488'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/72107092/answers' # 长发
#      noteBook:'8da41fc3-9020-425d-b7ab-39c10253f1b1'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/71964729/answers' # 女生常说的秘密
#      noteBook:'f7dc8d77-5830-4209-bfa2-5fd09687b10d'
#
#    }
#    {
#      url:'https://api.zhihu.com/collections/71438819/answers' # 有意思的问题
#      noteBook:'4d95c614-b935-4f9e-bf88-081a859d0ea2'
#
#    }
#
#  ]
#
#  col.forEach (item) ->
#    c = new Check(item.url, item.noteBook)
#    c.getList()
#
#
#schedule.scheduleJob rule2, () ->
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
