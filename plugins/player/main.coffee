fs = require('fs')

module.exports =
class Player
  constructor: (@pluginManager) ->
    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('body').append($.parseHTML(html))

    player = @

    # Set play function
    $("#player .previous").click(@back.bind(@))
    $("#player .play").click(@play.bind(@))
    $("#player .next").click(@next.bind(@))

    # Progressbar settings
    noUiSlider.create($("#player .progressbar")[0], {
      start: 0,
      connect: "lower",
      range: {
        min: 0,
        max: 100
      }
    })

    $("#player .progressbar")[0].noUiSlider.on('slide', ->
      $("#player audio")[0].currentTime = @.get())

    # Volume settings
    noUiSlider.create($("#player .volume")[0], {
      start: 0.5,
      connect: "lower",
      range: {
        min: 0,
        max: 1
      }
    })
    $("#player audio")[0].volume = 0.5
    $("#player .volume")[0].noUiSlider.on('update', ->
      $("#player audio")[0].volume = @.get())

    # Event time change
    $("#player audio").on("timeupdate", ->
      $("#player .elapsed-time").text(player.currentTime())
      $("#player .progressbar")[0].noUiSlider.set(@.currentTime))

    $("#player audio").on("durationchange", ->
      $("#player .total-time").text(player.duration())
      $("#player .progressbar")[0].noUiSlider.updateOptions({
        range: {
          min: 0,
          max: @.duration
        }
      }))

    # Event mute
    $("#player .volume-button").click(->
      if $("#player audio")[0].muted
        $("#player audio")[0].muted = false
        $(@).find('i').text("volume_up")
      else
        $("#player audio")[0].muted = true
        $(@).find('i').text("volume_mute"))

    # Random button
    $("#player .random").click(->
      random = not player.pluginManager.plugins.playlist.random
      player.pluginManager.plugins.playlist.setRandom random)

    @pluginManager.plugins.playlist.on('randomchange', (random) ->
      if random
        $("#player .random").addClass('active')
      else
        $("#player .random").removeClass('active'))

    # Repeat button
    $("#player .repeat").click(->
      do player.pluginManager.plugins.playlist.switchRepeatState)

    @pluginManager.plugins.playlist.on('repeatchange', (repeat) ->
      if repeat is null
        $("#player .repeat").removeClass('active')
        $("#player .repeat i").text('repeat')
      else if repeat is "all"
        $("#player .repeat").addClass('active')
        $("#player .repeat i").text('repeat')
      else
        $("#player .repeat").addClass('active')
        $("#player .repeat i").text('repeat_one'))

    # End of track
    $("#player audio").on("ended", ->
      if player.pluginManager.plugins.playlist.repeat is "one"
        $("#player audio")[0].currentTime = 0
        $("#player audio")[0].play()
      else
        do player.next)

  getLastTrack: ->
    @pluginManager.plugins.playlist.getLastTrack.bind(@pluginManager.plugins.playlist)()

  getNextTrack: ->
    @pluginManager.plugins.playlist.getNextTrack.bind(@pluginManager.plugins.playlist)()

  playTrack: (track) ->
    if track?
      $("#player audio").html("<source src='#{track.path}'>")
      $("#player audio")[0].load()
      $("#player .track-artist .title").text("#{track.metadata.title}")
      $("#player .track-artist .artist").text("#{track.metadata.artist[0]}")
    $("#player audio")[0].play()
    $("#player .play").text("pause")

  play: ->
    # Need to play
    if $("#player .play").text()  is "play_arrow"
      # No track -> getTrackToPlay
      if $("#player audio").html() is ""
        @playTrack @getNextTrack()
      do @playTrack

    # Need to pause
    else
      $("#player audio")[0].pause()
      $("#player .play").text("play_arrow")

  back: ->
    @playTrack @getLastTrack()

  next: ->
    @playTrack @getNextTrack()

  formatTime: (seconds) ->
    (new Date).clearTime()
              .addSeconds(seconds)
              .toString('mm:ss')

  currentTime: ->
    @formatTime $("#player audio")[0].currentTime

  duration: ->
    @formatTime $("#player audio")[0].duration
