fs = require 'fs'
path = require 'path'
{Disposable, CompositeDisposable} = require 'atom'

ProcessManager = require './process_manager'
MessageManager = require './message_manager'
StatusBarManager = require './status_bar_manager'
Latexmk = require './latexmk'
LogParser = require './log_parser'

class LatexPlus
  config:
    texPath:
      title: 'TeX Path'
      description: "Location of your custom TeX installation bin."
      type: 'string'
      default: ''
      order: 1
    texInputs:
      title: 'TeX Packages'
      description: "Location of your custom TeX packages directory."
      type: 'string'
      default: ''
      order: 3
    bibtexEnabled:
      title: 'Enable BibTeX'
      type: 'boolean'
      default: false
      order: 5
    shellEscapeEnabled:
      title: 'Enable Shell Escape'
      type: 'boolean'
      default: false
      order: 6

  cfg: {
    path: null,
    project: null,
    root: null,
    program: null,
    output: null
  }

  constructor: ->
    @processManager = new ProcessManager()
    @messageManager = new MessageManager()
    @statusBarManager = new StatusBarManager()
    @latexmk = new Latexmk()
    @logParser = new LogParser()

    @disposables = new CompositeDisposable
    @errorMarkers = [] # TODO: Make this a composite disposable.

  activate: (state) ->
    atom.commands.add 'atom-text-editor', 'latex-plus:compile': =>
      file = atom.workspace.getActiveTextEditor().getPath()

      # if the configuration file is not set or the file is not in the current
      # configuration path, then load the configuration and compile
      if !@cfg.path? || file.indexOf(@cfg.path) < 0
        if @loadProject(file)
          @compile()
      else
        @compile()

  deactivate: ->
    @messageManager.destroy()
    @statusBarManager.destroy()

  loadProject: (file, callback) ->
    @resetCfg()
    for project in atom.project.getPaths()
      # if the current file is not in `project` advance to the next iteration
      unless file.indexOf(project) > -1
        continue

      exists = fs.existsSync "#{project}/tex.json"
      if exists
        # watch for changes in the project configuration
        fs.watchFile "#{project}/tex.json", (curr, prev) =>
          if curr.mtime != prev.mtime
            @setCfg(project)
      else
        atom.notifications.addError("A project configuration file must be defined in #{project}.")
        return false

      if @setCfg(project)
        return true
      else
        return false

  setCfg: (project) ->
    @cfg.path = "#{project}/tex.json"

    data = fs.readFileSync @cfg.path
    cfg = JSON.parse(data)

    @cfg.root = path.join(project, cfg.root)
    unless path.extname(@cfg.root) is '.tex'
      atom.notifications.addInfo("The project root does not have the extension '.tex'.")
      return false

    exists = fs.existsSync @cfg.root
    unless exists
      atom.notifications.addError("The project root does not exist.")
      return false

    # TODO: check if the program is valid
    @cfg.program = cfg.program
    @cfg.output = path.join(project, cfg.output)
    @cfg.project = cfg.project

    @statusBarManager.project = @cfg.project
    @statusBarManager.update('ready')

    return true

  resetCfg: ->
    # stop watching for changes in the project configuration
    if @cfg.path?
      fs.unwatchFile(@cfg.path)

    @cfg.path = null
    @cfg.project = null
    @cfg.root = null
    @cfg.program = null
    @cfg.output = null

  consumeStatusBar: (statusBar) ->
    @statusBarManager.initialize(statusBar)
    @statusBarManager.attach()
    @disposables.add new Disposable =>
      @statusBarManager.detach()

  makeArgs: ->
    args = []

    latexmkArgs = {
      default: '-interaction=nonstopmode -f -cd -pdf -file-line-error'
    }

    latexmkArgs.bibtex = '-bibtex' if atom.config.get('latex-plus.bibtexEnabled')
    latexmkArgs.shellEscape = '-shell-escape' if atom.config.get('latex-plus.shellEscapeEnabled')

    args.push latexmkArgs.default
    if latexmkArgs.shellEscape?
      args.push latexmkArgs.shellEscape
    if latexmkArgs.bibtex?
      args.push latexmkArgs.bibtex
    unless @cfg.program == "pdflatex"
      args.push "-#{@cfg.program}"
    args.push "-outdir=\"#{@cfg.output}\""
    args.push "\"#{@cfg.root}\""

    args

  # TODO: Update editor gutter when file is opened.
  updateGutter: (errors) =>
    @messageManager.update(errors)
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

  compile: =>
    @statusBarManager.update('compile')

    # save all modified tex files before compiling
    for pane in atom.workspace.getPanes()
      pane.saveItems()

    args = @makeArgs()
    options = @processManager.options()
    proc = @latexmk.make args, options, (exitCode) =>
      switch exitCode
        when 0
          @statusBarManager.update('ready')
          @messageManager.update(null)
          marker.destroy() for marker in @errorMarkers
        else
          @statusBarManager.update('error')
          log = path.join(@cfg.output, path.basename(@cfg.root).split('.')[0] + '.log')
          @logParser.parseLogFile(path.dirname(@cfg.root), log, @updateGutter)

module.exports = new LatexPlus()
