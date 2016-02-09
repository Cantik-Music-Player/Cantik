fs = require('fs')

module.exports =
class Sidebar
  constructor: ->
    $('head').append( $('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('body').append($.parseHTML(html))

  addLink: (name, category) ->
    # Create category
    $('#sidebar ul').append("<h4 class='#{category}'>#{category}</h4>") if not $("#sidebar ul h4.#{category}").length

    # Get element to add after
    lastLi = null
    lastElement = null
    found = false
    for element in $("#sidebar ul").children()
      if found and $(element).is('h4') # We have found the correct h4 and reach another one
        # return last li
        lastLi = $(lastElement)
        break
      found = true if $(element).attr('class') == category and $(element).is('h4') # Found the correct h4
      lastElement = element # Store last element

    lastLi = lastLi or $("#sidebar ul h4.#{category}") # Default last li to h4

    # Create link
    if $("#sidebar ul li.active").length
      lastLi.after("<li><a class='withripple' href='#' data-toggle='pill' href='##{name}'>#{name}</a></li>")
    else  # Set first link as active
      lastLi.after("<li class='active'><a class='withripple' href='#' data-toggle='pill' href='##{name}'>#{name}</a></li>")
