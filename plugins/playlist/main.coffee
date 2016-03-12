events = require 'events'

require 'coffee-react/register'
PlaylistComponent = require('./view.cjsx').PlaylistComponent
showPlaylist = require('./view.cjsx').show

module.exports =
class Playlist
  constructor: (@pluginManager) ->
    events.EventEmitter.call(this)

    @element = @pluginManager.plugins.centralarea.addPanel('Playlist', 'Now Playing')
    @trackList = []
    @trackListPlayed = []
    @trackIndex = -1
    @trackPlayedIndex = -1
    @random = false
    @repeat = null

    do @show

  show: ->
    showPlaylist(@, @element)

  setRandom: (randomState) ->
    @trackListPlayed = [@trackList[@trackIndex]]
    @trackPlayedIndex = 0
    @random = randomState
    @emit('random_change', randomState)

  switchRepeatState: ->
    if @repeat is null
      @repeat = 'all'
    else if @repeat is 'all'
      @repeat = 'one'
    else
      @repeat = null
    @emit('repeat_change', @repeat)

  addTrack: (track) ->
    @trackList.push(track)
    @emit('tracklist_changed', @trackList)

  addTracks: (tracks) ->
    @addTrack t for t in tracks

  cleanPlaylist: ->
    @trackList = []
    @trackIndex = -1
    @trackListPlayed = []
    @emit('tracklist_changed', @trackList)

  getNextTrack: ->
    if @trackPlayedIndex < @trackListPlayed.length - 1
      @trackPlayedIndex++
      @trackIndex = @trackList.indexOf(@trackListPlayed[@trackPlayedIndex])
    else if not @random
      if @trackIndex < @trackList.length - 1
        @trackIndex++
        @trackListPlayed.push(@trackList[@trackIndex])
        @trackPlayedIndex = @trackListPlayed.length - 1
      else if @repeat is 'all'
        @trackIndex = 0
        @trackListPlayed = [@trackList[@trackIndex]]
        @trackPlayedIndex = 0
    else
      if @repeat is 'all' and @trackListPlayed.length is @trackList.length
        @trackListPlayed = []
      if @trackListPlayed.length < @trackList.length
        while true
          @trackIndex = Math.floor(Math.random() * @trackList.length);
          break if @trackList[@trackIndex] not in @trackListPlayed

        @trackListPlayed.push(@trackList[@trackIndex])
        @trackPlayedIndex = @trackListPlayed.length - 1

    @emit('track_changed', @trackList[@trackIndex])
    @trackList[@trackIndex]

  getLastTrack: ->
    if @trackPlayedIndex > 0
      @trackPlayedIndex--
      @trackIndex = @trackList.indexOf(@trackListPlayed[@trackPlayedIndex])
    else if not @random
      if @trackIndex > 0
        @trackIndex--
        @trackListPlayed.splice(@trackPlayedIndex, 0, @trackList[@trackIndex])

    @emit('track_changed', @trackList[@trackIndex])
    @trackList[@trackIndex]

Playlist.prototype.__proto__ = events.EventEmitter.prototype
