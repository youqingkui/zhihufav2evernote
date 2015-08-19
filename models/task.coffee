mongoose = require('./mongoose')

TaskSchema = mongoose.Schema
  url:{type:String, unique: true}
  noteBook:String
  status:{type:Number, default:1}
  id:{type:Number}
  guid:{type:String}
  title:{type:String}
  created_time:{type:Number}
  updated_time:{type:Number}

module.exports = mongoose.model('Task', TaskSchema)