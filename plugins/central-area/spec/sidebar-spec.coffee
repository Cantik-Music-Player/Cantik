CentralArea = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "CentralArea", ->
  beforeEach ->
    CentralArea.prototype.show = sinon.stub().returns({querySelector: -> 'DOM'})
    pluginManager = {'plugins': {'sidebar': {'addLink': sinon.spy()}}}
    @centralArea = new CentralArea(pluginManager, 'element')

  it "Initialized", ->
    assert.deepEqual(@centralArea.panels, {})
    assert(CentralArea.prototype.show.called)

  it "Add Panel", ->
    element = @centralArea.addPanel('name', 'category', 'sidebarClick', 'sidebarForceActive')

    assert.deepEqual(element, 'DOM')
    assert.deepEqual(@centralArea.panels, ['name'])
    assert(@centralArea.pluginManager.plugins.sidebar.addLink.calledWith('name', 'category', 'sidebarClick', 'sidebarForceActive'))
