###
Grabs underscore from a cdnjs and incorporates it into RequireJS.

To use underscore with Require, instead of requiring 'underscore', require this
script.
###

requirejs.config
  shim:
    underscore:
      exports: '_'
  paths:
    underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min'

# Simply return underscore.
define ['underscore'], (_) ->
  _

