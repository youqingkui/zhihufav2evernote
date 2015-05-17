// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, GetAnswer, async, cheerio, crypto, makeNote, q, request, txErr;

  request = require('request');

  async = require('async');

  makeNote = require('./createNote');

  Evernote = require('evernote').Evernote;

  cheerio = require('cheerio');

  crypto = require('crypto');

  txErr = require('./txErr');

  q = async.queue(function(data, cb) {
    var g;
    console.log("" + data.url + " now do");
    g = new GetAnswer(data.url, data.noteStore);
    return async.series([
      function(callback) {
        return g.getContent(callback);
      }, function(callback) {
        return g.changeContent(callback);
      }, function(callback) {
        return g.createNote(callback);
      }
    ], function(err) {
      if (err) {
        return cb(err);
      }
      return cb();
    });
  }, 10);

  q.saturated = function() {
    return console.log('all workers to be used');
  };

  q.empty = function() {
    return console.log('no more tasks wating');
  };

  q.drain = function() {
    return console.log('all tasks have been processed');
  };

  GetAnswer = (function() {
    function GetAnswer(url, noteStore) {
      this.url = url;
      this.noteStore = noteStore;
      this.headers = {
        'User-Agent': 'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0',
        'Authorization': 'oauth 5774b305d2ae4469a2c9258956ea49',
        'Content-Type': 'application/json'
      };
      this.resourceArr = [];
    }

    GetAnswer.prototype.getContent = function(cb) {
      var op, self;
      self = this;
      op = {
        url: self.url,
        headers: self.headers,
        gzip: true
      };
      return request.get(op, function(err, res, body) {
        var data;
        if (err) {
          return txErr(op.url, 1, {
            err: err,
            fun: 'getContent'
          }, cb);
        }
        data = JSON.parse(body);
        self.title = data.question.title;
        self.tagArr = [];
        self.sourceUrl = 'http://www.zhihu.com/question/' + data.question.id + '/answer/' + data.id;
        self.content = data.content;
        self.created = data.created_time;
        self.updated = data.updated_time;
        return cb();
      });
    };

    GetAnswer.prototype.changeContent = function(cb) {
      var $, imgs, self;
      self = this;
      $ = cheerio.load(self.content, {
        decodeEntities: false
      });
      $("a, span, img, i, div, code").map(function(i, elem) {
        var k, _results;
        _results = [];
        for (k in elem.attribs) {
          if (k !== 'data-actualsrc' && k !== 'src') {
            _results.push($(this).removeAttr(k));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      imgs = $("img");
      console.log("" + self.title + " find img length => " + imgs.length);
      return async.eachSeries(imgs, function(item, callback) {
        var src;
        src = $(item).attr('data-actualsrc');
        if (!src) {
          src = $(item).attr('src');
        }
        return self.readImgRes(src, function(err, resource) {
          var hexHash, md5, newTag;
          if (err) {
            return txErr(src, 2, {
              err: err,
              title: self.title,
              url: self.url,
              fun: 'changeContent'
            }, cb);
          }
          self.resourceArr.push(resource);
          md5 = crypto.createHash('md5');
          md5.update(resource.image);
          hexHash = md5.digest('hex');
          newTag = "<en-media type=" + resource.mime + " hash=" + hexHash + " />";
          $(item).replaceWith(newTag);
          return callback();
        });
      }, function() {
        console.log("" + self.title + " " + imgs.length + " imgs down ok");
        self.enContent = $.html({
          xmlMode: true,
          decodeEntities: false
        });
        return cb();
      });
    };

    GetAnswer.prototype.createNote = function(cb) {
      var self;
      self = this;
      return makeNote(this.noteStore, this.title, this.tagArr, this.enContent, this.sourceUrl, this.resourceArr, this.created, this.updated, function(err, note) {
        if (err) {
          if (err) {
            return txErr(self.url, 3, {
              err: err,
              title: self.title
            }, cb);
          }
        }
        console.log("+++++++++++++++++++++++");
        console.log("" + note.title + " create ok");
        console.log("+++++++++++++++++++++++");
        return cb();
      });
    };

    GetAnswer.prototype.readImgRes = function(imgUrl, cb) {
      var op, self;
      self = this;
      op = self.reqOp(imgUrl);
      op.encoding = 'binary';
      return async.auto({
        readImg: function(callback) {
          return request.get(op, function(err, res, body) {
            var mimeType;
            if (err) {
              return cb(err);
            }
            mimeType = res.headers['content-type'];
            mimeType = mimeType.split(';')[0];
            return callback(null, body, mimeType);
          });
        },
        enImg: [
          'readImg', function(callback, result) {
            var data, hash, image, mimeType, resource;
            mimeType = result.readImg[1];
            image = new Buffer(result.readImg[0], 'binary');
            hash = image.toString('base64');
            data = new Evernote.Data();
            data.size = image.length;
            data.bodyHash = hash;
            data.body = image;
            resource = new Evernote.Resource();
            resource.mime = mimeType;
            resource.data = data;
            resource.image = image;
            return cb(null, resource);
          }
        ]
      });
    };

    GetAnswer.prototype.reqOp = function(getUrl) {
      var options;
      options = {
        url: getUrl,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'
        }
      };
      return options;
    };

    return GetAnswer;

  })();

  module.exports = q;

}).call(this);

//# sourceMappingURL=getAnswers.js.map