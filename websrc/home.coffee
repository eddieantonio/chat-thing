###
A long-polling example.
###
require ['jquery', 'underscore-shim'], ($, _) ->

  RETRY_TIME = 5000
  retries = 3

  # This will be defined on document ready, when the template can be parsed
  renderMessage = undefined

  # Displays messages from the event div in the given jQuery.
  displayMessages = (events, displayList) ->
    displayList.append(
      renderMessage
        author: event.from
        messageText: event.msg
    ) for event in events when event.type is 'msg'

  # Get the very last timestamp of the last request.
  getLastRequest = (response) ->
    last: response.last

  $ ->

    # First, get a bunch of selectors from the page.
    mainChat = $ '#main-chat'
    chatForm = mainChat.find('form').first()
    chatDisplay = mainChat.children('.display').first()

    # This is really ugly, but no matter.
    renderMessage = _.template $('#_t-message-body').html()

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
          newLastRequest = getLastRequest response
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
          # Should display something like 'Could not deliver message...'
          console.error "Something bad happened trying to POST the message."

    # Initiate the long-polling
    longpoll()

