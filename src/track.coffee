fs = require('fs')
mm = require('musicmetadata')

module.exports =
class Track
  constructor: (@path, callback) ->
    t = @
    mm(fs.createReadStream(@path), (err, metadata) ->
      delete metadata.picture  # Too big for the database #TODO (use it in getCover)
      t.metadata = metadata if not err
      callback t
    )
