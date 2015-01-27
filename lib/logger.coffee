fs = require 'fs-plus'
path = require 'path'

module.exports =
class Logger
  readLogFile: (texFilePath) ->
    logFile = @resolveLogFilePath(texFilePath)
    try
      logContents = fs.readFileSync(logFile)
    catch e
      if e.code is 'ENOENT'
        logContents = e
      else
        logContents = e
        throw (e)

    logContents

  resolveLogFilePath: (texFilePath) ->
    outputDirectory = atom.config.get('texlicious.outputDirectory') ? ''
    currentDirectory = path.dirname(texFilePath)
    fileName = path.basename(texFilePath).replace(/\.tex|\.lhs$/, '.log')
    logFilePath = path.join(currentDirectory, outputDirectory, fileName)
