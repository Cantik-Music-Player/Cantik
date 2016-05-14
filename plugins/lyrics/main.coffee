require 'coffee-react/register'
LyricsComponent = require('./view.cjsx').LyricsComponent
showLyrics = require('./view.cjsx').show

module.exports =
class Lyrics
  constructor: (@pluginManager) ->
    @element = @pluginManager.plugins.centralarea.addPanel('Lyrics', 'Now Playing')
    @title
    @artist
    @lyrics

    do @show

  show: ->
    showLyrics(@, @element)

  getLyrics: (title, artist) ->
    
