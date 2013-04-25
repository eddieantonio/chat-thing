###
Defines the Mongoose schema used for user tables.
###

mongoose = require 'mongoose'

###
This is the schema!
###
eventSchema = mongoose.Schema
  # Mandatory fields
  type:   String
  ts:
    type: Date
    default: Date.now
  # Context-dependent fields
  msg:    String
  from:   String
  to:     String


# Schema paramaters
eventSchema.set 'autoIndex', false # if process.env.node_env isnt 'development'


# Helpers

###
Create a 'connected' event.
###
eventSchema.statics.makeConnected = (user) ->
  new this
    type: 'connected'
    from: user

###
Create a 'disconnected' event.
###
eventSchema.statics.makeDisconnected = (user) ->
  new this
    type: 'disconnected'
    from: user

###
Create a 'msg' event.
###
eventSchema.statics.makeMessage = (user, msg) ->
  new this
    type: 'msg'
    from: user
    msg: msg

###
Create a 'me' event.
###
eventSchema.statics.makeMe = (user, msg) ->
  new this
    type: 'me'
    from: user
    msg: msg


module.exports = eventSchema

