fs = require 'fs'
path = require 'path'

{ScrollView} = require 'atom-space-pen-views'
LogTool = require '../log-tool'

module.exports =
class LogView extends ScrollView

  @content: ->
    @div class: 'log-panel text-highlight',id: 'log-view-div', =>
      @span outlet: 'logContents',

  initialize: ->
    @logTool = new LogTool()
  updateLogView: (texFile) ->
    logContents = @logTool.readLogFile(texFile)
    @logContents.text(logContents)
