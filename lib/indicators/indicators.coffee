ErrorIndicator = require './error-indicator'
BuildIndicator = require './build-indicator'
WatchIndicator = require './watch-indicator'

module.exports =
class Indicators
  showErrorIndicator: (params) ->
    return @errorIndicator if @errorIndicator?
    @errorIndicator = new ErrorIndicator(params)
    atom.workspaceView.appendToBottom(@errorIndicator)
    @errorIndicator

  showBuildIndicator: ->
    return @buildIndicator if @buildIndicator?

    @buildIndicator = new BuildIndicator()
    atom.workspaceView.statusBar?.prependRight(@buildIndicator)
    @buildIndicator

  showWatchIndicator: (params) ->
    return @watchIndicator if @watchIndicator?

    @watchIndicator = new WatchIndicator(params)
    atom.workspaceView.statusBar?.prependRight(@watchIndicator)
    @watchIndicator

  destroyErrorIndicator: ->
    @errorIndicator?.destroy()
    @errorIndicator = null

  destroyBuildIndicator: ->
    @buildIndicator?.destroy()
    @buildIndicator = null

  destroyWatchIndicator: ->
    @watchIndicator?.destroy()
    @watchIndicator = null
