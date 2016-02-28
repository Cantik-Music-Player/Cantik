Sidebar = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "Sidebar", ->
  beforeEach ->
    Sidebar.prototype.show = sinon.spy()
    @sidebar = new Sidebar('pluginManager', 'element')

  it "Initialized", ->
    assert.deepEqual(@sidebar.links, {})
    assert(Sidebar.prototype.show.called)

  it "Add link", ->
    @sidebar.addLink('test1', 'cat1', 'func4', true)
    @sidebar.addLink('test2', 'cat2', 'func3', true)
    @sidebar.addLink('test3', 'cat1', 'func2', false)
    @sidebar.addLink('test4', 'cat2', 'func1', false)

    assert.deepEqual(@sidebar.links, {
      "cat1": [{
          "title": "test1",
          "onClick": "func4",
          "active": true
        },
        {
          "title": "test3",
          "onClick": "func2",
          "active": false
        }],
      "cat2": [{
          "title": "test2",
          "onClick": "func3",
          "active": true
        },
        {
          "title": "test4",
          "onClick": "func1",
          "active": false
        }],
    })
