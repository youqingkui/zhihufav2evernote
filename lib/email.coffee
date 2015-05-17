nodemailer = require('nodemailer')

module.exports = () ->

  transporter = nodemailer.createTransport
    service: 'QQ'
    auth:
      user: process.env.ERROR_EMAIL
      pass: process.env.ERROR_EMAIL_PWD


  send:(body, to='youqingkui@qq.com', subj='hi') ->
    transporter.sendMail
      from: 'youqingkui@qq.com'
      to: to
      subject: subj
      html: body
      generateTextFromHtml: true

    ,(err, info) ->
      return console.log err if err

      console.log info