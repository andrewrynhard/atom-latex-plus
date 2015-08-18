ContentsByMode =
  'ready': ["status-bar-texlicious-mode-compile", "TeXlicious: Ready"]
  'compile': ["status-bar-texlicious-mode-compile", "TeXlicious: Compiling ... "]
  'error': ["status-bar-texlicious-mode-error", "TeXlicious: Error"]

module.exports =
class StatusBarManager
  constructor: ->
    @element = document.createElement("div")
    @element.id = "status-bar-texlicious-mode"

    @container = document.createElement("div")
    @container.className = "inline-block"
    @container.appendChild(@element)

  initialize: (@statusBar) ->

  update: (mode) ->
    if newContents = ContentsByMode[mode]
      [klass, text] = newContents
      @element.className = klass
      @element.textContent = text

  # Private

  attach: ->
    @tile = @statusBar.addLeftTile(item: @container, priority: 20)

  detach: ->
    @tile.destroy()
