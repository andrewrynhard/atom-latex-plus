{exec, spawn} = require 'child_process'
child_process = require 'child_process'
fs = require 'fs-plus'
path = require 'path'
Builder = require '../builder'

module.exports =
class Latexmk extends Builder
  build: (args, options, callback) ->
    escapedArgs = (item.replace(' ', '\\ ') for item in args)
    command = "latexmk #{escapedArgs.join(' ')}"
    proc = exec command, options, (error, stdout, stderr) ->
      if error?
        callback(error.code)
      else
        callback(0)
    proc

  watch: (args, options, @indicator, callback) ->
    command = 'latexmk'
    proc = spawn command, args, options
    @indicator.showWatchIndicator({proc: proc})
    proc.on 'exit', (exitCode) -> callback(exitCode)
    process.on 'exit', () -> proc.kill()

  latexmkArgs: (texFile, shouldWatch) ->
    args = [
      '-interaction=nonstopmode'
      '-f'
      '-cd'
      '-pdf'
      '-synctex=1'
      '-file-line-error'
    ]

    enableShellEscape = atom.config.get('texlicious.enableShellEscape')
    engine = atom.config.get('texlicious.engine')
    outputDirectory = atom.config.get('texlicious.outputDirectory')
    args.push('-shell-escape') if enableShellEscape?
    args.push("-#{engine}")
    if shouldWatch
      args.push('-silent','-pvc','-view=none')
    args.push("-outdir=#{path.join(path.dirname(texFile), outputDirectory)}") if outputDirectory?
    args.push("#{texFile}")

    args
