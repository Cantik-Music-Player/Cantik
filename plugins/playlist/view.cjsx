React = require 'react'
ReactDOM = require 'react-dom'

remote = require 'remote'
Menu = remote.require 'menu'
MenuItem = remote.require 'menu-item'

formatTime = require('../../src/utils').formatTime

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

    index = 0

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
        <tbody ref="tbody" onDragOver={@dragOver.bind(@)}>
          {<tr draggable="true" onDragEnd={@dragEnd.bind(@)} onDragStart={@dragStart.bind(@)}
               className={"#{track.class} track"} key={"#{track.metadata.title}#{index}"}
               data-id={index} ref={"track#{index}"}>
            <td>{track.metadata.title}</td>
            <td>{track.metadata.artist[0]}</td>
            <td>{track.metadata.album}</td>
            <td>{formatTime(track.metadata.duration)}</td>
            {index++}
          </tr> for track in @state.tracklist}
        </tbody>
      </table>
    </div>

  componentDidUpdate: ->
    # Add menu for each track
    index = 0
    for _, track of @refs
      do (index) =>
        # MENU
        menu = new Menu()
        menu.append(new MenuItem({ label: 'Delete from playlist', click: =>
          @props.playlist.deleteTrack index}))

        track.addEventListener('contextmenu', (e) ->
          menu.popup(remote.getCurrentWindow()))

      index++

  dragStart: (e) ->
    @placeholder = document.createElement("tr")
    @placeholder.className = e.currentTarget.className
    @placeholder.innerHTML = e.currentTarget.innerHTML
    @dragged = e.currentTarget
    e.dataTransfer.effectAllowed = 'move'

  dragEnd: (e) ->
    @dragged.parentNode.removeChild(@placeholder)

    from = Number(@dragged.dataset.id)
    to = Number(@over.dataset.id)
    to-- if from < to
    to++ if @nodePlacement is 'after'
    @props.playlist.moveTrack(from, to)

  dragOver: (e) ->
    e.preventDefault()
    @dragged.style.display = "none"

    if e.target.className != "placeholder" and e.target != @refs.tbody
      # Inside the dragOver method
      relY = e.clientY - e.target.parentNode.parentNode.offsetTop
      height = e.target.parentNode.parentNode.offsetHeight / 2

      @over = e.target.parentNode

      if relY > height
        @nodePlacement = "after"
        e.target.parentNode.parentNode.insertBefore(@placeholder, e.target.parentNode.nextElementSibling)
      else if relY < height
        @nodePlacement = "before"
        e.target.parentNode.parentNode.insertBefore(@placeholder, e.target.parentNode)

module.exports.show = (playlist, element) ->
  ReactDOM.render(
    <PlaylistComponent playlist=playlist />,
    element
  )
