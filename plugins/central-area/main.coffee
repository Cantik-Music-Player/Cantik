fs = require('fs')

module.exports =
class CentralArea
  constructor: (@pluginManager) ->
    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('body').append($.parseHTML(html))

  addPanel: (name, category, content, sidebarClick, sidebarForceActive) ->
    # Add label to sidebar
    active = @pluginManager.plugins.sidebar.addLink(name, category, sidebarClick, sidebarForceActive)

    name = name.replace(' ', '-').toLowerCase()

    # Add div
    active = if active then "active" else ""

    if active is "active"
      $("#content .panel-body .tab-content .tab-pane").removeClass('active')

    $("#content .panel-body .tab-content").append("<div class='tab-pane #{active}' id='#{name}'></div>")
    $("#content .panel-body .tab-content ##{name}").html($.parseHTML(content))

    #Return element
    $("#content .panel-body .tab-content ##{name}")
