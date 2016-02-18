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

  addTrack: (track) ->
    @trackList.push(track)
    console.log track
    @element.find('table.list').append("""
    <tr>
      <td>#{track.metadata.title}</td>
      <td>#{track.metadata.artist[0]}</td>
      <td>#{track.metadata.album}</td>
      <td>#{track.metadata.duration}</td>
    </tr>
    """)
