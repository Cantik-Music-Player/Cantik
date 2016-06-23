React = require 'react'
ReactDOM = require 'react-dom'

module.exports.PlaylistComponent=
class LyricsComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {
      title: @props.lyrics.title,
      artist: @props.lyrics.artist,
      lyrics: {__html: @props.lyrics.lyrics}
    }

    @props.lyrics.on('lyrics_updated', (lyrics) =>
      @setState title: @props.lyrics.title
      @setState artist: @props.lyrics.artist

      if lyrics?
        @setState lyrics: {__html: @props.lyrics.lyrics.replace(/(?:\r\n|\r|\n)/g, '<br />')}
      else
        @setState lyrics: [__html: null])

  render: ->
    if @state.lyrics.__html?
      <div id="lyrics">
        <h1 className="title"><b>{@state.title}</b> - {@state.artist}</h1>
        <div dangerouslySetInnerHTML={@state.lyrics} />
      </div>
    else
      <div id="lyrics">
        <div className="msg-info">
          <h1>No Lyrics</h1>
        </div>
      </div>

module.exports.show = (lyrics, element) ->
  ReactDOM.render(
    <LyricsComponent lyrics=lyrics />,
    element
  )
