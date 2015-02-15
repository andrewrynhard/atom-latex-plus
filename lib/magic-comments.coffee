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

  getMagicComments: (texFile) ->
    magicComments = []

    fs.readFileSync(texFile).toString().split('\n').forEach (line) ->
      magicLine = line.match(magicCommentPattern)
      unless magicLine?
        return
      magicKey = line.match(magicCommentKeyPattern)
      magicValue = line.match(magicCommentValuePattern)
      if magicKey[0] == 'root'
        texFile = path.join(atom.project.getRootDirectory().getPath(), magicValue[1])
        magicValue[1] = "\'#{texFile}\'"
      magicComments[magicKey[0]] = magicValue[1]

    magicComments
