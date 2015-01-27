# TODO: Handle the showing of views/indicators better. Currently the logView is
# not being nulled out when pushing 'close' in the view. The 'close' button only
# destroys the view, it does not make '@logView' null.
LogView = require './views/log-view'
BuildIndicator = require './indicators/build-indicator'
WatchIndicator = require './indicators/watch-indicator'

module.exports =
class Viewer
  showLogView: (params) ->
    return @logView if @logView?
    @logView = new LogView(params)

  showBuildIndicator: ->
    return @buildIndicator if @buildIndicator?
    @buildIndicator = new BuildIndicator()

  showWatchIndicator: (params) ->
    return @watchIndicator if @watchIndicator?
    @watchIndicator = new WatchIndicator(params)

  destroyLogView: ->
    @logView?.destroy()
    @logView = null

  destroyBuildIndicator: ->
    @buildIndicator?.destroy()
    @buildIndicator = null

  destroyWatchIndicator: ->
    @watchIndicator?.destroy()
    @watchIndicator = null
