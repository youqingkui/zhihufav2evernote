PushEvernote = require('./pushEvernote')
updateNote = require('./updateNote')
noteStore = require('./noteStore')
txErr = require('./txErr')
async = require('async')

class UpdateEvernote extends PushEvernote
  constructor:(@url, @noteStore, @noteBook, @guid, @row) ->
    super



  upNote:(cb) ->
    self = @

    async.series [
      (callback) ->
        self.getContent(callback)

      (callback) ->
        self.changeContent(callback)

      (callback) ->
        self.updateNoteInfo(callback)

      (callback) ->
        self.changeStatus(callback)

    ]
    ,() ->
      cb()

  changeStatus:(cb) ->
    self = @
    self.row.status = 2
    self.row.save (err) ->
      return txErr {err:err, fun:'changeStatus',url:self.url}, cb if err

      cb()



  updateNoteInfo:(cb) ->
    self = @
    options = {
      sourceUrl:self.sourceUrl
      resources:self.resourceArr
      notebookGuid:self.notebookGuid
    }
    console.log self.sourceUrl
    updateNote noteStore, self.guid, self.title, self.enContent, options, (err, note) ->
      return txErr {err:err,fun:'updateNoteInfo',url:self.url}, cb if err

      cb()


module.exports = UpdateEvernote




