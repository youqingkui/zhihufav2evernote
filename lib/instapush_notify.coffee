
instapush = require("instapush")
instapush.settings {
  id:process.env.instapush_id,
  secret:process.env.instapush_secret
}

instapush_notify = (title) ->
  nowDate = new Date()
  date = nowDate.toLocaleDateString() + " "+ nowDate.toLocaleTimeString()
  instapush.notify {
    'event':'zhihufav',
    'trackers':{'title':title, 'date':date}
  }, (err, res) ->
    console.log err if err
    console.log res



#instapush_notify('1234')

module.exports = instapush_notify

