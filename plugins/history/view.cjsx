React = require('react')
ReactDOM = require('react-dom')

module.exports.HistoryComponent=
class HistoryComponent extends React.Component
  constructor: ->
    @props = {'history': null}

  render: ->
    <div className="history">
      <div className="form-group left">
        <button onClick={@props.history.back.bind(@props.history)} className="withripple"><i className="material-icons previous">keyboard_arrow_left</i></button>
      </div>
      <div className="form-group">
        <button onClick={@props.history.next.bind(@props.history)} className="withripple"><i className="material-icons next">keyboard_arrow_right</i></button>
      </div>
    </div>

module.exports.show = (history, element) ->
  ReactDOM.render(
    <HistoryComponent history=history />,
    element
  )
