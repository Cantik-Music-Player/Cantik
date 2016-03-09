React = require 'react'
ReactDOM = require 'react-dom'
normalizeString = require('../../src/utils').normalizeString

module.exports.CentralAreaComponent=
class CentralAreaComponent extends React.Component
  constructor: (props) ->
    super props

  render: ->
    # Format panels dict
    panels = {}
    for name, content of @props.panels
      panels[normalizeString name] = __html: content

    <div className="panel panel-default" id="content">
      <div className="panel-body">
        <div className="tab-content">
          {<div className="tab-pane" id={name} dangerouslySetInnerHTML={content}></div> for name, content of panels}
        </div>
      </div>
    </div>

module.exports.show = (panels, element) ->
  ReactDOM.render(
    <CentralAreaComponent panels=panels />,
    element
  )
