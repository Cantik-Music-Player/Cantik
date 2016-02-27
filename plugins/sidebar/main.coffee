fs = require('fs')
React = require('react')
ReactDOM = require('react-dom')
SidebarComponent = require('./view.cjsx')

module.exports =
class Sidebar
  constructor: (@pluginManager, @element) ->
    @links = {}
    do @show

  show: ->
    ReactDOM.render(
      <SidebarComponent links=@links />,
      @element
    )

  addLink: (name, category, onClick, active) ->
    @links[category] = [] if category not in Object.keys(@links)
    @links[category].push({'title': name, 'onClick': onClick, 'active': active})
    do @show
