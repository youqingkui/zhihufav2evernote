mongoose = require('./mongoose')

TaskSchema = mongoose.Schema
  url:{type:String, unique: true}
  status:{type:Number, default:1}

module.exports = mongoose.model('Task', TaskSchema)