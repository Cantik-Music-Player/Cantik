jsdom = require 'mocha-jsdom'
sinon = require 'sinon'
assert = require 'assert'

Player = null

describe "Player", ->
  jsdom()

  beforeEach ->
    Player = require '../main'
    Player.prototype.show = sinon.spy()
    pluginManager = {'plugins': {'playlist': {}}}
    pluginManager.plugins.playlist.getLastTrack = sinon.spy()
    pluginManager.plugins.playlist.getNextTrack = sinon.spy()
    @player = new Player(pluginManager, 'element')

  it "Initialized", ->
    assert.deepEqual(@player.playing, false)
    assert.deepEqual(@player.playingTrack, {})
    assert(Player.prototype.show.called)

  it "Get Last Track", ->
    assert.deepEqual(@player.getLastTrack(), @player.pluginManager.plugins.playlist.getLastTrack())
    assert(@player.pluginManager.plugins.playlist.getLastTrack.called)

  it "Get Next Track", ->
    assert.deepEqual(@player.getNextTrack(), @player.pluginManager.plugins.playlist.getNextTrack())
    assert(@player.pluginManager.plugins.playlist.getNextTrack.called)

  it "Play Track", ->
    eventTrack = false
    eventPlay = false

    @player.on('track_changed', ->
      eventTrack = true)

    @player.on('play_state_changed', ->
      eventPlay = true)

    track = {'track': 'test'}
    @player.playTrack track

    assert.deepEqual(@player.playingTrack, track)
    assert.deepEqual(@player.playing, true)
    assert.deepEqual(eventTrack, true)
    assert.deepEqual(eventPlay, true)

  it "Play null Track", ->
    eventTrack = false
    eventPlay = false

    @player.on('track_changed', ->
      eventTrack = true)

    @player.on('play_state_changed', ->
      eventPlay = true)

    @player.playingTrack = {'track': 'test'}
    do @player.playTrack

    assert.deepEqual(@player.playingTrack, {'track': 'test'})
    assert.deepEqual(@player.playing, true)
    assert.deepEqual(eventTrack, false)
    assert.deepEqual(eventPlay, true)

  it "Play new track", ->
    @player.playTrack = sinon.spy()
    @player.getNextTrack = -> 'abc'

    eventPlay = false
    @player.on('play_state_changed', ->
      eventPlay = true)

    do @player.play

    assert(@player.playTrack.calledWith('abc'))
    assert.deepEqual(@player.playing, true)
    assert.deepEqual(eventPlay, true)

  it "Resume play", ->
    @player.playTrack = sinon.spy()

    eventPlay = false
    @player.on('play_state_changed', ->
      eventPlay = true)

    @player.playingTrack = {'track': 'test'}
    do @player.play

    assert(@player.playTrack.calledWith())
    assert.deepEqual(@player.playing, true)
    assert.deepEqual(eventPlay, true)

  it "Pause", ->
    eventPlay = false
    @player.on('play_state_changed', ->
      eventPlay = true)

    @player.playing = true
    do @player.play

    assert.deepEqual(@player.playing, false)
    assert.deepEqual(eventPlay, true)

  it "Next", ->
    @player.playTrack = sinon.spy()
    @player.getNextTrack = -> 'abc'

    do @player.next

    assert(@player.playTrack.calledWith('abc'))

  it "Back", ->
    @player.playTrack = sinon.spy()
    @player.getLastTrack = -> 'abc'

    do @player.back

    assert(@player.playTrack.calledWith('abc'))
