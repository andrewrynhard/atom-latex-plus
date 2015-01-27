{$, View} = require 'atom-space-pen-views'

module.exports =
class WatchIndicator extends View
  @content: ->
    @div tabIndex: -1, class: 'panel log-panel panel-bottom', =>
      @button click: 'stop', class: 'btn', =>
        @span 'Stop Watching'
      @span class: 'spin-box'

  initialize: (params) ->
    @proc = params.proc
    atom.workspace.addBottomPanel
      item: this

  destroy: ->
    @remove()

  stop: ->
    try
      process.kill(@proc.pid, 'SIGINT')
    catch e
      if e.code is 'ESRCH'
        # TODO: Handle error.
      else
        throw (e)
