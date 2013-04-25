###
Handles messages and stuff!
###

mongoose = require 'mongoose'
makeModels = require '../schemata'

# Spend a maximum of 30s on a request.
REQUEST_TIMEOUT = 30000
# Rerequest the database every 250ms
POLL_INTERVAL = 250

# Specifiy the database name
# TODO: put this in a config file!
DB_NAME = 'msgdb'


###
Connect to MongoDB asychronously, and use the events collection.
###
withModels = (callback) ->
  connection =
    mongoose.createConnection 'mongodb://127.0.0.1/msgdb'

  connection.once 'connected', ->
    models = makeModels connection
    callback models, connection


###
Post a new message.
###
exports.post = (req, res) ->

  {message} = req.body

  # Make sure it doesn't live on forever.
  timer = setTimeout( ->
    res.send 504
  , REQUEST_TIMEOUT)

  withModels (models) ->

    {Event} = models

    record = Event.makeMessage null, message

    record.save (err, msg) ->
      return res.send 500 if err
      res.location "/message/#{msg._id}"
      res.send 201



###
Get the latest messages.
###
exports.longpoll = (req, res) ->
  last = if req.query.last?
    new Date(req.query.last)
  else
    new Date()

  shouldFetch = true

  timer = setTimeout( ->
    shouldFetch = false
  , REQUEST_TIMEOUT)

  withModels (model) ->

    {Event} = model

    # Keep fetchin' 'till we shan't fetch no more...
    keepFetchin = ->

      # Return 'unchanged' after a while.
      return res.send 200, {last: last} unless shouldFetch

      # Find all events whose ts is greater than the last.
      promise = Event.find({ts: {$gt: last}}).exec()

      promise.then(
        (docs) ->
          if docs.length > 0
            clearTimeout timer

            [_..., mostRecent] = docs
            res.send
              last: mostRecent.ts
              evts: docs

          else
            setTimeout keepFetchin, POLL_INTERVAL

        , ->
          # On error.
          clearTimeout timer
          res.send 503
      )


    # Start the fetch loop.
    keepFetchin()



###
Get a specific message, by URL.
###
exports.getMessage = (req, res) ->

  {id} = req.params

  try
    oid = new mongo.ObjectID id
  catch err
    return res.send 400

  withModels (events, db) ->

    events.findOne {_id: oid}, (err, doc) ->
      if doc?
        res.send doc
      else
        res.send 404
      db.close()


