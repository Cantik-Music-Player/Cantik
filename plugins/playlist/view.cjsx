React = require 'react'
ReactDOM = require 'react-dom'

module.exports.PlaylistComponent=
class PlaylistComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {
      tracklist: @props.playlist.tracklist,
      currentTrack: @props.playlist.tracklist[@props.playlist.tracklistIndex]
    }

    @props.playlist.on('tracklist_changed', @updateTracklist.bind(@))
    @props.playlist.on('track_changed', @updateCurrentTrack.bind(@))

  updateTracklist: (tracklist) ->
    @setState tracklist: tracklist

  updateCurrentTrack: (track) ->
    @setState currentTrack: track

  render: ->
    # Get track class
    for track in @state.tracklist
      if track is @state.currentTrack
        track.class = "info"
      else
        track.class = null

    <div id="playlist">
      <table className="table table-striped table-hover fixed">
        <thead>
          <tr>
            <th>Title</th>
            <th>Artist</th>
            <th>Album</th>
            <th>Duration</th>
          </tr>
        </thead>
      </table>
      <table className="table table-striped table-hover list">
        <tbody>
          {<tr className={track.class} key={track.metadata.title}>
            <td>{track.metadata.title}</td>
            <td>{track.metadata.artist[0]}</td>
            <td>{track.metadata.album}</td>
            <td>{track.metadata.duration}</td>
          </tr> for track in @state.tracklist}
        </tbody>
      </table>
    </div>

module.exports.show = (playlist, element) ->
  ReactDOM.render(
    <PlaylistComponent playlist=playlist />,
    element
  )
