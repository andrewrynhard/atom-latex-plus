{$, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
TeXlicious = require '../main'
LogView = require './log-view'

module.exports =
class TeXliciousView extends View

  initialize: (params) ->
    @editor = atom.workspace.getActiveTextEditor()
    @texlicious = params.texlicious

  destroy: ->
    @close()
    @remove()
    @detach()

  @content: ->
    @div class: 'texlicious', =>
      @div class: "panel", =>
        @div class: "panel-heading", =>
          @div class: 'pull-left', =>
            @button outlet: 'toggleLogButton', class:'btn panel-heading-btn', click: 'toggleLogView', 'Show Log'
          @div class: 'pull-left', =>
            @button outlet: 'toggleWatchButton', class:'btn panel-heading-btn watch-btn', click: 'stopWatching', id: 'watchButton', ''
          @div class: 'panel-heading-center', =>
            @span class: 'spin-box', id: 'compileIndicator'
        @div class: 'panel-body', =>
          @subview 'logView', new LogView()

  #TODO: Show the log file without having to error first.
  showLog: (texFile) ->
    @logView.updateLogView(texFile)
    if $('#log-view-div').css('display') is 'none'
      @toggleLogView()

  toggleLogView: ->
    if $('#log-view-div').css('display') is 'block'
      $('#log-view-div').css('display','none')
      @toggleLogButton.text('Show Log')
    else
      $('#log-view-div').css('display','block')
      @toggleLogButton.text('Hide Log')

  toggleCompileIndicator: ->
    if $('#compileIndicator').css('display') is 'block'
      $('#compileIndicator').css('display','none')
    else
      $('#compileIndicator').css('display','block')

  toggleWatchIndicator: ->
    if $('#watchButton').css('display') is 'none'
      $('#watchButton').css('display','block')
      @toggleWatchButton.text('Stop Watching')
    else
      $('#watchButton').css('display','none')

  stoppedChangingTimeout: null

  cancelStoppedChangingTimeout: ->
    clearTimeout(@stoppedChangingTimeout) if @stoppedChangingTimeout

  scheduleWatchEvent: ->
    @cancelStoppedChangingTimeout()
    stoppedChangingCallback = =>
      @stoppedChangingTimeout = null
    @stoppedChangingTimeout = setTimeout(@texlicious.compile.bind(@texlicious), atom.config.get('texlicious.watchDelay') * 1000)

  startWatching: ->
    console.log 'Watching ...'
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      buffer = editor.getBuffer()
      bufferChangedSubscription = buffer.onDidChange =>
        @scheduleWatchEvent()
      @subscriptions.add(bufferChangedSubscription)
    @toggleWatchIndicator()

  stopWatching: ->
    console.log '... stopped watching.'
    @subscriptions.dispose()
    @subscriptions = null
    @toggleWatchIndicator()
