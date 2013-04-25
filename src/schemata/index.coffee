###
# Loads all schemas as models 
#
# Based on:
# https://github.com/j0ni/beachenergy.ca/blob/master/datamodel/index.js
#
###

eventSchema = require './event'

module.exports = (connection) ->

  getModel = (name, schema) ->
    try
      connection.model name
    catch e
      connection.model name, schema

  models =
    Event: getModel 'Event', eventSchema

