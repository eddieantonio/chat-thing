expect = require('chai').expect
mongoose = require 'mongoose'


models = require '../../lib/schemata'

DEFAULT_MONGO_URL = 'mongodb://127.0.0.1/test'


describe 'Event model', ->
  # Will be defined during tests.
  connection = undefined
  Event = undefined

  beforeEach (done) ->
    connection =
      mongoose.createConnection process.env.MONGO_URL or DEFAULT_MONGO_URL
    connection.once 'open', ->
      {Event} = models(connection)
      done()

  afterEach (done) ->
    connection.close ->
      done()

  describe '.makeMe', ->
    it "should make a 'me' event", ->
      evt = Event.makeMe 'herbert', 'is testing'

      expect(evt)
        .to.be.instanceOf(Event)
        .property('type')
        .and.equal('me')

  describe '.makeConnected', ->
    it "should make a new 'connected' event", ->
      evt = Event.makeConnected 'herbert', 'test message'

      expect(evt)
        .to.be.instanceOf(Event)
        .property('type')
        .and.equal('connected')

  describe '.makeDisconnected', ->
    it "should make a new 'disconnected' event", ->
      evt = Event.makeDisconnected 'herbert', 'test message'

      expect(evt)
        .to.be.instanceOf(Event)
        .property('type')
        .and.equal('disconnected')

  describe '.makeMessage', ->
    it "should make a new 'msg' event", ->
      evt = Event.makeMessage 'herbert', 'test message'

      expect(evt)
        .to.be.instanceOf(Event)
        .property('type')
        .and.equal('msg')

