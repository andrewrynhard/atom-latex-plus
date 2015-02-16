fs = require 'fs'
path = require 'path'

errorLinePattern = ///
  ^l\.(\d*)
  ///

errorFileLineMessagePattern = ///
  ^\.\/(.*\.tex):(\d*):\s(.*)
  ///

module.exports =
class LogTool
  resolveLogFile: (texFile) ->
    outputDirectory = atom.config.get('texlicious.outputDirectory') ? ''
    logFile = path.basename(texFile).split('.')[0] + '.log'
    logFilePath = path.join(atom.project.getRootDirectory().getPath(),
      outputDirectory, logFile)

  readLogFile: (texFile) ->
    logFile = @resolveLogFile(texFile)
    try
      logContents = fs.readFileSync(logFile)
    catch e
      if e.code is 'ENOENT'
        atom.notifications.addError(e.toString(), dismissable: true)
      else
        atom.notifications.addError(e.toString(), dismissable: true)
        throw (e)

    logContents

  getErrors: (texFile) ->
    console.log "Parsing log file ..."

    errors = []

    logFile = @resolveLogFile(texFile)
    fs.readFileSync(logFile).toString().split('\n').forEach (line) ->
      logErrorLine = line.match(errorFileLineMessagePattern)

      unless logErrorLine?
        return

      errorInfo = line.match(errorFileLineMessagePattern)
      error = {
        file:     errorInfo[1]
        line:     errorInfo[2]
        message:  errorInfo[3]
      }

      errors.push error

    errors
