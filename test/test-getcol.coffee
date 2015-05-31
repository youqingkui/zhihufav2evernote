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
    url:'https://api.zhihu.com/collections/19932288/answers' # 知乎收藏
    noteBook:'4aad11b8-b6ac-4afc-b4c3-103a530c6dc4' # 知乎测试1
  }
  {
    url:'https://api.zhihu.com/collections/19745661/answers' # 其他收藏
    noteBook:'371df8dd-d950-4e66-a801-2ce719cab2d3' # 知乎测试2
  }
]

col.forEach (item, v) ->
    t = new GetCol(noteStore, item.noteBook)
    t.getColList(item.url)