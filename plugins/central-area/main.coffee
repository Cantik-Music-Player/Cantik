require 'coffee-react/register'
CentralAreaComponent = require('./view.cjsx').CentralAreaComponent
showCentralArea = require('./view.cjsx').show

module.exports =
class CentralArea
  constructor: (@pluginManager, @element) ->
    @panels = {}
    do @show

  show: ->
    showCentralArea(@panels, @element)

  addPanel: (name, category, content, sidebarClick, sidebarForceActive) ->
    # Add label to sidebar
    @pluginManager.plugins.sidebar.addLink(name, category, sidebarClick, sidebarForceActive)

    @panels[name] = content
    do @show
