fs = require('fs')
remote = require('remote')
app = remote.require('app')

Discogs = require('disconnect').Client
discogsClient = new Discogs({
  consumerKey: 'ZvSFpyJkoqeLHNexMsvf',
  consumerSecret: 'OISyQkPdqoDewONjvpXEcjKeCmjKvCWH'
}).database()

artistsMem = []
albumsMem = []

@getArtistImage = (artist, callback) ->
  if artist not in artistsMem and not fs.existsSync("#{app.getPath('userData')}/images/artists/#{artist}")
    artistsMem.push(artist)

    fs.mkdirSync("#{app.getPath('userData')}/images/") if not fs.existsSync("#{app.getPath('userData')}/images/")
    fs.mkdirSync("#{app.getPath('userData')}/images/artists") if not fs.existsSync("#{app.getPath('userData')}/images/artists")

    discogsClient.search(artist, {type: 'artist'}, (err, data) ->
      if not err and data.results.length > 0
        discogsClient.artist(data.results[0].id, (err, data) ->
          if not err and data.images?
            url = data.images[0].resource_url
            discogsClient.image(url, (err, data, rateLimit) ->
                fs.writeFile("#{app.getPath('userData')}/images/artists/#{artist}", data, 'binary', ->
                  callback "#{app.getPath('userData')}/images/artists/#{artist}" if callback?)
            )))

@getAlbumImage = (artist, album, callback) ->
  if album not in albumsMem and not fs.existsSync("#{app.getPath('userData')}/images/albums/#{artist} - #{album}")
    albumsMem.push(album)

    fs.mkdirSync("#{app.getPath('userData')}/images/") if not fs.existsSync("#{app.getPath('userData')}/images/")
    fs.mkdirSync("#{app.getPath('userData')}/images/albums") if not fs.existsSync("#{app.getPath('userData')}/images/albums")

    discogsClient.search(album, {type: 'release', artist: artist}, (err, data) ->
      if not err and data.results.length > 0
        discogsClient.release(data.results[0].id, (err, data) ->
          if not err and data.images?
            url = data.images[0].resource_url
            discogsClient.image(url, (err, data, rateLimit) ->
              fs.writeFile("#{app.getPath('userData')}/images/albums/#{artist} - #{album}", data, 'binary', (err) ->
                callback "#{app.getPath('userData')}/images/albums/#{artist} - #{album}" if callback?)
            )))
