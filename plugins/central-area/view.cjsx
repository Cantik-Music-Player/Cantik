React = require 'react'
ReactDOM = require 'react-dom'
normalizeString = require('../../src/utils').normalizeString

module.exports.CentralAreaComponent=
class CentralAreaComponent extends React.Component
  constructor: (props) ->
    super props

  render: ->
    <div className="panel panel-default" id="content">
      <div className="panel-body">
        <div className="tab-content">
          {<div className="tab-pane" id={normalizeString name}></div> for name in @props.centralArea.panels}
        </div>
      </div>
    </div>

module.exports.show = (centralArea, element) ->
  c = ReactDOM.render(
    <CentralAreaComponent centralArea=centralArea />,
    element
  )

  ReactDOM.findDOMNode(c)
