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
    url:'https://api.zhihu.com/collections/29469118/answers'
    noteBook:'f082258a-fd9a-4713-98a0-d85fa838f019'
  }
  {
    url:'https://api.zhihu.com/collections/19932288/answers'
    noteBook:'abfa14bd-8abf-4399-a0ee-70da3b253033'
  }
]

col.forEach (item) ->
  t = new GetCol(noteStore, item.noteBook)
  t.getColList(item.url)