{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'

module.exports =
class Latexmk
  constructor: ->

  make: (args, options, callback) ->
    latexmkpl = path.join(atom.packages.resolvePackagePath('texlicious'),'/vendor/latexmk.pl')
    escapedArgs = (item.replace(' ', '\\ ') for item in args)
    command = "#{latexmkpl} #{escapedArgs.join(' ')}"
    proc = exec command, options, (error, stdout, stderr) ->
      if error?
        console.log error
        callback(error.code)
      else
        callback(0)
    proc

  args: (texFile) ->
    args = [
      '-interaction=nonstopmode'
      '-f'
      '-cd'
      '-pdf'
      '-synctex=1'
      '-file-line-error'
    ]

    shellEscapeEnabled = atom.config.get('texlicious.shellEscapeEnabled')
    program = atom.config.get('texlicious.texFlavor')
    outputDirectory = atom.config.get('texlicious.outputDirectory')

    args.push('-shell-escape') if shellEscapeEnabled
    args.push("-#{program}") if program? and program isnt 'pdflatex'
    args.push("-outdir=#{path.join(path.dirname(texFile), outputDirectory)}") if outputDirectory?
    args.push("#{texFile}")

    args
