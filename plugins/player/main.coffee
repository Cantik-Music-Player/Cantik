events = require 'events'

require 'coffee-react/register'
PlayerComponent = require('./view.cjsx').PlayerComponent
showPlayer = require('./view.cjsx').show

module.exports =
class Player
  constructor: (@pluginManager, @element) ->
    events.EventEmitter.call(@)

    @playing = false
    @playingTrack = {}

    do @show

  show: ->
    showPlayer(@, @element)

  getLastTrack: ->
    @pluginManager.plugins.playlist.getLastTrack.bind(@pluginManager.plugins.playlist)()

  getNextTrack: ->
    @pluginManager.plugins.playlist.getNextTrack.bind(@pluginManager.plugins.playlist)()

  playTrack: (track) ->
    if track?
      @playingTrack = track
      @emit('track_changed', track)
    @playing = true
    @emit('play_state_changed', @)

  play: ->
    # Need to play
    if not @playing
      # No track -> getTrackToPlay
      if Object.keys(@playingTrack).length is 0
        @playTrack @getNextTrack()
      else
        do @playTrack

      @playing = true
      @emit('play_state_changed', @)

    # Need to pause
    else
      @playing = false
      @emit('play_state_changed', @)

  back: ->
    @playTrack @getLastTrack()

  next: ->
    @playTrack @getNextTrack()

Player.prototype.__proto__ = events.EventEmitter.prototype
