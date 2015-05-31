GetCol = require('../lib/getCollection')
noteStore = require('../lib/noteStore')
schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.dayOfWeek = [0, new schedule.Range(1, 6)]
rule.hour = 18
rule.minute = 30

#j = schedule.scheduleJob rule, () ->

col = [
  {
    url:'https://api.zhihu.com/collections/30429493/answers' # 点赞过万
    noteBook:'ac14ddad-cc5b-439a-82f2-2348afb9f7e0'
  }
  {
    url:'https://api.zhihu.com/collections/19710429/answers' # 关于爱情
    noteBook:'9485b127-4399-41c5-b2ec-569047fdb960'
  }
  {
    url:'https://api.zhihu.com/collections/19731344/answers' # 人丑就该多读书
    noteBook:'39538a19-d027-4b8b-85d9-a718a70f7006'
  }
  {
    url:'https://api.zhihu.com/collections/19932288/answers' # 程序员进阶
    noteBook:'de711cea-3fbe-4181-b03b-f9018415a40c'
  }
  {
    url:'https://api.zhihu.com/collections/21017107/answers' # 知乎--带来无穷的智慧
    noteBook:'a8ef249b-aa81-4f66-9d34-645aa79f1183'
  }
  {
    url:'https://api.zhihu.com/collections/29469118/answers' # 知乎收藏
    noteBook:'f082258a-fd9a-4713-98a0-d85fa838f019'
  }
]

col.forEach (item, v) ->
    t = new GetCol(noteStore, item.noteBook)
    t.getColList(item.url)