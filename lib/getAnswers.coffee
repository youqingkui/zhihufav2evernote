request = require('request')
async = require('async')
makeNote = require('./createNote')
Evernote = require('evernote').Evernote
cheerio = require('cheerio')
crypto = require('crypto')
txErr = require('./txErr')


q = async.queue (data, cb) ->
  console.log "#{data.url}  #{data.noteBook} now do"
  g = new GetAnswer(data.url, data.noteStore, data.noteBook)
  async.series [

    (callback) ->
      g.getContent(callback)

    (callback) ->
      g.changeContent(callback)

    (callback) ->
      g.createNote(callback)


  ],(err) ->
    return cb(err) if err
    cb()
, 1


q.saturated = () ->
  console.log('all workers to be used')


q.empty = () ->
  console.log('no more tasks wating')


q.drain = () ->
  console.log('all tasks have been processed')






class GetAnswer
  constructor:(@url, @noteStore, @noteBook) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }
    @resourceArr = []


  getContent:(cb) ->
    self = @
    op = {
      url:self.url
      headers:self.headers
      gzip:true
    }

    request.get op, (err, res, body) ->
      return txErr(op.url, 1, {err:err, fun:'getContent'},cb) if err

      data = JSON.parse(body)
      self.title = data.question.title.trim()
      self.tagArr = []
      self.sourceUrl = 'http://www.zhihu.com/question/'+
          data.question.id + '/answer/' + data.id

      self.content = data.content
      self.created = Date.now / 1000
#      self.updated = data.updated_time

      cb()

# 转换内容
  changeContent: (cb) ->
    self = @
    $ = cheerio.load(self.content, {decodeEntities: false})
    $("*")
    .map (i, elem) ->
      for k, v of elem.attribs
        if k != 'data-actualsrc' and k != 'src' and k !='href' and k != 'style'
          $(this).removeAttr(k)

        if k is 'href'
          if !self.checkUrl(v)
            $(this).removeAttr(k)

    $("iframe").remove()

    $("article").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("section").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("header").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("noscript").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    imgs = $("img")
    console.log "#{self.title} find img length => #{imgs.length}"
    async.eachSeries imgs, (item, callback) ->
      src = $(item).attr('data-actualsrc')
      if not src
        src = $(item).attr('src')

      self.readImgRes src, (err, resource) ->
        return txErr(src, 2, {err:err, title:self.title, url:self.url,fun:'changeContent'}, cb) if err

        self.resourceArr.push resource
        md5 = crypto.createHash('md5')
        md5.update(resource.image)
        hexHash = md5.digest('hex')
        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} />"
        $(item).replaceWith(newTag)

        callback()

    ,() ->
      console.log "#{self.title} #{imgs.length} imgs down ok"
      self.enContent = $.html({xmlMode:true, decodeEntities: false})

      cb()

# 创建笔记
  createNote: (cb) ->
    self = @
    makeNote @noteStore, @title, @tagArr, @enContent, @sourceUrl, @resourceArr,
      @created, @updated, @noteBook
      (err, note) ->
        if err
          return txErr(self.url, 3, {err:err, title:self.title}, cb) if err

        console.log "+++++++++++++++++++++++"
        console.log "#{note.title} create ok"
        console.log "+++++++++++++++++++++++"

        cb()


# 读取远程图片
  readImgRes: (imgUrl, cb) ->
    self = @
    op = self.reqOp(imgUrl)
    op.encoding = 'binary'
    async.auto
      readImg:(callback) ->
        request.get op, (err, res, body) ->
          return cb(err) if err
          mimeType = res.headers['content-type']
          mimeType = mimeType.split(';')[0]
          callback(null, body, mimeType)

      enImg:['readImg', (callback, result) ->
        mimeType = result.readImg[1]
        image = new Buffer(result.readImg[0], 'binary')
        hash = image.toString('base64')

        data = new Evernote.Data()
        data.size = image.length
        data.bodyHash = hash
        data.body = image

        resource = new Evernote.Resource()
        resource.mime = mimeType
        resource.data = data
        resource.image = image
        cb(null, resource)
      ]

  reqOp:(getUrl) ->
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',

    return options

  checkUrl:(href) ->
    strRegex = "^((https|http|ftp|rtsp|mms)?://)"
    + "?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?"
    + "(([0-9]{1,3}/.){3}[0-9]{1,3}" + "|"
    + "([0-9a-z_!~*'()-]+/.)*"
    + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]/."
    + "[a-z]{2,6})"
    + "(:[0-9]{1,4})?"
    + "((/?)|"
    + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"

    re = new RegExp(strRegex)
    if re.test href
      return true

    else
      return false



module.exports = q

