React = require('react')
ReactDOM = require('react-dom')
normalizeString = require('../../src/utils').normalizeString

module.exports.PlayerComponent=
class PlayerComponent extends React.Component
  constructor: (props) ->
    super props
    @state = {
      'playing': @props.player.playing,
      'playingTrack': @props.player.playingTrack,
      'currentTime': @props.player.currentTime,
      'duration': @props.player.duration
    }

    @props.player.on('track_changed', @updatePlayingTrack.bind(@))
    @props.player.on('play_state_changed', @updatePlayingState.bind(@))

  updatePlayingTrack: ->
    @setState playingTrack: @props.player.playingTrack
    @refs.audioObject.load()

  updatePlayingState: ->
    @setState playing: @props.player.playing

    if @props.player.playing
      @refs.audioObject.play()
    else
      @refs.audioObject.pause()

  render: ->
    <div className="panel panel-default" id="player">
      <audio controls ref="audioObject" >
        {<source src={@state.playingTrack.path} /> if @state.playingTrack.path?}
      </audio>

      <p className="track-artist">
        <span className="title">{@state.playingTrack.metadata?.title}</span>
         -
        <span className="artist">{@state.playingTrack.metadata?.artist?[0]}</span>
      </p>
      <div className="panel-body">
        <div className="left-button">
          <button onClick={@props.player.back.bind(@props.player)}><i className="material-icons previous">skip_previous</i></button>
          {<button onClick={@props.player.play.bind(@props.player)}><i className="material-icons play">play_arrow</i></button> if not @state.playing}
          {<button onClick={@props.player.play.bind(@props.player)}><i className="material-icons play">pause</i></button> if @state.playing}
          <button onClick={@props.player.next.bind(@props.player)}><i className="material-icons next">skip_next</i></button>
        </div>

        <span className="elapsed-time"></span>

        <div className="progress">
          <div className="slider shor progressbar"></div>
        </div>

        <span className="total-time"></span>

        <div className="volume-container">
          <button className="volume-button"><i className="material-icons volume-icon">volume_up</i></button>

          <div className="slider shor volume"></div>
        </div>

        <div className="right-button">
          <button className="repeat"><i className="material-icons">repeat</i></button>
          <button className="random"><i className="material-icons">shuffle</i></button>
        </div>
      </div>
    </div>

module.exports.show = (player, element) ->
  ReactDOM.render(
    <PlayerComponent player=player />,
    element
  )
