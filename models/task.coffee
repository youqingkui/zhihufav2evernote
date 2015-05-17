mongoose = require('./mongoose')

TaskSchema = mongoose.Schema
  url:String
  status:{type:Number, default:1, unique: true}

module.exports = mongoose.model('Task', TaskSchema)