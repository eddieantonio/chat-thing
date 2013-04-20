###
A long-polling example.
###
require ['jquery'], ($) ->

  RETRY_TIME = 1000
  retries = 3

  displayMessages = (messages, displayList) ->
    $('<li>').text(message.msg).appendTo(displayList) for message in messages

  # Get the very last timestamp of the last request.
  getLastRequest = (response) ->
    last: response.last


  $ ->

    # First, get a bunch of selectors from the page.
    mainChat = $ '#main-chat'
    chatForm = mainChat.children('form').first()
    chatDisplay = mainChat.children('.display').first()

    # Make a function that will long-poll forever.
    longpoll = (lastRequest) ->
      lastRequest = lastRequest or {}

      $.ajax
        url: chatForm.attr 'action'
        type: 'GET'
        data: lastRequest
        dataType: 'json'
        success: (response) ->
         if response?.evts?
            displayMessages response.evts, chatDisplay
          newLastRequest =  getLastRequest response
          # Just request again.
          longpoll newLastRequest

        error: ->
          retries--
          if retries > 0
            console.error "Failed long-polling. Retrying in #{RETRY_TIME}ms"
            setTimeout( ->
              longpoll(lastRequest)
            , RETRY_TIME)
          else
            console.error "Failed long-polling. Out of retries."


    # Bind chatForm submission to do an AJAX POST.
    chatForm.submit (event) ->
      event.preventDefault()

      # Make the AJAX call to the chat server.
      $.ajax
        url: chatForm.attr 'action'
        type: chatForm.attr 'method'
        data: chatForm.serializeArray()
        success: (data, textStatus, xhr) ->
          chatForm.get(0).reset()
          location = xhr.getResponseHeader 'location'
          console.log "Created message #{location}"
        error: ->
          console.error "Something bad happened trying to POST the message."

    # Initiate the long-polling
    longpoll()


