fs = require 'fs'
remote = require 'remote'
app = remote.require 'app'
Track = require '../../src/track'
path = require 'path'

LocalLibraryComponent = require('./view.cjsx').LocalLibraryComponent
showLocalLibrary = require('./view.cjsx').show

module.exports =
class LocalLibrary
  constructor: (@pluginManager) ->
    @history = @pluginManager.plugins.history
    @loading = false
    @userData = app.getPath 'userData'

    @element = @pluginManager.plugins.centralarea.addPanel('Local Library', 'Source',
                                                           null, true)

    do @initDB

    do @show

    @localLibrary = 'C:\\Users\\Cyprien\\Music\\Sabaton'
    @parseLibrary @localLibrary

  show: ->
    showLocalLibrary(@, @element)

  getArtists: (callback) ->
    if not @artists
      localLibrary = @
      @db.query('artistcount/artist', {reduce: true, group: true}, (err, results) ->
        localLibrary.artists = (a.key for a in results.rows)
        callback localLibrary.artists)
    else
      callback @artists

  getAlbums: (artist, callback) ->
    @db.query('artist/artist', {key: artist, include_docs: true}).then((result) ->
      albums = []
      for row in result.rows
        if row.doc.metadata?.album?
          albums.push(row.doc.metadata.album) if row.doc.metadata.album not in albums
      callback albums)

  getAlbumTracks: (artist, album, callback) ->
    if album is "All tracks"
      @db.query('artist/artist', {key: artist, include_docs: true}).then((result) ->
        callback result.rows)
    else
      @db.query('album/album', {key: album, include_docs: true}).then((result) ->
        tracks = []
        for row in result.rows
          tracks.push(row) if row.doc.metadata?.artist? and row.doc.metadata.artist[0] is artist
        callback tracks)

  initDB: ->
    @db = new PouchDB('library')
    @db.put({
      _id: '_design/artist',
      views: {
        'artist': {
          map: 'function (doc) { emit(doc.metadata.artist[0]); }'
        }
      }
    })
    @db.put({
      _id: '_design/artistcount',
      views: {
        'artist': {
          map: 'function (doc) { emit(doc.metadata.artist[0]); }',
          reduce: '_count'
        }
      }
    })
    @db.put({
      _id: '_design/album',
      views: {
        'album': {
          map: 'function (doc) { emit(doc.metadata.album); }'
        }
      }
    })

  parseLibrary: (libraryPath) ->
    db = @db
    files = fs.readdirSync(libraryPath)

    # Get the files
    for file in files
      if file[0] != '.'
          filePath = "#{libraryPath}/#{file}"
          stat = fs.statSync(filePath)

          if stat.isDirectory()
            @parseLibrary filePath
          else if path.extname(filePath) in ['.ogg', '.flac', '.aac', '.mp3', '.m4a']
            # Check already ingested
            db.get(filePath, (err, data) ->
              if err?.status is 404
                new Track(filePath, (t) ->
                  t._id = t.path
                  db.put(t)
                  ))
