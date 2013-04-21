###
Setup the database

The database is hardcoded to `msgdb`.

```sh
mongo setup-mongo.js
```

To insert, you must do this

```js
db.events.insert(
  {
    _id: db.eval('nextEventsID()'),
    type: null,
    msg: null,
    author: null
  }
)
```

###

DBNAME = 'msgdb'

conn = new Mongo()
db = conn.getDB DBNAME

db.createCollection 'counters'
# Only one collection is needed.
db.createCollection 'events'


# Make a counter fetcher.

###
Sets up the `events` collection to have an increment.

This used to be magic but then the magic broke. :c
###
makeIncrementer = () ->
  name = 'events'
  db.counters.save
    _id: name
    seq: 0

  incrementer = () ->
    rec = db.counters.findAndModify
      query:
        _id: 'events',
      update:
        $inc: { seq: 1 }
      new: yes
    rec.seq

  db.system.js.save
    _id: "nextEventID"
    value: incrementer

makeIncrementer()

