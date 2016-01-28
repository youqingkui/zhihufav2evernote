PushEvernote = require('./lib/pushEvernote')
async = require('async')
Task = require('./models/task')
txErr = require('./lib/txErr')
noteStore = require('./lib/noteStore')
UpdateEvernote = require('./lib/updateEvernote')
Check = require('./lib/check')
mongoose = require('./models/mongoose')


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

  {
    url:'https://api.zhihu.com/collections/19932288/answers' # 知乎--程序员进阶
    noteBook:'de711cea-3fbe-4181-b03b-f9018415a40c'
  }
  {
    url:'https://api.zhihu.com/collections/29001814/answers' # 知乎--品质生活馆
    noteBook:'474f7f8e-13e2-4d29-850d-48e49ed14cc0'
  }

]

async.waterfall [

  (cb) ->

    async.eachLimit col, 4,  (item, callback) ->
      recursive = if Math.random() > 0.5 then true else false
      c = new Check(item.url, item.noteBook, recursive)
      c.getList(item.url, callback)

    ,(err) ->
      return console.log err if err

      mongoose.connection.close()
      cb()
]



