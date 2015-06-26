fs = require 'fs'
path = require 'path'

{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ErrorView extends ScrollView

  #TODO: Indicate number of errors.
  #TODO: Resizable.
  @content: ->
    @div class: 'error-panel text-highlight',id: 'error-view-div', =>
      @div outlet: 'errorContents',

  update: (errors) ->
    if errors is null
      $('#error-view-div').css('display','none')
      @errorContents.html('')
      return

    html = ''
    for error in errors
      line = '<span>File: ' + error.file + ' Line: ' + error.line + ' Error: ' + error.message + '</span>'
      html = html + line + '<br/>'

    @errorContents.html(html)
    $('#error-view-div').css('display','block')

  destroy: ->
    @remove()
