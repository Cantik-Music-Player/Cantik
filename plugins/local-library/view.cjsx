path = require 'path'
React = require 'react'
ReactDOM = require 'react-dom'
Artwork = require '../../src/artwork'

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
      @stopRendering = true
      @setState showing: 'loading')

    @props.localLibrary.on('library_loaded', =>
      do @renderArtistsList)

    @props.localLibrary.on('go_home', =>
      do @renderArtistsList)

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

  addTracksToPlaylist: (trackToPlay, tracks) ->
    tracksDoc = (track.doc for track in tracks)

    @props.localLibrary.pluginManager.plugins.playlist.cleanPlaylist()
    @props.localLibrary.pluginManager.plugins.playlist.addTracks(tracksDoc)
    @props.localLibrary.pluginManager.plugins.playlist.tracklistIndex = -1 + tracks.indexOf trackToPlay
    @props.localLibrary.pluginManager.plugins.player.next()

  renderAlbum: (artist, album) ->
    @props.localLibrary.history.addHistoryEntry(@renderAlbum.bind(@, artist, album))
    @setState showing: 'loading'

    @props.localLibrary.getAlbumTracks(artist, album, (tracks) =>
      Artwork.getAlbumImage(artist, album)
      coverPath = "file:///#{@props.localLibrary.userData}/images/albums/".replace(/\\/g, '/')
      @temporaryCache = <div className="album">
        <div className="album-background" style={{backgroundImage: "url('#{coverPath}#{artist} - #{album}')"}}>
        </div>
        <div className="album-container">
          <div className="cover">
            <img draggable="false" src="" className="cover" />
          </div>

          <div className="album-info">
            <h1 className="title"><b>{album}</b> - {artist}</h1>

            <p className="description"></p>
          </div>

          <table className="table table-striped table-hover">
            <thead>
              <tr>
                <th>#</th>
                <th>Title</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              {<tr onDoubleClick={@addTracksToPlaylist.bind(@, track, tracks)}>
                <td>{track.doc.metadata.track.no}</td>
                <td>{track.doc.metadata.title}</td>
                <td>{track.doc.metadata.duration}</td>
              </tr> for track in tracks}
            </tbody>
          </table>
        </div>
      </div>
      @setState showing: 'cache')

  renderAlbumsList: (artist) ->
    @props.localLibrary.history.addHistoryEntry(@renderAlbumsList.bind(@, artist))
    @setState showing: 'loading'

    @props.localLibrary.getAlbums(artist, (albums) =>
      Artwork.getAlbumImage(artist, album) for album in albums
      coverPath = "file:///#{@props.localLibrary.userData}/images/albums/".replace(/\\/g, '/')
      @temporaryCache = <div>
        {<div className="figure" onClick={@renderAlbum.bind(@, artist, album)}>
          <div className="fallback-album"><div className="image" style={{backgroundImage: "url('#{coverPath}#{artist} - #{album}')"}}></div></div>
          <div className="caption">{album}</div>
        </div> for album in albums}
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
          Artwork.getArtistImage(artist) for artist in artists
          coverPath = "file:///#{@props.localLibrary.userData}/images/artists/".replace(/\\/g, '/')
          @temporaryCache = <div>
            {<div className="figure" onClick={@renderAlbumsList.bind(@, artist)}>
              <div className="fallback-artist">
                <div className="image" style={{backgroundImage: "url('#{coverPath}#{artist}')"}}>
                </div>
              </div>
              <div className="caption">{artist}</div>
            </div> for artist in artists}
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
