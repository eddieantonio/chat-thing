# ** Cakefile Template** is a Template for a common Cakefile that you may
# use in a CoffeeScript Node.js project.
#
# Based on https://github.com/twilson63/cakefile-template
#
# Heavily modified by Eddie Antonio Santos
#

WEB =
  src: 'websrc'
  out: 'public/js'
  flags: ['--map', '--bare']
SRV =
  src: 'src'
  out: 'lib'

fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

try
  which = require('which').sync
catch err
  if process.platform.match(/^win/)?
    console.log 'WARNING: the which module is required for windows\ntry: npm install which'
  which = null

# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
reset = '\x1b[0m'
red = '\x1b[0;31m'



# Tasks

task 'docs', 'Generate documentation', ->
  notImplemented -> docco()

task 'build', 'Compile all sources', ->
  multiInvoke 'build:web', 'build:srv'

task 'build:web', 'Compile web souces', ->
  build WEB

task 'build:srv', 'Compile server-side souces', ->
  build SRV

task 'watch', 'Watch and compile all coffee sources', ->
  multiInvoke 'watch:web', 'watch:srv'

task 'watch:srv', 'Watch and compile web sources', ->
  build SRV, yes

task 'watch:web', 'Watch and compile server-side sources', ->
  build WEB, yes

option '-r', '--reporter [MOCHA_REPORTER]', "set mocha's test reporter"

task 'test', 'Run tests', (options) ->
  mochaOpts =
    reporter: options.reporter or 'spec'
  mocha mochaOpts

task 'clean', 'clean generated files', ->
  notImplemented ->
    clean


# Internal Functions

# ## *walk* 
#
# **given** string as dir which represents a directory in relation to local directory
# **and** callback as done in the form of (err, results)
# **then** recurse through directory returning an array of files
#
# Examples
#
# ``` coffeescript
# walk 'src', (err, results) -> console.log results
# ```
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending

###
# Multi-invoke
#
# Invokes several tasks at once.
###
multiInvoke = () ->
  for arg in arguments
    (->
      # HACK! Gotta capture 'arg' in a closure.
      t = arg
      setTimeout (-> invoke t), 0)()

# ## *log* 
# 
# **given** string as a message
# **and** string as a color
# **and** optional string as an explanation
# **then** builds a statement and logs to console.
# 
log = (message, explanation, color=bold) ->
  console.log "#{color}#{message}#{reset} #{explanation or '' }"

# ## *launch*
#
# **given** string as a cmd
# **and** optional array and option flags
# **and** optional callback
# **then** spawn cmd with options
# **and** pipe to process stdout and stderr respectively
# **and** on child process exit emit callback if set and status is 0
launch = (cmd, args=[], callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, args,
    stdio: 'inherit'

  log cmd, args.join ' '

  app.on 'exit', (status) ->
    callback?() if status is 0

# ## *build*
#
# **given** optional boolean as watch
# **and** optional function as callback
# **then** invoke launch passing coffee command
# **and** defaulted options to compile src to lib
build = (argset, watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = no

  {out, src} = argset
  options = if argset.flags? then argset.flags else []
  options = options.concat '--compile', '--output', out, src
  options.unshift '--watch' if watch

  launch 'coffee', options, callback

# ## *unlinkIfCoffeeFile*
#
# **given** string as file
# **and** file ends in '.coffee'
# **then** convert '.coffee' to '.js'
# **and** remove the result
unlinkIfCoffeeFile = (file) ->
  if file.match /\.coffee$/
    fs.unlink file.replace(/\.coffee$/, '.js')
    true
  else false

# ## *clean*
#
# **given** optional function as callback
# **then** loop through files variable
# **and** call unlinkIfCoffeeFile on each
clean = (callback) ->
  try
    for file in files
      unless unlinkIfCoffeeFile file
        walk file, (err, results) ->
          for f in results
            unlinkIfCoffeeFile f

    callback?()
  catch err

# Just logs notImplemented and returns false.
notImplemented = ->
  log 'ERROR', 'task not implemented', red
  false


# ## *mocha*
#
# **given** optional array of option flags
# **and** optional function as callback
# **then** invoke launch passing mocha command
mocha = (opts, callback) ->
  if typeof options is 'function'
    callback = opts
    opts = {}

  # Add coffee directive.
  argv = ['--compilers', 'coffee:coffee-script']
  argv = argv.concat ['--reporter', opts.reporter] if opts.reporter?

  launch 'mocha', argv, callback

# ## *docco*
#
# **given** optional function as callback
# **then** invoke launch passing docco command
docco = (callback) ->
  walk 'src', (err, files) -> launch 'docco', files, callback

