{should, assert} = require 'chai'
should()

TimeoutEmitter = require '../lib/messages/TimeoutEmitter'
{EventEmitter} = require 'events'

describe 'TimeoutEmitter', ->
  it 'should be an EventEmitter', ->
    timer = new TimeoutEmitter()

    timer.should.be.instanceOf EventEmitter

  it "should emit a 'started' event when start()'d", (done) ->
    timer = new TimeoutEmitter()

    timer.on 'started', ->
      done()

    timer.start 0

  it "should emit a 'timeout' event when the timeout expires", (done) ->
    timer = new TimeoutEmitter()

    timer.on 'timeout', ->
      done()

    timer.start 0

  it "should emit 'done' with a reason when the timeout expires", (done) ->
    timer = new TimeoutEmitter()

    timer.on 'done', (reason) ->
      reason.should.equal 'timeout'
      done()

    timer.start 0


  it 'should be able to be stopped', (done) ->
    timer = new TimeoutEmitter()

    timer.on 'stopped', ->
      done()

    timer.on 'timeout', ->
      assert.fail no, yes, 'Timer timed out before stopped.'

    timer.start 10
    timer.stop()


  it "should emit 'done' on errors", (done) ->
    timer = new TimeoutEmitter()

    testMessage = 'Test-generated error'

    timer.on 'done', (reason) ->
      reason.should.equal 'error'
      done()

    # Suppress the error... unless it's not our own
    timer.on 'error', (err) ->
      err.message.should.equal testMessage

    timer.emit 'error', new Error testMessage

  it 'should stop the timer on errors', (done) ->
    timer = new TimeoutEmitter()

    testMessage = 'Test-generated error'

    # Suppress the error... unless it's not our own
    timer.on 'error', (err) ->
      err.message.should.equal testMessage

    timer.on 'stopped', ->
      done()

    timer.start 10
    timer.emit 'error', new Error testMessage


  it 'should be be able to emit arbitrary events', (done) ->
    timer = new TimeoutEmitter()

    timer.on 'fhqwhgads', ->
      done()

    timer.emit 'fhqwhgads'


  it 'should be able to be stopped on arbitrary events', (done) ->
    timer = new TimeoutEmitter()

    timer.stopOn 'yowzers'
    timer.on 'stopped', ->
      done()

    timer.start()
    timer.emit 'yowzers'

 describe '.start()', ->
    it 'should be a static method', ->
      TimeoutEmitter.should.itself.respondTo 'start'

    it 'should start immediately when called', (done) ->
      TimeoutEmitter.start(0).on 'timeout', ->
        done()

