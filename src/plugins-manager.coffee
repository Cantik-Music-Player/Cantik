fs = require('fs')
path = require('path')
electron = require('electron')
cantik = require('./cantik')
app = electron.remote.app

module.exports =
class PluginManager
  constructor: ->
    @pluginsBasePath = "#{app.getPath('userData')}/plugins/"

    fs.mkdirSync(@pluginsBasePath) if not fs.existsSync(@pluginsBasePath)

    files = fs.readdirSync(@pluginsBasePath)
    @plugins = {}

    # Get the plugins
    for file in files
      if file[0] != '.'
        filePath = "#{@pluginsBasePath}/#{file}"
        if fs.statSync(filePath).isDirectory() and not @plugins[@sanitizePluginName path.basename(filePath)]?
          @loadPlugin filePath

  loadPlugin: (pluginPath) ->
    @loadPluginDepedencies(pluginPath)
    try
      pluginJson = @loadPackageJSON(pluginPath)
      TempPlugin = require(pluginPath + '/' + pluginJson['main'])
      @loadPluginCss "#{pluginPath}/css/"
      @plugins[@sanitizePluginName path.basename(pluginPath)] = new TempPlugin(cantik)
      @plugins[@sanitizePluginName path.basename(pluginPath)].activate()
      @loadKeymap(pluginPath, @plugins[@sanitizePluginName path.basename(pluginPath)])
    catch error
      console.error("Cannot load #{pluginPath} plugin: #{error}")

  loadPluginCss: (cssFolder) ->
    if fs.existsSync(cssFolder) and fs.statSync(cssFolder).isDirectory()
      files = fs.readdirSync(cssFolder)
      for file in files
        if file[0] != '.'
          cssPath = "#{cssFolder}/#{file}"
          if fs.statSync(cssPath).isDirectory()
            @loadPluginCss cssPath
          else
            $('head').append( $('<link rel="stylesheet" type="text/css" />').attr('href', cssPath))

  loadPluginDepedencies: (pluginPath) ->
    dependencies = @loadPackageJSON(pluginPath).consumedServices ? {}
    for dep, depVersion of dependencies
      depPath = "#{@pluginsBasePath}/#{dep}"
      @loadPlugin depPath if not @plugins[@sanitizePluginName path.basename(depPath)]?

  loadKeymap: (pluginPath, plugin) ->
    if fs.existsSync("#{pluginPath}/keymap.json")
      keymap = JSON.parse(fs.readFileSync("#{pluginPath}/keymap.json"))
      for key, func of keymap
        $(document).bind('keydown', key, plugin[func].bind(plugin))

  loadPackageJSON: (pluginPath) ->
    JSON.parse(fs.readFileSync("#{pluginPath}/package.json"))

  sanitizePluginName: (name) ->
    name.replace('-', '')
