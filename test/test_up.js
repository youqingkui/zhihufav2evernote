// Generated by CoffeeScript 1.8.0
(function() {
  var Task, UpdateEvernote, async, noteStore;

  async = require('async');

  Task = require('../models/task');

  noteStore = require('../lib/noteStore');

  UpdateEvernote = require('../lib/updateEvernote');

  async.waterfall([
    function(cb) {
      return Task.find({
        status: 3
      }, null, {
        sort: {
          _id: -1
        }
      }, function(err, rows) {
        if (err) {
          return txErr({
            err: err,
            fun: 'TaskFind'
          }, callback);
        }
        return cb(null, rows);
      });
    }, function(rows) {
      return async.eachSeries(rows, function(item, callback) {
        var u;
        if (item.guid) {
          u = new UpdateEvernote(item.url, noteStore, item.noteBook, item.guid, item);
          return u.upNote(callback);
        }
      }, function() {
        return console.log("# all do #");
      });
    }
  ]);

}).call(this);

//# sourceMappingURL=test_up.js.map
