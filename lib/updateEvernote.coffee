PushEvernote = require('./pushEvernote')
updateNote = require('./updateNote')
noteStore = require('./noteStore')
txErr = require('./txErr')
async = require('async')

class UpdateEvernote extends PushEvernote
  constructor:(@url, @noteStore, @noteBook, @guid) ->
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
    ]



  updateNoteInfo:(cb) ->
    self = @
    options = {
      sourceURL:self.sourceUrl
      resources:self.resourceArr
      notebookGuid:self.notebookGuid
    }
    updateNote noteStore, self.guid, self.title, self.enContent, options, (err, note) ->
      return txErr {err:err,fun:'updateNoteInfo',url:self.url}, cb if err

      cb()






