require 'coffee-react/register'
CentralAreaComponent = require('./view.cjsx').CentralAreaComponent
showCentralArea = require('./view.cjsx').show

normalizeString = require('../../src/utils').normalizeString

module.exports =
class CentralArea
  constructor: (@pluginManager, @element) ->
    @panels = []
    do @show

  show: ->
    showCentralArea(@, @element)

  addPanel: (name, category, sidebarClick, sidebarForceActive) ->
    # Add label to sidebar
    active = @pluginManager.plugins.sidebar.addLink(name, category,
                                                    sidebarClick,
                                                    sidebarForceActive)

    @panels.push({name: name, active: active})
    centralArea = do @show

    # Return dom element
    centralArea.querySelector("##{normalizeString(name)}")
