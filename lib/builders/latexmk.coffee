child_process = require 'child_process'
fs = require 'fs-plus'
path = require 'path'
Builder = require '../builder'

module.exports =
class LatexmkBuilder extends Builder
  # TODO: Add support for killing the exec process.
  # TODO: kill all child processes on exit.
  build: (args, options, callback) ->
    escapedArgs = (item.replace(' ', '\\ ') for item in args)
    command = "latexmk #{escapedArgs.join(' ')}"
    proc = child_process.exec command, options, (error, stdout, stderr) ->
      if error?
        callback(error.code)
      else
        callback(0)
    proc

  watch: (args, options, callback) ->
    command = 'latexmk'
    args.push('-silent','-pvc')
    proc = child_process.spawn command, args, options
    proc.stdout.on 'data', (data) ->
      console.log('stdout: ' + data.toString())
      callback()
    proc.stderr.on 'data', (data) ->
      console.log('stderr: ' + data.toString())
      callback()
    proc.on 'exit', (statusCode) ->
      callback(statusCode)

  constructArgs: (filePath) ->
    args = [
      '-interaction=nonstopmode'
      '-f'
      '-cd'
      '-pdf'
      '-synctex=1'
      '-file-line-error'
    ]

    enableShellEscape = atom.config.get('latex.enableShellEscape')
    customEngine = atom.config.get('latex.customEngine')
    engine = atom.config.get('latex.engine')

    args.push('-shell-escape') if enableShellEscape?

    if customEngine
      args.push("-pdflatex=\"#{customEngine}\"")
    else if engine? and engine isnt 'pdflatex'
      args.push("-#{engine}")

    if outdir = atom.config.get('latex.outputDirectory')
      dir = path.dirname(filePath)
      outdir = path.join(dir, outdir)
      args.push("-outdir=#{outdir}")

    args.push("#{filePath}")

    args
