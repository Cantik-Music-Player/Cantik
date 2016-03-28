fs = require 'fs'
events = require 'events'
remote = require 'remote'
app = remote.require 'app'

require 'coffee-react/register'
SettingsComponent = require('./view.cjsx').SettingsComponent
showSettings = require('./view.cjsx').show

module.exports =
class Settings
  constructor: (@pluginManager, @element) ->
    events.EventEmitter.call(this)

    @configPath = "#{app.getPath 'userData'}/config.json"

    @settings = @loadSettings()

    @pluginManager.plugins.sidebar.addLink('Settings', 'Main', @show.bind(@))

  show: ->
    showSettings(@settings, @element)

  addSettings: (pluginName, settingName, settingType, settingDefault) ->
    if not @settings[pluginName]?
      @settings[pluginName] = {}

    if not @settings[pluginName][settingName]?
      @settings[pluginName][settingName] = {value: settingDefault, type: settingType}
      do @saveSettings
      settingDefault
    else
      @settings[pluginName][settingName].value

  getSetting: (pluginName, settingName) ->
    @settings[pluginName]?[settingName]?.value

  setSetting: (pluginName, settingName, value) ->
    @settings[pluginName]?[settingName]?.value = value

  loadSettings: ->
    if fs.existsSync(@configPath)
      JSON.parse fs.readFileSync(@configPath)
    else
      {}

  saveSettings: ->
    fs.writeFile(@configPath, JSON.stringify(@settings));
