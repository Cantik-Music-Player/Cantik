fs = require('fs')

module.exports =
class CentralArea
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('body').append($.parseHTML(html))

  addPanel: (name, category, content, sidebarClick) ->
    # Add label to sidebar
    active = @pluginManager.plugins.sidebar.addLink(name, category, sidebarClick)

    name = name.replace(' ', '-').toLowerCase()

    # Add div
    active = if active then "active" else ""
    $("#content .panel-body .tab-content").append("<div class='tab-pane #{active}' id='#{name}'></div>")
    $("#content .panel-body .tab-content ##{name}").html($.parseHTML(content))

    #Return element
    $("#content .panel-body .tab-content ##{name}")
