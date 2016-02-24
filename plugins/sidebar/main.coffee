fs = require('fs')

module.exports =
class Sidebar
  constructor: ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))
    $('body').append("<div class=\"panel panel-default\"  id='sidebar'></div>")
    require('./view.js')

  addLink: (name, category, onClick, forceActive) ->
    normalizedName = name.replace(' ', '-').toLowerCase()
    normalizedCat = category.replace(' ', '-').toLowerCase()

    # Create category
    $('#sidebar ul').append("<h4 class='#{normalizedCat}'>#{category}</h4>") if not $("#sidebar ul h4.#{category}").length

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

    lastLi = lastLi or $("#sidebar ul h4.#{normalizedCat}") # Default last li to h4

    # Create link
    element = null
    active = false
    if $("#sidebar ul li.active").length and not forceActive
      element = $("<li><a class='withripple' data-toggle='pill' href='##{normalizedName}'>#{name}</a></li>").insertAfter(lastLi)
    else  # Set first link as active
      $('#sidebar ul li').removeClass('active')
      element = $("<li class='active'><a class='withripple' data-toggle='pill' href='##{normalizedName}'>#{name}</a></li>").insertAfter(lastLi)
      active = true

    element.click(onClick) if onClick?
    active
