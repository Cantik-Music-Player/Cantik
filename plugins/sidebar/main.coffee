require 'coffee-react/register'
SidebarComponent = require('./view.cjsx').SidebarComponent
showSidebar = require('./view.cjsx').show
normalizeString = require('../../src/utils').normalizeString

module.exports =
class Sidebar
  constructor: (@pluginManager, @element) ->
    @links = {}
    do @show

  show: ->
    showSidebar(@links, @element)

  changeTab: (tabName) ->
    id = normalizeString tabName
    @element.querySelector(".panel .panel-body ul #sidebar-#{id} a").click()

  addLink: (name, category, onClick, active, dataToggle) ->
    active = if active then true else false
    dataToggle = true if not dataToggle?
    @links[category] = [] if category not in Object.keys(@links)

    # Call given onclick after adding tab to history
    onClickWithHistory = (e) =>
      target = e.target
      @pluginManager.plugins.history.addHistoryEntry(-> target.click())
      do onClick if onClick?

    @links[category].push({'title': name, 'onClick': onClickWithHistory, 'active': active, 'dataToggle': dataToggle})
    do @show
    active
