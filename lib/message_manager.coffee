fs = require 'fs'
path = require 'path'
{MessagePanelView, LineMessageView, PlainMessageView} = require('atom-message-panel')

module.exports =
class MessageView

  constructor: ->
    @messagepanel = new MessagePanelView({title: 'Errors:'}) unless @messagepanel?

  update: (errors) ->
    @messagepanel.clear()
    if errors == null
      @messagepanel.close()
      return

    for error in errors
      @messagepanel.add(new LineMessageView({file: error.file , line: error.line, character: 0, message: error.message}))

    @messagepanel.attach()

  destroy: =>
    @messagepanel?.remove()
    @messagepanel = null
