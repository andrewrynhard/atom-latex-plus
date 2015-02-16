{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'

module.exports =
class Latexmk
  constructor: ->

  make: (args, options, callback) ->
    latexmkpl = path.join(atom.packages.resolvePackagePath('texlicious'),'/vendor/latexmk.pl')
    command = "perl #{latexmkpl} #{args.join(' ')}"
    proc = exec command, options, (error, stdout, stderr) ->
      if error?
        console.log error.message
        callback(error.code)
      else
        callback(0)
    proc

  args: (texFile) ->
    latexmkArgs = {
      default: '-interaction=nonstopmode -f -cd -pdf -file-line-error'
    }

    shellEscapeEnabled = atom.config.get('texlicious.shellEscapeEnabled')
    synctexEnabled = atom.config.get('texlicious.synctexEnabled')
    program = atom.config.get('texlicious.texFlavor')
    outputDirectory = atom.config.get('texlicious.outputDirectory')

    latexmkArgs.shellEscape = '-shell-escape' if shellEscapeEnabled
    latexmkArgs.synctex = '-synctex=1' if synctexEnabled
    latexmkArgs.program = "-#{program}" if program? and program isnt 'pdflatex'
    latexmkArgs.outdir = "-outdir=\"#{path.join(atom.project.getRootDirectory().getPath(), outputDirectory)}\"" if outputDirectory isnt ''
    latexmkArgs.root = "\"#{texFile}\""

    latexmkArgs
