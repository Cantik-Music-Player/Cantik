events = require 'events'
request = require 'request'
require 'coffee-react/register'
LyricsComponent = require('./view.cjsx').LyricsComponent
showLyrics = require('./view.cjsx').show

module.exports =
class Lyrics
  constructor: (@pluginManager) ->
    events.EventEmitter.call(@)
    @element = @pluginManager.plugins.centralarea.addPanel('Lyrics', 'Now Playing')
    @title
    @artist
    @lyrics

    @pluginManager.plugins.player.on('track_changed', (track) =>
      @title = track.metadata.title
      @artist = track.metadata.artist[0]
      @lyrics = null
      @emit('lyrics_updated', @lyrics)
      @getLyrics(@title, @artist))

    do @show

  show: ->
    showLyrics(@, @element)

  getLyrics: (title, artist) ->
    re = / /g
    request({
      url: "https://www.musixmatch.com/lyrics/#{artist.replace(re, '-')}/#{title.replace(re, '-')}",
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
      }
    },
    (error, response, body) =>
      if !error && response.statusCode == 200
        re = /<p class="mxm-lyrics__content" data-reactid=".{1,5}">([^<]*)/
        m = re.exec(body)
        @lyrics = m[1]
        @emit('lyrics_updated', @lyrics)
    )

Lyrics.prototype.__proto__ = events.EventEmitter.prototype
