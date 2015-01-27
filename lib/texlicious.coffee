# TODO: clean auxdir and move pdf/synctex file to root directory.
# TODO: Kill all spawned processes on 'deactivate'

_ = require 'underscore-plus'
fs = require 'fs-plus'
path = require 'path'
Latexmk = require './builders/latexmk'
Viewer = require './viewer'
CommentMagician = require './magicians/comments'
Logger = require './logger'

texInputsPattern = ///
  (.*[A-Za-z0-9_]\/\/:$) # Ensure last three characters are '//:'
  ///

class Texlicious
  version: require('../package.json').version
  config: _.clone(require('./misc/config'))

  constructor: ->
    @projectDirectory = atom.project.getRootDirectory().getPath()
    @viewer = new Viewer()
    @latexmk = new Latexmk()
    @commentMagician = new CommentMagician()
    @logger = new Logger()
    @formatTexInputs()

  activate: (state) ->
    atom.workspaceView.command 'texlicious:build', => @run(false)
    atom.workspaceView.command 'texlicious:watch', => @run(true)

  deactivate: -> # ...

  serialize: -> # ...

  formatTexInputs: ->
    @texInputs = atom.config.get('texlicious.texInputs')
    if @texInputs?
      match = @texInputs.match(texInputsPattern)
      unless match?
        atom.config.set('texlicious.texInputs',
          @texInputs.replace(/(^.*[A-Za-z0-9_])/, "$1\/\/:"))

  getActiveFile: ->
    editor = atom.workspace.getActivePaneItem()
    filePath = editor?.getPath()
    if filePath?
      unless path.extname(filePath) is '.tex'
        return
      filePath

  saveActiveFile: ->
    editor = atom.workspace.getActivePaneItem()
    editor.save()

  run: (shouldWatch) ->
    @texFile = @getActiveFile()
    if @texFile?
      @saveActiveFile()

    @commentMagician.getMagicComments @texFile, (magicComments) =>
      if magicComments.root?
        @texFile = path.join(@projectDirectory, magicComments.root)

      args = @latexmk.latexmkArgs @texFile, shouldWatch
      options = @latexmk.setChildProcessEnv(shouldWatch)

      if shouldWatch
        proc = @latexmk.watch args, options, @viewer, (exitCode) =>
          @viewer.destroyWatchIndicator()
      else
        @viewer.showBuildIndicator()
        proc = @latexmk.build args, options, (exitCode) =>
          switch exitCode
            when 0
              proc.kill()
            else
              proc.kill()
              logContents = @logger.readLogFile(@texFile)
              @viewer.showLogView({logContents: logContents})
          @viewer.destroyBuildIndicator()

module.exports = new Texlicious()
