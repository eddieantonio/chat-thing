{exec} = require 'child_process'

SRCDIR = 'src'
DESTDIR = 'lib'

task 'build', 'Build all Coffescript files', ->
  exec "coffee --compile --output #{DESTDIR} #{SRCDIR}", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

task 'watch', 'Watch all Coffescript files', ->
  exec "coffee --compile --watch --output #{DESTDIR} #{SRCDIR}", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

