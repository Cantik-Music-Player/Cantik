fs = require('fs')
mm = require('musicmetadata')

module.exports =
class Track
  constructor: (@path, callback) ->
    t = @
    mm(fs.createReadStream(@path), (err, metadata) ->
      if metadata?
        delete metadata.picture
        t.metadata = metadata
        callback t
    )
