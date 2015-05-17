GetCol = require('../lib/getCollection')
noteStore = require('../lib/noteStore')
schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.dayOfWeek = [0, new schedule.Range(1, 6)]
rule.hour = 18
rule.minute = 30

#j = schedule.scheduleJob rule, () ->
url = 'https://api.zhihu.com/collections/29469118/answers'

g = new GetCol(noteStore, 'f082258a-fd9a-4713-98a0-d85fa838f019')
g.getColList(url)