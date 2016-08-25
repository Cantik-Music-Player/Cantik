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
    @sidebar.addLink('test4', 'cat2', 'func1', false, false)

    delete @sidebar.links['cat1'][0]['onClick']
    delete @sidebar.links['cat1'][1]['onClick']
    delete @sidebar.links['cat2'][0]['onClick']
    delete @sidebar.links['cat2'][1]['onClick']

    assert.deepEqual(@sidebar.links, {
      "cat1": [{
          "title": "test1",
          "active": true,
          "dataToggle": true
        },
        {
          "title": "test3",
          "active": false,
          "dataToggle": true
        }],
      "cat2": [{
          "title": "test2",
          "active": true,
          "dataToggle": true
        },
        {
          "title": "test4",
          "active": false,
          "dataToggle": false
        }],
    })
