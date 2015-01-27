{$, View} = require 'atom-space-pen-views'

module.exports =
class BuildIndicator extends View
  @content: ->
    @div class: 'inline-block', =>
      @span class: 'spin-box'

  initialize: ->
    atom.workspace.addBottomPanel
      item: this

  destroy: ->
    @remove()
