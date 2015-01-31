# TODO: Logger for https://atom.io/docs/api/v0.176.0/Atom#instance-inDevMode.

fs = require 'fs'
path = require 'path'
extend = require 'extend'

ProcessManager = require './process-manager'
Latexmk = require './latexmk'
MagicComments = require './magic-comments'
TeXliciousView = require './views/texlicious-view'

class TeXlicious
  config:
    texPath:
      title: 'TeX Path'
      description: "Location of your TeX installation bin."
      type: 'string'
      default: ''
      order: 1
    texFlavor:
      title: 'TeX Flavor'
      description: 'Default program used to compile a TeX file.'
      type: 'string'
      default: 'pdflatex'
      enum: ['lualatex', 'pdflatex', 'xelatex']
      order: 2
    texInputs:
      title: 'TeX Packages'
      description: "Location of your custom TeX packages directory."
      type: 'string'
      default: ''
      order: 3
    outputDirectory:
      title: 'Output Directory'
      description: 'Output directory relative to the project root.'
      type: 'string'
      default: ''
      order: 4
    shellEscapeEnabled:
      title: 'Shell Escape'
      type: 'boolean'
      default: false
      order: 5
    watchDelay:
      title: 'Watch Delay'
      description: 'Time in seconds to wait until compiling when in watch mode.'
      type: 'integer'
      default: 5
      order: 6

  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @processManager = new ProcessManager()
    @latexmk = new Latexmk()
    @magicComments = new MagicComments()
    @texliciousView = new TeXliciousView({texlicious: @})

  activate: (state) ->
    atom.commands.add 'atom-text-editor',
      'texlicious:compile': => @compile()
    atom.commands.add 'atom-text-editor',
      'texlicious:watch': => @watch()

    atom.workspace.addBottomPanel
      item: @texliciousView

  deactivate: ->
    @texliciousView.destroy()

  # TODO: See: https://atom.io/docs/v0.176.0/advanced/serialization.
  # serialize: ->

  getActiveFile: ->
    activeFile = @editor.getPath()
    unless activeFile?
      return

    activeFile

  isTexFile: ->
    activeFile = @getActiveFile()
    if activeFile?
      unless path.extname(activeFile) is '.tex'
        # TODO: Notify the user that the file is not a tex file.
        console.log 'No tex file found.'
        return false

      @texFile = activeFile

      return true

  saveTexFile: ->
    @editor.save()

  makeArgs: ->
    latexmkArgs = @latexmk.args @texFile
    magicComments = @magicComments.getMagicComments @texFile
    magicArgs = @magicComments.args magicComments
    mergedArgs = extend(true, latexmkArgs, magicComments)
    args = [mergedArgs.default, mergedArgs.program, mergedArgs.outdir, mergedArgs.root]

    args

  compile: ->
    console.log "Compiling ..."
    unless @isTexFile()
      return

    @saveTexFile()

    args = @makeArgs()
    options = @processManager.options()

    @texliciousView.toggleCompileIndicator()
    proc = @latexmk.make args, options, (exitCode) =>
      @texliciousView.toggleCompileIndicator()
      switch exitCode
        when 0
          console.log '... done compiling.'
        else
          console.log '... error compiling.'
          @texliciousView.showLog(@texFile)

  watch: ->
    @texliciousView.startWatching()

module.exports = new TeXlicious()
