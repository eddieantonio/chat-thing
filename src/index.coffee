###
Using Up to manage an Express web application.
###

up = require 'up'

master = require('http').Server().listen process.env.PORT or 3000

srv = up master, "#{__dirname}/server"

process.on 'SIGUSER2', ->
  srv.reload()

