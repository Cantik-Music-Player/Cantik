module.exports =
class PlayerNotifications
  constructor: (@pluginManager, @element) ->
    @pluginManager.plugins.player.on('track_changed', (track) =>
      @notify("#{track.metadata.title} - #{track.metadata.artist[0]}"))

  notify: (title, msg) ->
    new Notification(title, {
      body: msg
    })
