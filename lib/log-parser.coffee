fs = require 'fs'
path = require 'path'

errorFileLineMessagePattern = ///
  ^(\.\/|[A-D:])(.*\.tex):(\d*):\s(.*)
  ///

module.exports =
class LogParser
  constructor: (params) ->
    @texliciousCore = params.texliciousCore

  resolveLogFile: (texFile) ->
    outputDirectory = atom.config.get('texlicious.outputDirectory') ? ''
    logFile = path.basename(texFile).split('.')[0] + '.log'
    logFilePath = path.join(@texliciousCore.getTexProjectRoot(),
                            outputDirectory, logFile)

  parseLogFile: (texFile, callback) ->
    errors = []
    fs.readFile @resolveLogFile(texFile), (err, data) ->
      if(err)
        return err

      bufferString = data.toString().split('\n').forEach (line) ->
        logErrorLine = line.match(errorFileLineMessagePattern)

        unless logErrorLine?
          return

        errorInfo = line.match(errorFileLineMessagePattern)
        error = {
          file:     errorInfo[2]
          line:     errorInfo[3]
          message:  errorInfo[4]
        }

        errors.push error
      callback(errors)
