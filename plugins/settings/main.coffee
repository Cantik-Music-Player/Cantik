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

    @pluginManager.plugins.sidebar.addLink('Settings', 'Main', @show.bind(@), null, false)

  show: ->
    showSettings(@, @element)

  addSetting: (pluginName, settingName, settingType, settingDefault) ->
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
    @emit("#{pluginName}-#{settingName}-change", value)
    do @saveSettings

  setSettings: (settings) ->
    oldSettings = @settings
    @settings = settings

    # Emit events
    for pluginName, pluginSettings of settings
      for settingName, settingParam of pluginSettings
        if settingParam.value != oldSettings[pluginName][settingName].value
          try
            @emit("#{pluginName}-#{settingName}-change", settingParam.value)
          catch error

    do @saveSettings

  loadSettings: ->
    if fs.existsSync(@configPath)
      JSON.parse fs.readFileSync(@configPath)
    else
      {}

  saveSettings: ->
    fs.writeFile(@configPath, JSON.stringify(@settings))

Settings.prototype.__proto__ = events.EventEmitter.prototype
