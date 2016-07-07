path = require 'path'
React = require 'react'
ReactDOM = require 'react-dom'
Artwork = require '../../src/artwork'

electron = require('electron')
remote = electron.remote
Menu = remote.Menu
MenuItem = remote.MenuItem

formatTime = require('../../src/utils').formatTime


module.exports.ImageComponent=
class ImageComponent extends React.Component
  constructor: (props) ->
    super props

    userData = remote.app.getPath 'userData'

    if not @props.album?
      coverPath = "file:///#{userData}/images/artists/".replace(/\\/g, '/')
      @state = image: "#{coverPath}#{@props.artist}"

      Artwork.getArtistImage(@props.artist, (path) =>
        @setState image: path + '?')
    else
      coverPath = "file:///#{userData}/images/albums/".replace(/\\/g, '/')
      @state = image: "#{coverPath}#{@props.artist} - #{@props.album}"

      Artwork.getAlbumImage(@props.artist, @props.album, (path) =>
        @setState image: path + '?')

  render: ->
    if not @props.album?
      <div className="figure" onClick={@props.onClick}>
        <div className="fallback-artist">
          <div className="image" ref="image" style={{backgroundImage: "url('#{@state.image}')"}}></div>
        </div>
        <div className="caption">{@props.artist}</div>
      </div>
    else
      <div className="figure" onClick={@props.onClick}>
        <div className="fallback-album">
          <div className="image" style={{backgroundImage: "url('#{@state.image}')"}}></div>
        </div>
        <div className="caption">{@props.album}</div>
      </div>


module.exports.LocalLibraryComponent=
class LocalLibraryComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {
      showing: 'loading'
    }

    @temporaryCache = null
    @stopRendering = false

    do @renderArtistsList

    @props.localLibrary.on('library_path_change', =>
      do @renderArtistsList)

    @props.localLibrary.on('library_loading', =>
      @max = 0
      @stopRendering = true
      @setState showing: 'loading')

    @props.localLibrary.on('totreat_updated', (toTreat) =>
      @max = toTreat if toTreat > @max
      done = @max - toTreat
      @renderProgress(done, @max))

    @props.localLibrary.on('library_loaded', =>
      do @renderArtistsList)

    @props.localLibrary.on('go_home', =>
      do @renderArtistsList)

    @props.localLibrary.on('filter', (filter) =>
      @filterLibrary filter)

  renderMessage: (msg) ->
    <div className="msg-info">
      <h1>{msg}</h1>
    </div>

  renderLoading: ->
    <div className="sk-folding-cube loading">
      <div className="sk-cube1 sk-cube"></div>
      <div className="sk-cube2 sk-cube"></div>
      <div className="sk-cube4 sk-cube"></div>
      <div className="sk-cube3 sk-cube"></div>
    </div>

  renderProgress: (done, max) ->
    @temporaryCache = <div className="progress">
      <div className="sk-folding-cube loading">
        <div className="sk-cube1 sk-cube"></div>
        <div className="sk-cube2 sk-cube"></div>
        <div className="sk-cube4 sk-cube"></div>
        <div className="sk-cube3 sk-cube"></div>
      </div>
      <div className="progress-txt">
        <h3>Scanning... {done} / {max}</h3>
      </div>
    </div>
    @setState showing: 'cache'

  filterLibrary: (filter) =>
    @props.localLibrary.history.addHistoryEntry(@filterLibrary.bind(@, filter))
    @setState showing: 'loading'

    @props.localLibrary.search(filter, (tracks) =>
      @temporaryCache = @buildTrackList(tracks, null, null, null, filter)
      @setState showing: 'cache')

  addTracksToPlaylist: (trackToPlay, tracks) ->
    tracksDoc = (track.doc for track in tracks)

    @props.localLibrary.pluginManager.plugins.playlist.cleanPlaylist()
    @props.localLibrary.pluginManager.plugins.playlist.addTracks(tracksDoc)
    @props.localLibrary.pluginManager.plugins.playlist.tracklistIndex = -1 + tracks.indexOf trackToPlay
    @props.localLibrary.pluginManager.plugins.player.next()

  addTrackToPlaylist: (track) ->
    track = track.doc
    @props.localLibrary.pluginManager.plugins.playlist.addTracks([track])

  popupMenu: (menu) ->
    menu.popup(remote.getCurrentWindow())

  buildTrackList: (tracks, artist, album, coverPath, searchQuery) ->
    # Add menu for each track
    tracksDOM = []
    for track in tracks
      do (track) =>
        # MENU
        menu = new Menu()
        menu.append(new MenuItem({ label: 'Add to playlist', click: =>
          @addTrackToPlaylist(track)}))

        tempTrack = <tr onDoubleClick={@addTracksToPlaylist.bind(@, track, tracks)} onContextMenu={@popupMenu.bind(@, menu)}>
          <td>{track.doc.metadata.track.no}</td>
          <td>{track.doc.metadata.title}</td>
          {<td>{track.doc.metadata.album}</td> if searchQuery?}
          {<td>{track.doc.metadata.artist[0]}</td> if searchQuery?}
          <td>{formatTime(track.doc.metadata.duration)}</td>
        </tr>

        tracksDOM.push(tempTrack)

    <div className="album">
      <div className="album-background" style={{backgroundImage: "url('#{coverPath}#{artist} - #{album}')"}}>
      </div>
      <div className="album-container">
        <div className="cover">
          <img draggable="false" src="" className="cover" />
        </div>

        <div className="album-info">
          {<h1 className="title"><b>{album}</b> - {artist}</h1> if not searchQuery?}
          {<h1 className="title">Results for <b>"{searchQuery}"</b></h1> if searchQuery?}

          <p className="description"></p>
        </div>

        <table className="table table-striped table-hover">
          <thead>
            <tr>
              <th>#</th>
              <th>Title</th>
              {<th>Album</th> if searchQuery?}
              {<th>Artist</th> if searchQuery?}
              <th>Duration</th>
            </tr>
          </thead>
          <tbody>
            {tracksDOM}
          </tbody>
        </table>
      </div>
    </div>

  renderAlbum: (artist, album) ->
    @props.localLibrary.history.addHistoryEntry(@renderAlbum.bind(@, artist, album))
    @setState showing: 'loading'

    @props.localLibrary.getAlbumTracks(artist, album, (tracks) =>
      Artwork.getAlbumImage(artist, album)
      coverPath = "file:///#{@props.localLibrary.userData}/images/albums/".replace(/\\/g, '/')
      @temporaryCache = @buildTrackList(tracks, artist, album, coverPath)
      @setState showing: 'cache')

  renderAlbumsList: (artist) ->
    @props.localLibrary.history.addHistoryEntry(@renderAlbumsList.bind(@, artist))
    @setState showing: 'loading'

    @props.localLibrary.getAlbums(artist, (albums) =>
      coverPath = "file:///#{@props.localLibrary.userData}/images/albums/".replace(/\\/g, '/')
      @temporaryCache = <div>
        <div className="figure" onClick={@renderAlbum.bind(@, artist, "All tracks")}>
          <div className="fallback-album">
            <div className="image-composite">
              {<img src={"#{coverPath}#{artist} - #{albums[0]}"} /> if albums[0]?}
              {<img src={"#{coverPath}#{artist} - #{albums[1]}"} /> if albums[1]?}
              {<img src={"#{coverPath}#{artist} - #{albums[2]}"} /> if albums[2]?}
              {<img src={"#{coverPath}#{artist} - #{albums[3]}"} /> if albums[3]?}
            </div>
          </div>
          <div className="caption">All tracks</div>
        </div>
        {<ImageComponent onClick={@renderAlbum.bind(@, artist, album)} artist=artist album=album /> for album in albums}
      </div>
      @setState showing: 'cache')

  renderArtistsList: ->
    @props.localLibrary.history.addHistoryEntry(@renderArtistsList.bind(@))
    @setState showing: 'loading'

    @props.localLibrary.getArtists((artists) =>
      if not @stopRendering
        if artists.length is 0 and @props.localLibrary.localLibrary is ''
          @setState {showing: 'msg', msg: 'You need to set your music library path in settings'}
        else if artists.length is 0
          @setState {showing: 'msg', msg: 'Empty library'}
        else
          @temporaryCache = <div>
            {<ImageComponent onClick={@renderAlbumsList.bind(@, artist)} artist=artist /> for artist in artists}
          </div>
          @setState showing: 'cache'
      else
        @stopRendering = false)

  render: ->
    if @state.showing is 'loading'
      <div className="local-library">
        {do @renderLoading}
      </div>
    else if @state.showing is 'msg'
      <div className="local-library">
        {@renderMessage @state.msg}
      </div>
    else if @state.showing is "cache"
      <div className="local-library">
        {@temporaryCache}
      </div>

module.exports.show = (localLibrary, element) ->
  ReactDOM.render(
    <LocalLibraryComponent localLibrary=localLibrary />,
    element
  )
