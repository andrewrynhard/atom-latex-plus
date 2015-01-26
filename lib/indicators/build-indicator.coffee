{$, View} = require 'atom-space-pen-views'

module.exports =
class BuildIndicator extends View
  @content: ->
    @div class: 'inline-block', =>
      @span class: 'spin-box', =>

  destroy: ->
    @remove()
