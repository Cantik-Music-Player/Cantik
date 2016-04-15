events = require 'events'

require 'coffee-react/register'
PlaylistComponent = require('./view.cjsx').PlaylistComponent
showPlaylist = require('./view.cjsx').show

deleteValueFromArray = require('../../src/utils').deleteValueFromArray

module.exports =
class Playlist
  constructor: (@pluginManager) ->
    events.EventEmitter.call(this)

    @element = @pluginManager.plugins.centralarea.addPanel('Playlist', 'Now Playing')
    @tracklist = []
    @tracklistHistory = []
    @tracklistIndex = -1
    @tracklistHistoryIndex = -1
    @random = false
    @repeat = null

    do @show

  show: ->
    showPlaylist(@, @element)

  setRandom: (randomState) ->
    if randomState is not @random
      @tracklistHistory = [@tracklist[@tracklistIndex]]
      @tracklistHistoryIndex = 0
      @random = randomState
      @emit('random_changed', randomState)

  switchRepeatState: ->
    if @repeat is null
      @repeat = 'all'
    else if @repeat is 'all'
      @repeat = 'one'
    else
      @repeat = null
    @emit('repeat_changed', @repeat)

  addTrack: (track) ->
    @tracklist.push(track)
    @emit('tracklist_changed', @tracklist)

  addTracks: (tracks) ->
    @addTrack t for t in tracks

  deleteTrack: (trackIndex) ->
    @tracklistHistory = deleteValueFromArray(@tracklist[trackIndex], @tracklistHistory)
    @tracklist.splice(trackIndex, 1)

    @tracklistIndex-- if trackIndex <= @tracklistIndex
    @tracklistHistoryIndex-- if @tracklistHistoryIndex > -1 + @tracklistHistory.length

    @emit('tracklist_changed', @tracklist)

  cleanPlaylist: ->
    @tracklist = []
    @tracklistIndex = -1
    @tracklistHistory = []
    @emit('tracklist_changed', @tracklist)

  getNextTrack: ->
    if @tracklistHistoryIndex < @tracklistHistory.length - 1
      # Going next in the history
      @tracklistHistoryIndex++
      @tracklistIndex = @tracklist.indexOf(@tracklistHistory[@tracklistHistoryIndex])
    else if not @random
      if @tracklistIndex < @tracklist.length - 1
        # No random & not end of plalist => Go next
        @tracklistIndex++
        @tracklistHistory.push(@tracklist[@tracklistIndex])
        @tracklistHistoryIndex = @tracklistHistory.length - 1
      else if @repeat is 'all'
        # End of playlist & repeat is all => Go to first track
        @tracklistIndex = 0
        @tracklistHistory = [@tracklist[@tracklistIndex]]
        @tracklistHistoryIndex = 0
    else
      # Random
      if @repeat is 'all' and @tracklistHistory.length is @tracklist.length
        # Reset history if it contains all te tracklist
        @tracklistHistory = []
      if @tracklistHistory.length < @tracklist.length
        # Find a random not alreay in history
        while true
          @tracklistIndex = Math.floor(Math.random() * @tracklist.length);
          break if @tracklist[@tracklistIndex] not in @tracklistHistory

        @tracklistHistory.push(@tracklist[@tracklistIndex])
        @tracklistHistoryIndex = @tracklistHistory.length - 1

    @emit('track_changed', @tracklist[@tracklistIndex])
    @tracklist[@tracklistIndex]

  getLastTrack: ->
    if @tracklistHistoryIndex > 0
      # Go back in history
      @tracklistHistoryIndex--
      @tracklistIndex = @tracklist.indexOf(@tracklistHistory[@tracklistHistoryIndex])
    else if not @random
      if @tracklistIndex > 0
        # No random and not beginning => Go last track
        @tracklistIndex--
        @tracklistHistory.splice(@tracklistHistoryIndex, 0, @tracklist[@tracklistIndex])

    @emit('track_changed', @tracklist[@tracklistIndex])
    @tracklist[@tracklistIndex]

Playlist.prototype.__proto__ = events.EventEmitter.prototype
