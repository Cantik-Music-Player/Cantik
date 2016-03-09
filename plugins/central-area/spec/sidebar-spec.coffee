CentralArea = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "CentralArea", ->
  beforeEach ->
    CentralArea.prototype.show = sinon.spy()
    pluginManager = {'plugins': {'sidebar': {'addLink': sinon.spy()}}}
    @centralArea = new CentralArea(pluginManager, 'element')

  it "Initialized", ->
    assert.deepEqual(@centralArea.panels, {})
    assert(CentralArea.prototype.show.called)

  it "Add Panel", ->
    @centralArea.addPanel('name', 'category', 'content', 'sidebarClick', 'sidebarForceActive')

    assert.deepEqual(@centralArea.panels, {'name': 'content'})
    assert(@centralArea.pluginManager.plugins.sidebar.addLink.calledWith('name', 'category', 'sidebarClick', 'sidebarForceActive'))
