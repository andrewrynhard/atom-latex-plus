#TODO: Listen for closing of watched file and stop watching when it happens.
{CompositeDisposable} = require 'atom'

module.exports =
class Watcher
  compileTimeout: null

  constructor: (params) ->
    @texliciousCore = params.texliciousCore
    @mainView = params.mainView

  cancelCompile: ->
    clearTimeout(@compileTimeout) if @compileTimeout

  scheduleCompile: ->
    @cancelCompile()

    stoppedChangingCallback = =>
      @compileTimeout = null

    @compileTimeout = setTimeout(@texliciousCore.compile.bind(@texliciousCore), atom.config.get('texlicious.watchDelay') * 1000)

  startWatching: ->
    @watch()

    @onDidChangeActivePaneItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      panel = atom.workspace.getActivePaneItem()
      unless panel is @texliciousCore.getTexEditor() and @texliciousCore.isWatchingAndWatched()
        @pauseWatching()
      else
        @texliciousCore.setWatchingAndWatched(true)
        @watch()

    @mainView.toggleWatchIndicator(true)

  pauseWatching: ->
    if @bufferOnDidChangeSubscription?
      @bufferOnDidChangeSubscription.dispose()
      @bufferOnDidChangeSubscription = null
      console.log '... paused watching.'

  stopWatching: ->
    @texliciousCore.setWatchingAndWatched(false)

    if @onDidChangeActivePaneItemSubscription?
      @onDidChangeActivePaneItemSubscription.dispose()
      @onDidChangeActivePaneItemSubscription = null

    if @bufferOnDidChangeSubscription?
      @bufferOnDidChangeSubscription.dispose()
      @bufferOnDidChangeSubscription = null

    @mainView.toggleWatchIndicator(false)
    console.log '... stopped watching.'

  watch: ->
    @texliciousCore.compile()

    buffer = @texliciousCore.getTexEditor().buffer
    @bufferOnDidChangeSubscription = new CompositeDisposable
    @bufferOnDidChangeSubscription.add buffer.onDidChange =>
      @scheduleCompile()

    console.log 'Watching ...'
