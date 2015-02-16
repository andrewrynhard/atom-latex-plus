path = require 'path'

{$, View} = require 'atom-space-pen-views'
ErrorView = require './error-view'

module.exports =
class MainView extends View

  initialize: (params) ->
    @texliciousCore = params.texliciousCore

  destroy: ->
    @close()
    @remove()
    @detach()

  @content: ->
    @div class: 'texlicious', =>
      @div class: "panel", =>
        @div class: "panel-heading", =>
          @div class: 'pull-left', =>
            @span outlet: 'watchingStatus', class:'watch-text', id: 'watchIndicator', ''
          @div class: 'panel-heading-center', =>
            @span class: 'spin-box', id: 'compileIndicator'
        @div class: 'panel-body', =>
          @subview 'errorView', new ErrorView()

  updateErrorView: () ->
    @errorView.update @texliciousCore.getErrors()

  toggleCompileIndicator: ->
    if $('#compileIndicator').css('display') is 'block'
      $('#compileIndicator').css('display','none')
    else
      $('#compileIndicator').css('display','block')

  toggleWatchIndicator: (shouldIndicate) ->
    if shouldIndicate
      switch process.platform
        when 'win32'
          stopMessage = "Press 'ctrl-shift-S' to stop."
        when 'darwin'
          stopMessage = "Press 'ctrl-cmd-c' to stop."

      @watchingStatus.text("Watching: #{path.basename @texliciousCore.getTexFile()} - #{stopMessage}")
      $('#watchIndicator').css('display','block')
    else
      $('#watchIndicator').css('display','none')
