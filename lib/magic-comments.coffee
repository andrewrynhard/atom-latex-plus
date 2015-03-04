#TODO: Add and option that allows relative paths for PDF output.
fs = require 'fs'
path = require 'path'

magicCommentPattern = ///
  ^%!TEX # Find line starting with %!TEX
  ///

magicCommentKeyPattern = ///
  [^%!TEX\s]([A-Za-z]*) # Capture the key
  ///

magicCommentValuePattern = ///
  =\s(.+) # Capture the value
  ///

module.exports =
class MagicComments
  constructor: (params) ->
    @texliciousCore = params.texliciousCore

  getMagicComments: (texFile) ->
    magicComments = []

    try
      texProjectRoot = @texliciousCore.getTexProjectRoot()
      fs.readFileSync(texFile).toString().split('\n').forEach (line) ->
        magicLine = line.match(magicCommentPattern)
        unless magicLine?
          return
        magicKey = line.match(magicCommentKeyPattern)
        magicValue = line.match(magicCommentValuePattern)
        if magicKey[0] == 'root'
          texFile = path.join(texProjectRoot, magicValue[1])
          magicValue[1] = "\"#{texFile}\""
        magicComments[magicKey[0]] = magicValue[1]
    catch e
      if e.code is 'ENOENT'
        atom.notifications.addError(e.toString(), dismissable: true)
      else
        atom.notifications.addError(e.toString(), dismissable: true)
        throw (e)

    magicComments
