fs = require('fs')
Track = require('../../src/track')


module.exports =
class Playlist
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    @history = @pluginManager.plugins.history


    @element = @pluginManager.plugins.centralarea.addPanel('Playlist', 'Now Playing', html)
    @trackList = []
    @trackIndex = -1
    @random = false
    @repeat = null

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

  getNextTrack: ->
    if not @random
      @trackIndex++
      @element.find('table.list tr').removeClass("info")
      $(@element.find('table.list tr')[@trackIndex]).addClass("info")
      @trackList[@trackIndex]

  getLastTrack: ->
    if not @random
      @trackIndex--
      @element.find('table.list tr').removeClass("info")
      $(@element.find('table.list tr')[@trackIndex]).addClass("info")
      @trackList[@trackIndex]
