// Generated by CoffeeScript 1.10.0
(function() {
  var Check, PushEvernote, Task, UpdateEvernote, async, noteStore, p, schedule, txErr;

  PushEvernote = require('../lib/pushEvernote');

  async = require('async');

  Task = require('../models/task');

  txErr = require('../lib/txErr');

  noteStore = require('../lib/noteStore');

  UpdateEvernote = require('../lib/updateEvernote');

  Check = require('../lib/check');

  schedule = require("node-schedule");

  p = new PushEvernote('https://api.zhihu.com/answers/83350780', noteStore);

  p.pushNote(function() {
    return console.log("ok");
  });

}).call(this);

//# sourceMappingURL=test_push_note.js.map
