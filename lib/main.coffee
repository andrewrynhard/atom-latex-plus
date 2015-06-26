fs = require 'fs'
path = require 'path'
extend = require 'extend'
{Disposable, CompositeDisposable} = require 'atom'

ProcessManager = require './process-manager'
StatusBarManager = require './status-bar-manager'
Latexmk = require './latexmk'
MagicComments = require './magic-comments'
ErrorView = require './views/error-view'
LogParser = require './log-parser'

class TeXlicious
  config:
    texPath:
      title: 'TeX Path'
      description: "Location of your custom TeX installation bin."
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
    bibtexEnabled:
      title: 'Enable BibTeX'
      type: 'boolean'
      default: false
      order: 5
    synctexEnabled:
      title: 'Enable Synctex'
      type: 'boolean'
      default: false
      order: 6
    shellEscapeEnabled:
      title: 'Enable Shell Escape'
      type: 'boolean'
      default: false
      order: 7

  constructor: ->
    @processManager = new ProcessManager()
    @statusBarManager = new StatusBarManager
    @latexmk = new Latexmk({texliciousCore: @})
    @magicComments = new MagicComments({texliciousCore: @})
    @logParser = new LogParser({texliciousCore: @})
    @errorView = new ErrorView()

    @disposables = new CompositeDisposable
    @texEditor = null
    @texFile = null
    @errorMarkers = [] # TODO: Make this a composite disposable.

  activate: (state) ->
    atom.workspace.addBottomPanel item: @errorView
    atom.commands.add 'atom-text-editor',
      'texlicious:compile': =>
        unless @isTex()
          return
        @updateStatusBar('compile')
        @setTex()
        @compile()

  deactivate: ->
    @mainPanel.destroy()
    @errorView.destroy()

  consumeStatusBar: (statusBar) ->
    @statusBarManager.initialize(statusBar)
    @statusBarManager.attach()
    @disposables.add new Disposable =>
      @statusBarManager.detach()

  updateStatusBar: (mode) ->
    @statusBarManager.update(mode)

  notify: (message) ->
    atom.notifications.addInfo(message)

  saveAll: ->
    pane.saveItems() for pane in @getPanes()

  setTex: ->
    activeTextEditor = atom.workspace.getActiveTextEditor()
    activeFile = activeTextEditor.getPath()

    for directory in atom.project.getDirectories()
      if activeFile.indexOf(directory.realPath) isnt -1
        @texProjectRoot = directory.realPath
        break

    unless @texProjectRoot
      return

    @texEditor = activeTextEditor

  isTex: ->
    activeFile = atom.workspace.getActiveTextEditor().getPath()
    unless path.extname(activeFile) is '.tex'
      @notify "The file \'" + path.basename activeFile + "\' is not a TeX file."
      return false
    true

  getTexProjectRoot: ->
    @texProjectRoot

  getTexEditor: ->
    @texEditor

  getPanes: ->
    atom.workspace.getPanes()

  getPaneItems: ->
    atom.workspace.getPaneItems()

  getEditors: ->
    atom.workspace.getTextEditors()

  makeArgs: ->
    args = []

    if @getTexEditor not null
      latexmkArgs = @latexmk.args @texEditor.getPath()
      magicComments = @magicComments.getMagicComments @texEditor.getPath()
      mergedArgs = extend(true, latexmkArgs, magicComments)
      @texFile = mergedArgs.root

      args.push mergedArgs.default
      if mergedArgs.synctex?
        args.push mergedArgs.synctex
      if mergedArgs.program?
        args.push mergedArgs.program
      if mergedArgs.outdir?
        args.push mergedArgs.outdir
      args.push mergedArgs.root

      args

  # TODO: Update editor gutter when file is opened.
  updateErrors: (errors) =>
    @errorView.update(errors)
    editors =  atom.workspace.getTextEditors()

    for error in errors
      for editor in editors
        errorFile = path.basename error.file
        if errorFile == path.basename editor.getPath()
          row = parseInt error.line - 1
          column = editor.buffer.lineLengthForRow(row)
          range = [[row, 0], [row, column]]
          marker = editor.markBufferRange(range, invalidate: 'touch')
          decoration = editor.decorateMarker(marker, {type: 'line-number', class: 'gutter-red'})
          @errorMarkers.push marker

  compile: ->
    @saveAll()
    args = @makeArgs()
    options = @processManager.options()
    proc = @latexmk.make args, options, (exitCode) =>
      switch exitCode
        when 0
          @updateStatusBar('ready')
          @errorView.update(null)
          marker.destroy() for marker in @errorMarkers
        else
          @updateStatusBar('error')
          @logParser.parseLogFile(@texFile, @updateErrors)

module.exports = new TeXlicious()
