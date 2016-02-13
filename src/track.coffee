fs = require('fs')
mm = require('musicmetadata')
remote = require('remote')
app = remote.require('app')
Discogs = require('disconnect').Client

module.exports =
class Track
  constructor: (@path, callback) ->
    t = @
    mm(fs.createReadStream(@path), (err, metadata) ->
      delete metadata.picture  # Too big for the database #TODO (use it in getCover)
      t.metadata = metadata if not err
      callback t
    )

  initDiscogs: ->
    if not @discogsClient?
      # TODO(use settings)
      @discogsClient = new Discogs({
        consumerKey: 'ZvSFpyJkoqeLHNexMsvf',
        consumerSecret: 'OISyQkPdqoDewONjvpXEcjKeCmjKvCWH'
      }).database()

  getArtistImage: ->
    if @metadata?.artist? and not fs.existsSync("#{app.getPath('userData')}/images/artists/#{@metadata.artist}")
      do @initDiscogs
      discogsClient = @discogsClient
      metadata = @metadata

      fs.mkdirSync("#{app.getPath('userData')}/images/") if not fs.existsSync("#{app.getPath('userData')}/images/")
      fs.mkdirSync("#{app.getPath('userData')}/images/artists") if not fs.existsSync("#{app.getPath('userData')}/images/artists")

      @discogsClient.search(metadata.artist[0], {type: 'artist'}, (err, data) ->
        if not err and data.results.length > 0
          discogsClient.artist(data.results[0].id, (err, data) ->
            if not err and data.images?
              url = data.images[0].resource_url
              discogsClient.image(url, (err, data, rateLimit) ->
                  fs.writeFile("#{app.getPath('userData')}/images/artists/#{metadata.artist[0]}", data, 'binary')
              )))

  getAlbumImage: ->
    if @metadata?.album? and not fs.existsSync("#{app.getPath('userData')}/images/albums/#{@metadata.artist[0]} - #{@metadata.album}")
      do @initDiscogs
      discogsClient = @discogsClient
      metadata = @metadata

      fs.mkdirSync("#{app.getPath('userData')}/images/") if not fs.existsSync("#{app.getPath('userData')}/images/")
      fs.mkdirSync("#{app.getPath('userData')}/images/albums") if not fs.existsSync("#{app.getPath('userData')}/images/albums")

      @discogsClient.search(metadata.album, {type: 'release', artist: metadata.artist[0]}, (err, data) ->
        console.log err
        if not err and data.results.length > 0
          discogsClient.release(data.results[0].id, (err, data) ->
            if not err and data.images?
              url = data.images[0].resource_url
              discogsClient.image(url, (err, data, rateLimit) ->
                  fs.writeFile("#{app.getPath('userData')}/images/albums/#{metadata.artist[0]} - #{metadata.album}", data, 'binary')
              )))
