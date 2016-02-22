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
    @history = @pluginManager.plugins.history

    @loading = false

    @element = @pluginManager.plugins.centralarea.addPanel('Local Library', 'Source', @indexHtml,
                                                           @.showArtistList.bind(@), true)

    do @initDB
    do @showArtistList

    # TODO(Use settings)
    @localLibrary = '/media/omnius/Music'
    @parseLibrary @localLibrary

  reloadMissingimage: (imageUrl) ->
    @element.find('.figure div.image').each(->
      elementPath = $(@).css('background-image').replace('url(file://', '')
      elementPath = decodeURI elementPath.substring(0, elementPath.length - 1)
      if elementPath == imageUrl
        console.log "url(file:/"+imageUrl+"adkjhfdskjfhsl)"
        $(@).css('background-image', "url(file:/#{encodeURIComponent(imageUrl)}?)"))

    @element.find('img.cover').attr('src', "#{imageUrl}?")

  showArtistList: ->
    if not @loading
      @loading = true
      localLibrary = @
      @history.addHistoryEntry({
        "plugin": @,
        "function": "showArtistList",
        "args": []
      })
      @getArtists (artists) ->
        localLibrary.element.html(localLibrary.indexHtml)
        for artist in artists.sort()
          Artwork.getArtistImage(artist, localLibrary.reloadMissingimage.bind(localLibrary))
          coverPath = "#{app.getPath('userData')}/images/artists/#{artist}"
          coverPath = coverPath.replace('"', '\\"').replace("'", "\\'")
          localLibrary.element.append("""<div class="figure">
            <div class="fallback-artist"><div class="image" style="background-image: url('#{coverPath}');"></div></div>
            <div class="caption">#{artist}</div>
          </div>
          """)
        localLibrary.element.find('div.figure').click(->
          localLibrary.showAlbumsList($(this).find('.caption').text()))
        localLibrary.loading = false
        true  # Return true to be sure not to stop the event propagation

  getArtists: (callback) ->
    if not @artists
      localLibrary = @
      @db.query('artistcount/artist', {reduce: true, group: true}, (err, results) ->
        localLibrary.artists = (a.key for a in results.rows)
        callback localLibrary.artists)
    else
      callback @artists

  showAlbumsList: (artist) ->
    localLibrary = @
    @history.addHistoryEntry({
      "plugin": @,
      "function": "showAlbumsList",
      "args": [artist]
    })
    @getAlbums(artist, (albums) ->
      localLibrary.element.html(localLibrary.indexHtml)
      covers = []
      for album in albums.sort()
        Artwork.getAlbumImage(artist, album, localLibrary.reloadMissingimage.bind(localLibrary))
        coverPath = "#{app.getPath('userData')}/images/albums/#{artist} - #{album}"
        coverPath = coverPath.replace('"', '\\"').replace("'", "\\'")
        covers.push(coverPath)
        localLibrary.element.append("""<div class="figure">
          <div class="fallback-album"><div class="image" style="background-image: url('#{coverPath}');"></div></div>
          <div class="caption">#{album}</div>
        </div>
        """)

      # All tracks
      localLibrary.element.prepend("""<div class="figure">
        <div class="fallback-album"><div class="image-composite"></div></div>
        <div class="caption">All tracks</div>
      </div>
      """)
      i = 0
      for cover in covers
        if fs.existsSync(cover)
          i++
          localLibrary.element.find('div.figure .image-composite').append("<img src='#{cover}'/>")
          if i == 4
            break

      # Click event
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
    localLibrary = @
    element = @element
    html = @albumHtml
    @history.addHistoryEntry({
      "plugin": @,
      "function": "showAlbumTracksList",
      "args": [artist, album]
    })
    @getAlbumTracks(artist, album, (tracks) ->
      Artwork.getAlbumImage(artist, album, localLibrary.reloadMissingimage.bind(localLibrary))
      element.html(html)
      element.find('.album-background').css("background-image", "url('#{app.getPath('userData')}/images/albums/#{artist} - #{album}')")
      if fs.existsSync("#{app.getPath('userData')}/images/albums/#{artist} - #{album}")
        element.find('img.cover').attr("src", "#{app.getPath('userData')}/images/albums/#{artist} - #{album}")
      else
        element.find('img.cover').attr("src", "../plugins/local-library/images/cd.svg").css('width', '100%')
      element.find('.title').html("<b>#{album}</b> - #{artist}")
      i = 0
      for track in tracks
        element.find('tbody').append("""
        <tr class="#{i}">
          <td>#{track.doc.metadata.track.no}</td>
          <td>#{track.doc.metadata.title}</td>
          <td>#{track.doc.metadata.duration}</td>
        </tr>
        """)
        i++
      element.find('tbody tr').dblclick(->
        localLibrary.pluginManager.plugins.playlist.cleanPlaylist()
        localLibrary.pluginManager.plugins.playlist.addTracks(t.doc for t in tracks)
        localLibrary.pluginManager.plugins.playlist.trackIndex = parseInt($(@).attr('class')) - 1
        localLibrary.pluginManager.plugins.player.next()))

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
              if not err and not data
                new Track(filePath, (t) ->
                  t._id = t.path
                  db.put(t)
                  ))
