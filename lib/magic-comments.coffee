fs = require 'fs'

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
      magicComments[magicKey[0]] = magicValue[1]

    magicComments
