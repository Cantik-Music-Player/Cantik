events = require 'events'
fs = require 'fs'
electron = require('electron')
app = electron.remote.app
Track = require '../../src/track'
path = require 'path'

LocalLibraryComponent = require('./view.cjsx').LocalLibraryComponent
showLocalLibrary = require('./view.cjsx').show

PouchDB.plugin(require('pouchdb-quick-search'))

module.exports =
class LocalLibrary
  constructor: (@pluginManager) ->
    events.EventEmitter.call(@)

    @history = @pluginManager.plugins.history
    @loading = false
    @userData = app.getPath 'userData'
    @element = @pluginManager.plugins.centralarea.addPanel('Local Library',
                                                           'Source',
                                                           @goHome.bind(@),
                                                           true)

    do @initDB
    do @show

    @pluginManager.plugins.centralarea

    @localLibrary = @pluginManager.plugins.settings.addSetting('Local Library',
                                                               'Library Path',
                                                               'file', '')
    @parseLibrary @localLibrary if @localLibrary != ''

    # Avoid going home when local library was not showed
    @preventGoHome = false
    $('a[data-toggle="tab"][href="#local-library"]').on('shown.bs.tab', =>
      @preventGoHome = true)

    # Update library if path changes
    @pluginManager.plugins.settings.on('Local Library-Library Path-change',
                                       (path) =>
                                         @emit('library_loading', @)
                                         @flushDB(=>
                                           @artists = null
                                           @localLibrary = path
                                           @emit('library_path_change', @)
                                           @parseLibrary @localLibrary))

  filterLibrary: (query) ->
    @emit('filter', query)

  show: ->
    showLocalLibrary(@, @element)

  search: (query, callback) ->
    @db.search({
      query: query,
      fields: ['metadata.title', 'metadata.artist'],
      include_docs: true
    }).then((res) ->
      callback res.rows)

  goHome: ->
    @emit('go_home', @) if not @preventGoHome
    @preventGoHome = false

  getArtists: (callback) ->
    if not @artists or @artists?.length is 0
      @db.query('artistcount/artist', {reduce: true, group: true},
                (err, results) =>
                  @artists = (a.key for a in results.rows)
                  callback @artists)
    else
      callback @artists

  getAlbums: (artist, callback) ->
    @db.query('artist/artist', {key: artist, include_docs: true}).then(
      (result) ->
        albums = []
        for row in result.rows
          if row.doc.metadata?.album? and
             row.doc.metadata.album not in albums
            albums.push(row.doc.metadata.album)
        callback albums)

  getAlbumTracks: (artist, album, callback) ->
    if album is "All tracks"
      @db.query('artist/artist', {key: artist, include_docs: true}).then(
        (result) ->
          callback result.rows)
    else
      @db.query('album/album', {key: album, include_docs: true}).then((result) ->
        tracks = []
        for row in result.rows
          tracks.push(row) if row.doc.metadata?.artist? and
                              row.doc.metadata.artist[0] is artist
        callback tracks)

  initDB: (callback) ->
    @db = new PouchDB('library')
    @db.put({
      _id: '_design/artist',
      views: {
        'artist': {
          map: 'function (doc) { emit(doc.metadata.artist[0]); }'
        }
      }
    }, =>
      @db.put({
        _id: '_design/artistcount',
        views: {
          'artist': {
            map: 'function (doc) { emit(doc.metadata.artist[0]); }',
            reduce: '_count'
          }
        }
      }, =>
      @db.put({
        _id: '_design/album',
        views: {
          'album': {
            map: 'function (doc) { emit(doc.metadata.album); }'
          }
        }
      }, =>
        do callback if callback?)))

  flushDB: (callback) ->
    @db.destroy(=>
      @initDB callback)

  parseLibrary: (libraryPath) ->
    if libraryPath is @localLibrary
      @loading = true
      @docToCreate = []
      @toTreat = 0
      @emit('library_loading', @)

    files = fs.readdirSync(libraryPath)

    # Get the files
    for file in files
      if file[0] != '.'
        filePath = "#{libraryPath}/#{file}"
        stat = fs.statSync(filePath)

        if stat.isDirectory()
          @parseLibrary filePath
        else if path.extname(filePath) in ['.ogg', '.flac', '.aac',
                                           '.mp3', '.m4a']
          @toTreat++
          @emit('totreat_updated', @toTreat)
          do (filePath) =>
            @db.get(filePath, (err, data) =>
              if err?.status is 404
                new Track(filePath, (t) =>
                  t._id = t.path
                  @docToCreate.push(t)

                  @toTreat--
                  @emit('totreat_updated', @toTreat)
                  if @toTreat is 0
                    @db.bulkDocs(@docToCreate, =>
                      @loading = false
                      @emit('library_loaded', @))
                )
              else
                @toTreat--
                @emit('totreat_updated', @toTreat)
                if @toTreat is 0
                  @db.bulkDocs(@docToCreate, =>
                    @loading = false
                    @emit('library_loaded', @)))

    if libraryPath is @localLibrary and @toTreat is 0
      @loading = false
      @emit('library_loaded', @)

LocalLibrary.prototype.__proto__ = events.EventEmitter.prototype
