History = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "History", ->
  beforeEach ->
    History.prototype.show = sinon.spy()
    @history = new History('pluginManager', 'element')

  it "Initialized", ->
    assert.deepEqual(@history.history, [])
    assert.deepEqual(@history.historyIndex, -1)
    assert.deepEqual(@history.avoidNewEntry, false)
    assert(History.prototype.show.called)

  it "Add entry", ->
    @history.history = [1, 2, 3, 4, 5]
    @history.historyIndex = 2
    @history.addHistoryEntry(42)

    assert.deepEqual(@history.history, [1, 2, 3, 42])
    assert.deepEqual(@history.historyIndex, 3)

  it "Do not add entry if avoidNewEntry is set", ->
    @history.history = [1, 2, 3, 4, 5]
    @history.historyIndex = 2
    @history.avoidNewEntry = true
    @history.addHistoryEntry(42)

    assert.deepEqual(@history.history, [1, 2, 3, 4, 5])
    assert.deepEqual(@history.historyIndex, 2)

  it "Go to entry", ->
    spyFunction = sinon.spy()
    @history.history = [1, spyFunction.bind(null, 1, 2), 7]
    @history.historyIndex = -1
    @history.goToEntry 1

    assert(spyFunction.calledWith(1, 2))

  it "Go back", ->
    @history.historyIndex = 5
    @history.goToEntry = sinon.spy()
    @history.back()

    assert(@history.goToEntry.calledWith(4))

  it "Go next", ->
    @history.historyIndex = 5
    @history.goToEntry = sinon.spy()
    @history.next()

    assert(@history.goToEntry.calledWith(6))
