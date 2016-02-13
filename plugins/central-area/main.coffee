fs = require('fs')

module.exports =
class CentralArea
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('body').append($.parseHTML(html))

  addPanel: (name, category, content) ->
    # Add label to sidebar
    @pluginManager.plugins.sidebar.addLink(name, category)

    name = name.replace(' ', '-').toLowerCase()

    # Add div
    $("#content").append("<div class='tab-pane' id='#{name}'></div>")
    $("#content ##{name}").html($.parseHTML(content))

    #Return element
    $("#content ##{name}")
