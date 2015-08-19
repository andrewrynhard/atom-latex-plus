fs = require 'fs'
path = require 'path'

errorFileLineMessagePattern = ///
  ^(\.\/|[A-D:])(.*\.tex):(\d*):\s(.*)
  ///

module.exports =
class LogParser
  parseLogFile: (rootPath, log, callback) ->
    errors = []
    fs.readFile log, (err, data) ->
      if(err)
        return err

      bufferString = data.toString().split('\n').forEach (line) ->
        logErrorLine = line.match(errorFileLineMessagePattern)

        unless logErrorLine?
          return

        errorInfo = line.match(errorFileLineMessagePattern)
        error = {
          file:     path.join(rootPath, path.normalize(errorInfo[2]))
          line:     errorInfo[3]
          message:  errorInfo[4]
        }

        errors.push error
      callback(errors)
