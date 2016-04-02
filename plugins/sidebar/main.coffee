require 'coffee-react/register'
SidebarComponent = require('./view.cjsx').SidebarComponent
showSidebar = require('./view.cjsx').show

module.exports =
class Sidebar
  constructor: (@pluginManager, @element) ->
    @links = {}
    do @show

  show: ->
    showSidebar(@links, @element)

  addLink: (name, category, onClick, active, dataToggle) ->
    active = if active then true else false
    dataToggle = true if not dataToggle?
    @links[category] = [] if category not in Object.keys(@links)
    @links[category].push({'title': name, 'onClick': onClick, 'active': active, 'dataToggle': dataToggle})
    do @show
    active
