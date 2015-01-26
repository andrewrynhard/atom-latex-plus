{$, View} = require 'atom-space-pen-views'

module.exports =
class WatchIndicator extends View
  @content: ->
    @div class: 'inline-block', =>
      @button click: 'stop',class: 'btn', "Stop"

  initialize: (params) ->
      @proc = params.proc

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
