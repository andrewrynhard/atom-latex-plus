fs = require 'fs-plus'
path = require 'path'

module.exports =
class Logger
  readLogFile: (texFilePath) ->
    logFile = @resolveLogFilePath(texFilePath)
    logContents = fs.readFileSync(logFile)

  resolveLogFilePath: (texFilePath) ->
    outputDirectory = atom.config.get('latex.outputDirectory') ? ''
    currentDirectory = path.dirname(texFilePath)
    fileName = path.basename(texFilePath).replace(/\.tex|\.lhs$/, '.log')
    logFilePath = path.join(currentDirectory, outputDirectory, fileName)
