{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'

module.exports =
class Latexmk
  constructor: (params) ->
    @texliciousCore = params.texliciousCore

  make: (args, options, callback) ->
    command = "latexmk #{args.join(' ')}"
    proc = exec command, options, (error, stdout, stderr) ->
      if error?
        callback(error.code)
      else
        callback(0)
    proc

  args: (texFile) ->
    latexmkArgs = {
      default: '-interaction=nonstopmode -f -cd -pdf -file-line-error'
    }

    bibtexEnabled = atom.config.get('texlicious.bibtexEnabled')
    shellEscapeEnabled = atom.config.get('texlicious.shellEscapeEnabled')
    synctexEnabled = atom.config.get('texlicious.synctexEnabled')
    program = atom.config.get('texlicious.texFlavor')
    outputDirectory = atom.config.get('texlicious.outputDirectory')

    latexmkArgs.shellEscape = '-bibtex' if bibtexEnabled
    latexmkArgs.shellEscape = '-shell-escape' if shellEscapeEnabled
    latexmkArgs.synctex = '-synctex=1' if synctexEnabled
    latexmkArgs.program = "-#{program}" if program? and program isnt 'pdflatex'
    latexmkArgs.outdir = "-outdir=\"#{path.join(@texliciousCore.getTexProjectRoot(), outputDirectory)}\"" if outputDirectory isnt ''
    latexmkArgs.root = "\"#{texFile}\""

    latexmkArgs
