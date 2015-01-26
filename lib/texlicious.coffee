_ = require 'underscore-plus'
fs = require 'fs-plus'
path = require 'path'
LatexmkBuilder = require './builders/latexmk'
Indicators = require './indicators/indicators'
Logger = require './logger'

texInputsPattern = ///
  (.*[A-Za-z0-9_]\/\/:$) # Ensure last three characters are '//:'
  ///

module.exports =
  config:
    texPath:
      title: 'TeX Path'
      description: "The full path to your TeX distribution's bin directory."
      type: 'string'
      default: ''
      order: 1
    engine:
      title: 'TeX Flavor'
      description: 'Engine used to compile a TeX file.'
      type: 'string'
      default: 'pdflatex'
      enum: ['pdflatex', 'lualatex', 'xelatex']
      order: 2
    texInputs:
      title: 'TeX Inputs'
      description: "The full path to your custom TeX packages directory."
      type: 'string'
      default: ''
      order: 3
    outputDirectory:
      title: 'Output Directory'
      description: 'All files generated during a build will be redirected here.
        Leave blank if you want the build output to be stored in the same
        directory as the TeX document.'
      type: 'string'
      default: ''
      order: 4
    enableShellEscape:
      title: 'Shell Escape Flag for latexmk'
      type: 'boolean'
      default: false
      order: 5
    useHardwareAcceleration:
      type: 'boolean'
      default: true
      description: 'Disabling will improve editor font rendering but reduce scrolling performance.'
      order: 99

  activate: (state) ->
    atom.workspaceView.command 'texlicious:build', => @build()
    atom.workspaceView.command 'texlicious:watch', => @watch()

  deactivate: -> # ...

  serialize: -> # ...

  build: ->
    texFilePath = @getFilePath()
    unless texFilePath?
      return

    @formatTexInputs()
    builder = @getBuilder()
    args = builder.constructArgs(texFilePath)
    options = builder.constructChildProcessOptions()

    @indicators = new Indicators()
    @indicators.showBuildIndicator()
    proc = builder.build args, options, (statusCode) =>
      @indicators.destroyBuildIndicator()
      switch statusCode
        when 0
          console.log(statusCode) # TODO: clean auxdir and move pdf/synctex file to root directory.
        when 127
          @logger = new Logger()
          logContents = @logger.readLogFile(texFilePath)
          @indicators.showErrorIndicator({logContents: logContents})
        else
          @logger = new Logger()
          logContents = @logger.readLogFile(texFilePath)
          @indicators.showErrorIndicator({logContents: logContents})
    return

  watch: ->
    texFilePath = @getFilePath()
    unless texFilePath?
      return

    @formatTexInputs()
    builder = @getBuilder()
    args = builder.constructArgs(texFilePath)
    options = builder.constructChildProcessOptions()

    @indicators = new Indicators()
    proc = builder.watch args, options, (statusCode) =>
      @indicators.showWatchIndicator({proc: proc})
      # TODO: handle all error exit codes.
      switch statusCode
        when 0
          console.log("Process #{proc.pid} terminated.")
          @indicators.destroyWatchIndicator()
        when 12 # TODO: Research this error code.
          @indicators.destroyWatchIndicator()

    return

  getFilePath: ->
    editor = atom.workspace.getActivePaneItem()
    texFilePath = editor?.getPath()
    unless texFilePath?
      unless atom.inSpecMode()
        console.info 'File needs to be saved to disk before it can be TeXified.'
      return

    editor.save() if editor.isModified() # TODO: Make this configurable?
    texFilePath

  getBuilder: ->
    new LatexmkBuilder()

  formatTexInputs: ->
    @texInputs = atom.config.get('texlicious.texInputs')
    if @texInputs?
      match = @texInputs.match(texInputsPattern)
      unless match?
        atom.config.set('texlicious.texInputs', @texInputs.replace(/(^.*[A-Za-z0-9_])/, "$1\/\/:"))
