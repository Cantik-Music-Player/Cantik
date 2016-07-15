electron = require('electron')
remote = electron.remote

module.exports =
class PlayerTaskbarProgress
  constructor: (@pluginManager) ->
    @duration = 100

    @pluginManager.plugins.player.on('duration_change', (duration) =>
      @duration = duration)

    @pluginManager.plugins.player.on('current_time_change', (time) =>
      remote.getGlobal('window').setProgressBar(time/@duration))
