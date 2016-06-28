fs = require('fs')
mm = require('musicmetadata')

module.exports =
class Track
  constructor: (@path, callback) ->
    stream = fs.createReadStream(@path)
    mm(stream, {duration: true}, (err, metadata) =>
      if metadata?
        delete metadata.picture
        @metadata = metadata
      stream.close()
      callback @
    )
