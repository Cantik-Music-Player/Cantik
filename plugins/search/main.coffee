require 'coffee-react/register'
SearchComponent = require('./view.cjsx').SearchComponent
showSearch = require('./view.cjsx').show

module.exports =
class Search
  constructor: (@pluginManager, @element) ->
    do @show

  show: ->
    showSearch(@, @element)
