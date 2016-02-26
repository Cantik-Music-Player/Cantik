fs = require('fs')

module.exports =
class Sidebar
  constructor: ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))
    $('body').append("<div class=\"panel panel-default\"  id='sidebar'></div>")
    test = require('./view')
    console.log test.SidebarComponent
