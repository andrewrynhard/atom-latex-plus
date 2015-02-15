path = require 'path'

{$, View} = require 'atom-space-pen-views'
{CompositeDisposable,Disposable} = require 'atom'
TeXlicious = require '../main'
LogView = require './log-view'

module.exports =
class TeXliciousView extends View

  initialize: (params) ->
    @texlicious = params.texlicious
    @watching = false

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
            @span outlet: 'watchingTextIndicator', class:'watch-text', id: 'watchingText', ''
          @div class: 'panel-heading-center', =>
            @span class: 'spin-box', id: 'compileIndicator'
        @div class: 'panel-body', =>
          @subview 'logView', new LogView()

  setTexFile: (texFile) ->
    @texFile = texFile

  setWatchFile: (watchFile) ->
    @watchFile = watchFile

  showLog: ->
    @logView.updateLogView(@texFile)
    if $('#log-view-div').css('display') is 'none'
      @toggleLogView()

  updateLog: ->
    @logView.updateLogView(@texFile)

  toggleLogView: ->
    if $('#log-view-div').css('display') is 'block'
      $('#log-view-div').css('display','none')
      @toggleLogButton.text('Show Log')
    else
      @updateLog()
      $('#log-view-div').css('display','block')
      @toggleLogButton.text('Hide Log')

  toggleCompileIndicator: ->
    if $('#compileIndicator').css('display') is 'block'
      $('#compileIndicator').css('display','none')
    else
      $('#compileIndicator').css('display','block')

  toggleWatchIndicator: ->
    if $('#watchingText').css('display') is 'none'
      $('#watchingText').css('display','block')
      @watchingTextIndicator.text("Watching: #{path.basename @texlicious.texFile}")
    else
      $('#watchingText').css('display','none')

  stoppedChangingTimeout: null

  cancelStoppedChangingTimeout: ->
    clearTimeout(@stoppedChangingTimeout) if @stoppedChangingTimeout

  startWatchEvents: ->
    console.log @texlicious.texPanel
    @toggleWatchIndicator()
    @startWatching()

    @watchEventsSubscription = new CompositeDisposable

    @watchEventsSubscription.add atom.workspace.onDidChangeActivePaneItem =>
      panel = atom.workspace.getActivePaneItem()
      unless panel is @texlicious.texPanel and @texlicious.texPanel.watching
        @pauseWatching()
      else
        @startWatching()

  scheduleWatchEvent: ->
    @cancelStoppedChangingTimeout()
    stoppedChangingCallback = =>
      @stoppedChangingTimeout = null
    @stoppedChangingTimeout = setTimeout(@texlicious.compile.bind(@texlicious), atom.config.get('texlicious.watchDelay') * 1000)

  startWatching: ->
    console.log 'Watching ...'
    @texlicious.compile()

    @watchingSubscriptions = new CompositeDisposable

    @bufferChangedSubscription = @texlicious.buffer.onDidChange =>
      @scheduleWatchEvent()

    @watchingSubscriptions.add(@bufferChangedSubscription)

  pauseWatching: ->
    if @watchingSubscriptions?
      @watchingSubscriptions.dispose()
      @watchingSubscriptions = null
      console.log '... paused watching.'

  stopWatching: ->
    console.log atom.workspace.getPanes()
    console.log '... stopped watching.'
    @texlicious.texPanel.watching = false
    @watching = false
    if @watchEventsSubscription?
      @watchEventsSubscription.dispose()
      @watchEventsSubscription = null
    if @watchingSubscriptions?
      @watchingSubscriptions.dispose()
      @watchingSubscriptions = null

    @toggleWatchIndicator()
