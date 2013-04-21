###
Handles messages and stuff!
###

mongo = require 'mongodb'

# Spend a maximum of 30s on a request.
REQUEST_TIMEOUT = 30000
POLL_INTERVAL = 250



###
Connect to MongoDB asychronously, and use the events collection.
###
msgDbConnect = (callback) ->
  mongo.MongoClient.connect 'mongodb://127.0.0.1/msgdb', (err, db) ->
    throw err if err

    # Get the proper collection
    collection = db.collection 'events'
    callback collection, db



###
Post a new message.
###
exports.post = (req, res) ->

  {message} = req.body

  # Make sure it doesn't live on forever.
  timer = setTimeout( ->
    res.send 504
  , REQUEST_TIMEOUT)

  msgDbConnect (events, db) ->

    record =
      msg: message
      ts: new Date()

    # This occurs if the record was inserted properly.
    events.insert record, (err, records) ->
      clearTimeout timer
      return res.send 503 if err

      id = records[0]._id

      res.location "/message/#{id}"
      res.send 201

      db.close()


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

  msgDbConnect (collection, db) ->

    # Keep fetchin' 'till we shan't fetch no more...
    keepFetchin = ->

      # Return 'unchanged' after a while.
      return res.send 200, {last: last} unless shouldFetch

      # Find all events whose ts is greater than the last.
      collection.find({ts: {$gt: last}}).toArray (err, docs) ->

        return res.send 503 if err

        if docs.length > 0
          clearTimeout timer

          [_..., mostRecent] = docs
          res.send
            last: mostRecent.ts
            evts: docs

          db.close()
        else
          setTimeout keepFetchin, POLL_INTERVAL

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

  msgDbConnect (events, db) ->

    events.findOne {_id: oid}, (err, doc) ->
      if doc?
        res.send doc
      else
        res.send 404
      db.close()


