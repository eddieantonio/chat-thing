###
The TimeoutEmitter class provide an EventEmitter wrapper around standard
timers.


NOTE: Should probably just use a promise-framework like `q`.
###

{EventEmitter} = require 'events'
util = require 'util'

TimeoutEmitter = module.exports = class TimeoutEmitter
  constructor: () ->
    EventEmitter.call this
    @isDoneWhen 'timeout'
    @once 'error', (err) =>
      @emit 'done', 'error'
      @stop() if @timer?
      # Re-emit the error.
      @emit 'error', err

util.inherits TimeoutEmitter, EventEmitter


###
Starts a timer
###
TimeoutEmitter::start = (expiration) ->
  if @timer?
    throw new Error 'Timer already started'

  @timer = setTimeout (=> @emit 'timeout'), expiration
  @emit 'started', @timer

  this


###
Stops the timer or interval
###
TimeoutEmitter::stop = () ->
  if not @timer?
    throw new Error 'Timer not started'

  clearTimeout @timer
  delete @timer
  @emit 'stopped'

  this

###
Stops the timer when the given event is emitted.
###
TimeoutEmitter::stopOn = (eventName) ->
  @once eventName, =>
    @stop()

  this

# Helpers

###
Signifies an event name in which the timeout should be considered 'done'.

(Should this even exist?)
###
TimeoutEmitter::isDoneWhen = (name) ->
  @once name, => @emit 'done', name

  this

###
Create a TimeoutEmitter and immediately start it.
###
TimeoutEmitter.start = (expiration) ->
  timer = new TimeoutEmitter().start expiration


