mongoose = require('./mongoose')

TaskSchema = mongoose.Schema
  url:{type:String, unique: true}
  noteBook:String
  status:{type:Number, default:1}
  id:{type:Number, unique: true}
  guid:{type:String, unique: true}
  created_time:{type:Number}
  updated_time:{type:Number}

module.exports = mongoose.model('Task', TaskSchema)