React = require 'react'
ReactDOM = require 'react-dom'

module.exports.PlaylistComponent=
class PlaylistComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {
      trackList: @props.playlist.trackList,
      currentTrack: @props.playlist.trackList[@props.playlist.trackIndex]
    }

    @props.playlist.on('tracklist_changed', @updateTrackList.bind(@))
    @props.playlist.on('track_changed', @updateCurrentTrack.bind(@))

  updateTrackList: (trackList) ->
    @setState trackList: trackList

  updateCurrentTrack: (track) ->
    @setState currentTrack: track

  render: ->
    # Get track class
    for track in @state.trackList
      if track is @state.currentTrack
        track.class = "info"
      else
        track.class = null

    console.log @state.trackList

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
          </tr> for track in @state.trackList}
        </tbody>
      </table>
    </div>

module.exports.show = (playlist, element) ->
  ReactDOM.render(
    <PlaylistComponent playlist=playlist />,
    element
  )
