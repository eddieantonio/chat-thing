###
Express server setup
###

express = require 'express'
path = require 'path'

messages = require './routes/messages'


# Boilerplate up/express setup.
app = express()
server = app.listen()

publicFolder = path.join __dirname, '..', 'public'
DEVELOPMENT = process.env.NODE_ENV is 'development'

# Set up template locals.
app.locals
  NAME: 'Keelhaul'

# Set up middleware.
app.use express.logger('dev')
app.use express.favicon()
app.set 'views', path.join __dirname, '..', 'views'
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.static(publicFolder)

# Routes!
app.get '/', (req, res) ->
  res.render 'index'

# Set up routes for getting a message
app.post '/message', messages.post
app.get '/message', messages.longpoll
app.get '/message/:id', messages.getMessage

# For debugging client-side CoffeeScript
#app.use express.static(__dirname + '/websrc/') if DEVELOPMENT
if DEVELOPMENT
  app.get '/websrc/:file', (req, res) ->
    {file} = req.params
    res.sendfile "./websrc/#{file}"



# Export for `up` to use.
module.exports = server

