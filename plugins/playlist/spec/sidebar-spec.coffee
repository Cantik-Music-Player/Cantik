Playlist = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "Playlist", ->
  beforeEach ->
    Playlist.prototype.show = sinon.spy()
    pluginManager = {plugins: {centralarea: {addPanel: sinon.spy()}}}
    @playlist = new Playlist(pluginManager)

  it "Initialized", ->
    assert(@playlist.pluginManager.plugins.centralarea.addPanel.called)

    assert.deepEqual(@playlist.trackList, [])
    assert.deepEqual(@playlist.trackListPlayed, [])
    assert.deepEqual(@playlist.trackIndex, -1)
    assert.deepEqual(@playlist.trackPlayedIndex, -1)
    assert.deepEqual(@playlist.random, false)
    assert.deepEqual(@playlist.repeat, null)

    assert(Playlist.prototype.show.called)

  it "Set random", ->
    @playlist.trackListPlayed = [1, 2, 3, 4]
    @playlist.trackPlayedIndex = 3
    @playlist.trackList = [1, 2, 3, 4, 5, 6, 7]
    @playlist.trackIndex = 3
    @playlist.random = false

    @playlist.setRandom true

    assert.deepEqual(@playlist.trackListPlayed, [4])
    assert.deepEqual(@playlist.trackPlayedIndex, 0)
    assert.deepEqual(@playlist.random, true)

  it "Set random without change", ->
    @playlist.trackListPlayed = [1, 2, 3, 4]
    @playlist.trackPlayedIndex = 3
    @playlist.trackList = [1, 2, 3, 4, 5, 6, 7]
    @playlist.trackIndex = 3
    @playlist.random = false

    @playlist.setRandom false

    assert.deepEqual(@playlist.trackListPlayed, [1, 2, 3, 4])
    assert.deepEqual(@playlist.trackPlayedIndex, 3)
    assert.deepEqual(@playlist.random, false)
