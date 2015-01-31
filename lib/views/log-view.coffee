fs = require 'fs'
path = require 'path'

{ScrollView} = require 'atom-space-pen-views'

module.exports =
class LogView extends ScrollView

  @content: ->
    @div class: 'log-panel text-highlight',id: 'log-view-div', =>
      @span outlet: 'logContents',

  readLogFile: (texFile) ->
    logFile = @resolveLogFile(texFile)
    try
      logContents = fs.readFileSync(logFile)
    catch e
      if e.code is 'ENOENT'
        logContents = e
      else
        logContents = e
        throw (e)

    logContents

  resolveLogFile: (texFile) ->
    outputDirectory = atom.config.get('texlicious.outputDirectory') ? ''
    fileName = path.basename(texFile).replace(/\.tex|\.lhs$/, '.log')
    logFilePath = path.join(atom.project.getRootDirectory().getPath(),
      outputDirectory, fileName)

  updateLogView: (texFile) ->
    logContents = @readLogFile(texFile)
    @logContents.text(logContents)
