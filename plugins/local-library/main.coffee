fs = require('fs')
remote = require('remote')
app = remote.require('app')
Track = require('../../src/track')
path = require('path')

module.exports =
class LocalLibrary
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    @element = @pluginManager.plugins.centralarea.addPanel('Local Library', 'Source', html)
    do @initDB

    do @showArtistList

    # TODO(Use settings)
    @localLibrary = '/media/omnius/Music'
    @parseLibrary @localLibrary

  showArtistList: ->
    element = @element
    @getArtists (artists) ->
      for artist in artists.sort()
        element.append("""<div class="figure">
          <div class="image" style="background-image: url('#{app.getPath('userData')}/images/artists/#{artist}');"></div>
          <div class="caption">#{artist}</div>
        </div>
        """)

  getArtists: (callback) ->
    @db.allDocs({include_docs: true, descending: true}, (err, doc) ->
      artists = []
      for row in doc.rows
        if row.doc.metadata.artist?
          for a in row.doc.metadata.artist
            artists.push(a) if a not in artists
      callback artists)

  initDB: ->
    @db = new PouchDB('library')

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
            new Track(filePath, (t) ->
              t._id = t.path
              db.put(t, (err, data) ->
                if not err
                  t.getArtistImage()
                  t.getAlbumImage()
                )
              )
