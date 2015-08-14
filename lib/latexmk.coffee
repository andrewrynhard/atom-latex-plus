{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'

module.exports =
class Latexmk
  make: (args, options, callback) ->
    command = "latexmk #{args.join(' ')}"
    proc = exec command, options, (error, stdout, stderr) ->
      if error?
        callback(error.code)
      else
        callback(0)
    proc
