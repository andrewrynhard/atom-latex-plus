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
  config: _.clone(require('./config-schema'))

  activate: (state) ->
    atom.workspaceView.command 'latex:build', => @build()
    atom.workspaceView.command 'latex:watch', => @watch()

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
    @texInputs = atom.config.get('latex.texInputs')
    if @texInputs?
      match = @texInputs.match(texInputsPattern)
      unless match?
        atom.config.set('latex.texInputs', @texInputs.replace(/(^.*[A-Za-z0-9_])/, "$1\/\/:"))
