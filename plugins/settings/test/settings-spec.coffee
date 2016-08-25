mock = require 'mock-require'

mock('electron', {
  remote: {
    app: {
      getPath: ->
        'abc'
    }
  }
})

Settings = require '../main'
sinon = require 'sinon'
assert = require 'assert'

describe "Settings", ->
  beforeEach ->
    @pluginManager = {plugins: {sidebar: {addLink: sinon.spy()}}}
    Settings.prototype.saveSettings = sinon.spy()
    @settings = new Settings(@pluginManager, 'element')

  it "Initialized", ->
    assert.deepEqual(@settings.configPath, 'abc/config.json')
    assert.deepEqual(@settings.settings, {})
    assert(@pluginManager.plugins.sidebar.addLink.calledWith('Settings', 'Main'))

  it "Add Setting", ->
    assert.deepEqual(@settings.addSetting('pluginName', 'settingName', 'settingType', 'settingDefault'), 'settingDefault')
    assert.deepEqual(@settings.settings, {pluginName: {settingName: {value: 'settingDefault', type: 'settingType'}}})
    assert.deepEqual(@settings.addSetting('pluginName', 'settingName', 'settingType', 'aaa'), 'settingDefault')
    assert.deepEqual(@settings.settings, {pluginName: {settingName: {value: 'settingDefault', type: 'settingType'}}})

  it "Get setting", ->
    @settings.settings = {pluginName: {settingName: {value: 'aaa', type: 'settingType'}}}
    assert.deepEqual(@settings.getSetting('pluginName', 'settingName'), 'aaa')

  it "Set setting", ->
    event = false
    @settings.on('pluginName-settingName-change', ->
      event = true)

    @settings.settings = {pluginName: {settingName: {value: 'aaa', type: 'settingType'}}}
    @settings.setSetting('pluginName', 'settingName', 'test')
    assert.deepEqual(@settings.settings.pluginName.settingName.value, 'test')
    assert(event)
    assert(Settings.prototype.saveSettings.called)

  it "Set settings", ->
    event = false
    @settings.on('pluginName-settingName-change', ->
      event = true)

    @settings.settings = {pluginName: {settingName: {value: 'aaa', type: 'settingType'}}}
    @settings.setSettings({pluginName: {settingName: {value: 'test', type: 'settingType'}}})
    assert.deepEqual(@settings.settings.pluginName.settingName.value, 'test')
    assert(event)
    assert(Settings.prototype.saveSettings.called)
