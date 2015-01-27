{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class LogView extends ScrollView
  @content: (params) ->
    @div tabIndex: -1, class: 'panel log-panel panel-bottom', style: 'overflow: scroll', =>
      @div class: 'btn-group', =>
        @button click: 'destroy', class: 'btn', =>
          @span class: "icon icon-x"
          @span 'Close'
      @div class: 'panel log-panel-body', =>
        @div class: 'text-highlight', "#{params.logContents}"

  initialize: ->
    super
    atom.workspace.addBottomPanel
      item: this

  destroy: ->
    @remove()
