// Generated by CoffeeScript 1.8.0
(function() {
  var noteStore;

  noteStore = require('../lib/noteStore');

  noteStore.listNotebooks(function(err, info) {
    var k, _i, _len, _results;
    if (err) {
      return console.log(err);
    }
    _results = [];
    for (_i = 0, _len = info.length; _i < _len; _i++) {
      k = info[_i];
      _results.push(console.log(k.guid + " => " + k.name));
    }
    return _results;
  });

}).call(this);

//# sourceMappingURL=list-books.js.map
