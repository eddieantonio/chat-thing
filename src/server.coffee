###
Express server setup.

Exports a server for use with Up.
###

express = require 'express'
path = require 'path'

messages = require './routes/messages'



# Boilerplate Up/Express setup.
app = express()
server = app.listen()

# Some constants.
publicFolder = path.join __dirname, '..', 'public'

# Set up template locals.
app.locals
  NAME: 'Chat Thing'

# Set up middleware.
app.set 'views', path.join __dirname, '..', 'views'
app.set 'view engine', 'jade'
app.use express.logger('dev')
app.use express.cookieParser()
app.use express.cookieSession({secret: 'i dunno lol'})
app.use express.favicon()
app.use express.bodyParser()
app.use express.csrf()
app.use app.router
app.use express.static(publicFolder)

# Get Jade to pretty-print the rendered HTML, but only for development!
if app.get('env') is 'development'
  app.locals.pretty = true



# Route helper middleware.
attachCsrf = (req, res, next) ->
  res.locals.csrfToken = req.session._csrf
  next()



# Routes!
app.get '/', attachCsrf, (req, res) ->
  res.render 'index'

# Set up routes for getting a message
app.post '/message', messages.post
app.get '/message', messages.longpoll
app.get '/message/:id', messages.getMessage

# For debugging client-side CoffeeScript
if app.get('env') is 'development'
  app.get '/websrc/:file', (req, res) ->
    {file} = req.params
    res.sendfile "./websrc/#{file}"

# Export for `up` to use.
module.exports = server

