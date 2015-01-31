# TODO: Logger for https://atom.io/docs/api/v0.176.0/Atom#instance-inDevMode.

fs = require 'fs'
path = require 'path'

{CompositeDisposable} = require 'atom'
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

  activate: (state) ->
    atom.commands.add 'atom-text-editor',
      'texlicious:compile': => @compile()
    atom.commands.add 'atom-text-editor',
      'texlicious:watch': => @watch()

    atom.workspace.addBottomPanel
      item: @texliciousView

  constructor: ->
    @processManager = new ProcessManager()
    @latexmk = new Latexmk()
    @magicComments = new MagicComments()
    @texliciousView = new TeXliciousView()

  deactivate: ->
    @texliciousView.destroy()

  # TODO: See: https://atom.io/docs/v0.176.0/advanced/serialization.
  # serialize: ->

  getActiveFile: ->
    editor = atom.workspace.getActivePaneItem()
    filePath = editor?.getPath()
    if filePath?
      unless path.extname(filePath) is '.tex'
        filePath = null
      filePath

  saveActiveFile: ->
    editor = atom.workspace.getActivePaneItem()
    editor.save()

  handleEvents: () ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      buffer = editor.getBuffer()
      bufferSavedSubscription = buffer.onDidSave =>
        buffer.transact =>
          scopeDescriptor = editor.getRootScopeDescriptor()
          @compile(true)

      editorDestroyedSubscription = editor.onDidDestroy ->
        bufferSavedSubscription.dispose()
        editorDestroyedSubscription.dispose()
      bufferDestroyedSubscription = buffer.onDidDestroy ->
        bufferDestroyedSubscription.dispose()
        bufferSavedSubscription.dispose()

      @subscriptions.add(bufferSavedSubscription)
      @subscriptions.add(editorDestroyedSubscription)
      @subscriptions.add(bufferDestroyedSubscription)

  compile: (isWatching) ->
    console.log "Compiling ..."

    # Prevent infinite loop.
    unless isWatching?
      @saveActiveFile()

    texFile = @getActiveFile()
    unless texFile?
      # TODO: Display message indicating a non-tex file tried to be compiled.
      return

    magicComments = @magicComments.getMagicComments texFile
    # TODO: Make this if block its own method.
    # TODO: Implement 'program' magic comment.
    if magicComments.root?
      files = fs.readdirSync(atom.project.getRootDirectory().getPath()).forEach (file) ->
        if magicComments.root == file
          texFile = path.join(atom.project.getRootDirectory().getPath(),file)
        else
          # TODO: Notify the user that the file was not found.
    args = @latexmk.args texFile
    options = @processManager.options()

    @texliciousView.toggleCompileIndicator()
    proc = @latexmk.make args, options, (exitCode) =>
      @texliciousView.toggleCompileIndicator()
      switch exitCode
        when 0
          console.log '... success.'
        else
          console.log '... error.'
          @texliciousView.showLog(texFile)

  watch: ->
    console.log "Watching ..."
    @handleEvents()

module.exports = new TeXlicious()
