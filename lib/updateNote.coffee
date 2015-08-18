Evernote = require('evernote').Evernote

updateNote = (noteStore, guid, noteTitle, noteBody, options, callback) ->
  nBody = '<?xml version="1.0" encoding="UTF-8"?>'
  nBody += '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">'

  nBody += '<en-note>' + noteBody + '</en-note>'
  #  console.log noteBody
  # Create note object
  ourNote = new Evernote.Note()
  ourNote.guid = guid
  ourNote.title = noteTitle
  ourNote.content = nBody
  attr = new Evernote.NoteAttributes
  if options
    if options.sourceURL
      attr.sourceURL = options.sourceUrl

    if options.resources
      ourNote.resources = options.resources

    if options.tagNames
      ourNote.tagNames = options.tagNames

    if options.notebookGuid
      ourNote.notebookGuid = options.notebookGuid

    if options.created
      ourNote = options.created * 1000

    if options.updated
      ourNote.updated = options.updated * 1000


  ourNote.attributes = attr
  #  console.log nBody

  # parentNotebook is optional; if omitted, default notebook is used
  #  if parentNotebook and parentNotebook.guid
  #    ourNote.notebookGuid = parentNotebook.guid
  # Attempt to create note in Evernote account
  noteStore.updateNote ourNote, (err, note) ->
    if err
# Something was wrong with the note data
# See EDAMErrorCode enumeration for error code explanation
# http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
      console.log err
      console.log noteTitle
      callback(err)
    else
      callback null, note


module.exports = updateNote