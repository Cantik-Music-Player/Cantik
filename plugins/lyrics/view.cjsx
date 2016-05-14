React = require 'react'
ReactDOM = require 'react-dom'

module.exports.PlaylistComponent=
class LyricsComponent extends React.Component
  constructor: (props) ->
    super props

  render: ->
    <div id="lyrics">
      <h1 className="title"><b>{@props.lyrics.title}</b> - {@props.lyrics.artist}</h1>

      {@props.lyrics.lyrics}
    </div>

module.exports.show = (lyrics, element) ->
  ReactDOM.render(
    <LyricsComponent lyrics=lyrics />,
    element
  )
