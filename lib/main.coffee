fs = require 'fs'
path = require 'path'
extend = require 'extend'
{Disposable, CompositeDisposable} = require 'atom'

ProcessManager = require './process_manager'
MessageManager = require './message_manager'
Latexmk = require './latexmk'
LogParser = require './log_parser'

class TeXlicious
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

# texFlavor:
#   title: 'TeX Flavor'
#   description: 'Default program used to compile a TeX file.'
#   type: 'string'
#   default: 'pdflatex'
#   enum: ['lualatex', 'pdflatex', 'xelatex']
#   order: 2
# outputDirectory:
#   title: 'Output Directory'
#   description: 'Output directory relative to the project root.'
#   type: 'string'
#   default: ''
#   order: 4

  constructor: ->
    @processManager = new ProcessManager()
    @messageManager = new MessageManager()
    @latexmk = new Latexmk()
    @logParser = new LogParser()

    @disposables = new CompositeDisposable
    @errorMarkers = [] # TODO: Make this a composite disposable.

  activate: (state) ->
    atom.commands.add 'atom-text-editor', 'texlicious:compile': => @compile()

  deactivate: ->
    @mainPanel.destroy()
    @messageManager.destroy()
    @statusBarManager.update(mode)

  loadProject: () ->
    # set the first directory found to have a 'tex.json' file as the project
    # root
    for directory in atom.project.getDirectories()
      files = fs.readdirSync directory.getPath()

      if "tex.json" in files
        @projectRoot = directory.realPath
        json = fs.readFileSync path.join(@projectRoot, "tex.json")

        data = JSON.parse(json)
        @project = data.project
        @root = data.root
        @program = data.program
        @output = data.output

        break

  notProject: ->
    unless @projectRoot
      atom.notifications.addError("The project configuration file 'tex.json' must be defined in the project root")
      return false

    true

  notTex: ->
    activeFile = atom.workspace.getActiveTextEditor().getPath()
    unless path.extname(activeFile) is '.tex'
      atom.notifications.addInfo("The file \'" + path.basename activeFile + "\' does not have the extension '.tex'.")
      return false

    true

  makeArgs: ->
    args = []

    latexmkArgs = {
      default: '-interaction=nonstopmode -f -cd -pdf -file-line-error'
    }

    latexmkArgs.bibtex = '-bibtex' if atom.config.get('texlicious.bibtexEnabled')
    latexmkArgs.shellEscape = '-shell-escape' if atom.config.get('texlicious.shellEscapeEnabled')

    args.push latexmkArgs.default
    if latexmkArgs.shellEscape?
      args.push latexmkArgs.shellEscape
    if latexmkArgs.bibtex?
      args.push latexmkArgs.bibtex
    args.push "-#{@program}"
    args.push "-outdir=\"#{path.join(@projectRoot, @output)}\""
    args.push "\"#{path.join(@projectRoot, @root)}\""

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

  compile: ->
    @loadProject()

    # require a '.tex' extension
    unless @notTex()
      return

    # require a 'tex.json' configuration file to be defined
    unless @notProject()
      return

    # save all modified tex files before compiling
    for pane in atom.workspace.getPanes()
      pane.saveItems()

    args = @makeArgs()
    options = @processManager.options()
    proc = @latexmk.make args, options, (exitCode) =>
      switch exitCode
        when 0
          @messageManager.update(null)
          marker.destroy() for marker in @errorMarkers
        else
          log = path.join(@projectRoot, @output, path.basename(@root).split('.')[0] + '.log')
          @logParser.parseLogFile(log, @updateGutter)

module.exports = new TeXlicious()
