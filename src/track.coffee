fs = require('fs')
mm = require('musicmetadata')

module.exports =
class Track
  constructor: (@path, callback) ->
    mm(fs.createReadStream(@path), {duration: true}, (err, metadata) =>
      if metadata?
        delete metadata.picture
        @metadata = metadata
      callback @
    )
