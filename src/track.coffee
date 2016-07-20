fs = require 'graceful-fs'
mm = require 'musicmetadata'

module.exports =
class Track
  constructor: (@path, callback) ->
    stream = fs.createReadStream(@path)
    stream.on('error', callback)
    mm(stream, {duration: true}, (err, metadata) =>
      if metadata?
        delete metadata.picture
        @metadata = metadata
      stream.close()
      callback @
    )
