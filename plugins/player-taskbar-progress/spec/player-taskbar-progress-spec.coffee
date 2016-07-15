events = require 'events'
assert = require 'assert'
sinon = require 'sinon'
mock = require 'mock-require'

# Mock electron -> getGlobal -> setProgressBar
mock_getglobal = sinon.spy()
mock('electron', {
  remote: {
    getGlobal: (v) ->
      {
        setProgressBar: mock_getglobal
      }
    }
})

PlayerTaskbarProgress = require '../main'

# Mock of the Player class
class PlayerMock
  constructor: ->
    events.EventEmitter.call(@)

PlayerMock.prototype.__proto__ = events.EventEmitter.prototype

describe "Player Taskbar Progress", ->
  it "Works", ->
    # Plugin Manager mock
    pm = {
      plugins: {
        player: new PlayerMock()
      }
    }

    ptp = new PlayerTaskbarProgress(pm)
    pm.plugins.player.emit('duration_change', 50)
    pm.plugins.player.emit('current_time_change', 12)
    assert(mock_getglobal.calledWith(12/50))
