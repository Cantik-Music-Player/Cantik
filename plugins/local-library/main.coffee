fs = require('fs')
remote = require('remote')
app = remote.require('app')
Track = require('../../src/track')
Artwork = require('../../src/artwork')
path = require('path')

module.exports =
class LocalLibrary
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    @indexHtml = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    @albumHtml = fs.readFileSync(__dirname + '/html/album.html', 'utf8')
    @element = @pluginManager.plugins.centralarea.addPanel('Local Library', 'Source', @indexHtml)

    do @initDB
    do @showArtistList

    # TODO(Use settings)
    @localLibrary = '/media/omnius/Music'
    #@parseLibrary @localLibrary

  showArtistList: ->
    localLibrary = @
    @element.html(@indexHtml)
    @getArtists (artists) ->
      for artist in artists.sort()
        Artwork.getArtistImage(artist)
        localLibrary.element.append("""<div class="figure">
          <div class="image" style="background-image: url('#{app.getPath('userData')}/images/artists/#{artist}');"></div>
          <div class="caption">#{artist}</div>
        </div>
        """)
      localLibrary.element.find('div.figure').click(->
        localLibrary.showAlbumsList($(this).find('.caption').text()))

  getArtists: (callback) ->
    @db.allDocs({include_docs: true, descending: true}, (err, doc) ->
      artists = []
      for row in doc.rows
        if row.doc.metadata?.artist?
          for a in row.doc.metadata.artist
            artists.push(a) if a not in artists
      callback artists)

  showAlbumsList: (artist) ->
    localLibrary = @
    @element.html(@indexHtml)
    @getAlbums(artist, (albums) ->
      for album in albums.sort()
        Artwork.getAlbumImage(artist, album)
        localLibrary.element.append("""<div class="figure">
          <div class="image" style="background-image: url('#{app.getPath('userData')}/images/albums/#{artist} - #{album}');"></div>
          <div class="caption">#{album}</div>
        </div>
        """)
      localLibrary.element.find('div.figure').click(->
        localLibrary.showAlbumTracksList(artist, $(this).find('.caption').text())))

  getAlbums: (artist, callback) ->
    @db.query('artist/artist', {key: artist, include_docs: true}).then((result) ->
      albums = []
      for row in result.rows
        if row.doc.metadata?.album?
          albums.push(row.doc.metadata.album) if row.doc.metadata.album not in albums
      callback albums)

  showAlbumTracksList: (artist, album) ->
    element = @element
    html = @albumHtml
    @getAlbumTracks(artist, album, (tracks) ->
      Artwork.getAlbumImage(artist, album)
      element.html(html)
      element.find('img.cover').attr("src", "#{app.getPath('userData')}/images/albums/#{artist} - #{album}")
      element.find('.title').html("<b>#{album}</b> - #{artist}")
      for track in tracks
        element.find('tbody').append("""
        <tr>
          <td>#{track.doc.metadata.track.no}</td>
          <td>#{track.doc.metadata.title}</td>
          <td>#{track.doc.metadata.duration}</td>
        </tr>
        """))

  getAlbumTracks: (artist, album, callback) ->
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
            new Track(filePath, (t) ->
              t._id = t.path
              db.put(t)
              )
