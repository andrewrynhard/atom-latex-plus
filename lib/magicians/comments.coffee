_ = require 'underscore-plus'
fs = require 'fs-plus'
readline = require 'readline'
stream = require 'stream'
Magician = require '../magician'

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
class CommentMagician extends Magician
  getMagicComments: (texFile, callback) ->
    magicComments = []

    instream = fs.createReadStream(texFile)
    outstream = new stream

    outstream.readable = true
    outstream.writable = true

    reader = readline.createInterface {
      input: instream,
      output: outstream,
      terminal: false
      }

    reader.on 'line', (line) ->
      magicLine = line.match(magicCommentPattern)

      if magicLine?
        magicKey = line.match(magicCommentKeyPattern)
        magicValue = line.match(magicCommentValuePattern)
        magicComments[magicKey[0]] = magicValue[1]

    reader.on 'close', () ->
      callback(magicComments)
