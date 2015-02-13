fs = require 'fs'
path = require 'path'

errorLinePattern = ///
  ^l\.(\d*)
  ///

errorFileLinePattern = ///
  ^\.\/(.*\.tex):(\d*)
  ///

module.exports =
class LogTool
  parseLogFile: (texFile) ->
    console.log "Parsing log file ..."

    errors = []

    logFile = @resolveLogFile(texFile)

    fs.readFileSync(logFile).toString().split('\n').forEach (line) ->
      logErrorLine = line.match(errorFileLinePattern)

      unless logErrorLine?
        return

      errorInfo = line.match(errorFileLinePattern)
      errorFile = errorInfo[1]
      errorLine = errorInfo[2]

      unless errors[errorLine]?
        errors[errorLine] = errorFile

    errors

  resolveLogFile: (texFile) ->
    outputDirectory = atom.config.get('texlicious.outputDirectory') ? ''
    fileName = path.basename(texFile).replace(/\.tex|\.lhs$/, '.log')
    logFilePath = path.join(atom.project.getRootDirectory().getPath(),
      outputDirectory, fileName)
