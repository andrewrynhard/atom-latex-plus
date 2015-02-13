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
    synctexEnabled:
      title: 'Synctex'
      type: 'boolean'
      default: false
      order: 5
    shellEscapeEnabled:
      title: 'Shell Escape'
      type: 'boolean'
      default: false
      order: 6
    watchDelay:
      title: 'Watch Delay'
      description: 'Time in seconds to wait until compiling when in watch mode.'
      type: 'integer'
      default: 5
      order: 7

  constructor: ->
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
    editor = atom.workspace.getActiveTextEditor()
    activeFile = editor.getPath()
    unless activeFile?
      return

    activeFile

  isTexFile: ->
    activeFile = @getActiveFile()
    if activeFile?
      unless path.extname(activeFile) is '.tex'
        atom.notifications.addInfo("The file \'" + path.basename activeFile + "\' is not a TeX file.")
        return false

      @texFile = activeFile

      return true

  saveTexFile: ->
    editor = atom.workspace.getActiveTextEditor()
    editor.save()

  makeArgs: ->
    args = []

    latexmkArgs = @latexmk.args @texFile
    magicComments = @magicComments.getMagicComments @texFile
    mergedArgs = extend(true, latexmkArgs, magicComments)

    @texliciousView.setTexFile mergedArgs.root

    args.push mergedArgs.default
    if mergedArgs.synctex?
      args.push mergedArgs.synctex
    if mergedArgs.program?
      args.push mergedArgs.program
    args.push mergedArgs.outdir
    args.push mergedArgs.root

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
          # TODO: Highlight lines with errors in the gutter.
          console.log '... error compiling.'
      @texliciousView.updateLog()

  watch: ->
    if @texliciousView.watching
      atom.notifications.addInfo("TeXlicious is already watching a file.")
      return
    else
      @texliciousView.watching = true

    @texPanel = atom.workspace.getActivePaneItem()
    @texPanel.isWatching = true

    @compile()
    console.log @getActiveFile()
    @texliciousView.setWatchFile path.basename @getActiveFile()
    @texliciousView.startWatchEvents()

module.exports = new TeXlicious()
