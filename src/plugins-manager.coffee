fs = require('fs')
path = require('path')
remote = require('remote')
app = remote.require('app')

module.exports =
class PluginManager
  constructor: ->
    @pluginsBasePath = __dirname + '/../plugins'

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
      TempPlugin = require(pluginPath + '/main')
      @loadPluginCss "#{pluginPath}/css/"
      element = @createDOMElement pluginPath
      @plugins[@sanitizePluginName path.basename(pluginPath)] = new TempPlugin(@, element)
      @loadKeymap(pluginPath, @plugins[@sanitizePluginName path.basename(pluginPath)])
    catch error
      console.error("Cannot load #{pluginPath} plugin: #{error}")

  loadPluginCss: (cssFolder) ->
    if fs.statSync(cssFolder).isDirectory()
      files = fs.readdirSync(cssFolder)
      for file in files
          if file[0] != '.'
            cssPath = "#{cssFolder}/#{file}"
            if fs.statSync(cssPath).isDirectory()
              @loadPluginCss cssPath
            else
              $('head').append( $('<link rel="stylesheet" type="text/css" />').attr('href', cssPath))

  createDOMElement: (pluginPath) ->
    parentSelector = @loadPackageJSON(pluginPath).DOMContainer
    if parentSelector?
      elementId = "plugin-#{path.basename(pluginPath)}"
      $("<div id='#{elementId}'></div>").appendTo(parentSelector)[0]

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
