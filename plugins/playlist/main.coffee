fs = require('fs')
events = require('events')
Track = require('../../src/track')

module.exports =
class Playlist
  constructor: (@pluginManager) ->
    events.EventEmitter.call(this)

    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    @history = @pluginManager.plugins.history


    @element = @pluginManager.plugins.centralarea.addPanel('Playlist', 'Now Playing', html)
    @trackList = []
    @trackListPlayed = []
    @trackIndex = -1
    @trackPlayedIndex = -1
    @random = false
    @repeat = null

  setRandom: (randomState) ->
    @random = randomState
    @emit('randomchange', randomState)

  setRepeat: (repeatState) ->
    @repeat = randomState
    @emit('repeatchange', repeatState)

  addTrack: (track) ->
    @trackList.push(track)
    @element.find('table.list').append("""
    <tr>
      <td>#{track.metadata.title}</td>
      <td>#{track.metadata.artist[0]}</td>
      <td>#{track.metadata.album}</td>
      <td>#{track.metadata.duration}</td>
    </tr>
    """)

  addTracks: (tracks) ->
    @addTrack t for t in tracks

  cleanPlaylist: ->
    @element.find('table.list').html("")
    @trackList = []
    @trackIndex = -1
    @trackListPlayed = []

  getNextTrack: ->
    if @trackPlayedIndex < @trackListPlayed.length - 1
      @trackPlayedIndex++
      @trackIndex = @trackList.indexOf(@trackListPlayed[@trackPlayedIndex])
    else if not @random
      if @trackIndex < @trackList.length - 1
        @trackIndex++
        @trackListPlayed.push(@trackList[@trackIndex])
        @trackPlayedIndex = @trackListPlayed.length - 1
    else if @trackListPlayed.length < @trackList.length
      while true
        @trackIndex = Math.floor(Math.random() * @trackList.length);
        break if @trackList[@trackIndex] not in @trackListPlayed

      @trackListPlayed.push(@trackList[@trackIndex])
      @trackPlayedIndex = @trackListPlayed.length - 1

    @element.find('table.list tr').removeClass("info")
    $(@element.find('table.list tr')[@trackIndex]).addClass("info")
    @trackList[@trackIndex]

  getLastTrack: ->
    if @trackPlayedIndex > 0
      @trackPlayedIndex--
      @trackIndex = @trackList.indexOf(@trackListPlayed[@trackPlayedIndex])
    else if not @random
      if @trackIndex > 0
        @trackIndex--
        @trackListPlayed.splice(@trackPlayedIndex, 0, @trackList[@trackIndex])

    @element.find('table.list tr').removeClass("info")
    $(@element.find('table.list tr')[@trackIndex]).addClass("info")
    @trackList[@trackIndex]

Playlist.prototype.__proto__ = events.EventEmitter.prototype
