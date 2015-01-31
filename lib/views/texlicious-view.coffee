{$, View} = require 'atom-space-pen-views'
LogView = require './log-view'

module.exports =
class TeXliciousView extends View


  @content: ->
    @div class: 'texlicious', =>
      @div class: "panel", =>
        @div class: "panel-heading", =>
          @div class: 'pull-left', =>
            @button outlet:'toggleButton', class:'btn log-btn', click: 'toggleLogView', 'Show Log'
          @div class: 'panel-heading-center', =>
            @span class: 'spin-box', id: 'compileIndicator'
        @div class: 'panel-body', =>
          @subview 'logView', new LogView()

  initialize: ->

  destroy: ->
    @close()
    @remove()
    @detach()

  #TODO: Show the log file without having to error first.
  showLog: (texFile) ->
    @logView.updateLogView(texFile)
    if $('#log-view-div').css('display') is 'none'
      @toggleLogView()

  toggleLogView: ->
    if $('#log-view-div').css('display') is 'block'
      $('#log-view-div').css('display','none')
      @toggleButton.text('Show Log')
    else
      $('#log-view-div').css('display','block')
      @toggleButton.text('Hide Log')

  toggleCompileIndicator: ->
    if $('#compileIndicator').css('display') is 'block'
      $('#compileIndicator').css('display','none')
    else
      $('#compileIndicator').css('display','block')
