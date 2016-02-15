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
            stat = fs.statSync(filePath)

            # Load plugin
            if stat.isDirectory() and not @plugins[@sanitizePluginName path.basename(filePath)]?
              # Load dependencies
              @loadPluginDepedencies(filePath)
              try
                TempPlugin = require(filePath + '/main')
                @plugins[@sanitizePluginName path.basename(filePath)] = new TempPlugin(@)
                @loadKeymap(filePath, @plugins[@sanitizePluginName path.basename(filePath)])
              catch error
                console.error("Cannot load #{filePath} plugin: #{error}")

  loadPluginDepedencies: (pluginPath) ->
    dependencies = @loadPackageJSON(pluginPath).consumedServices ? {}
    for dep, depVersion of dependencies
      try
        depPath = "#{@pluginsBasePath}/#{dep}"
        if not @plugins[@sanitizePluginName path.basename(depPath)]?
          @loadPluginDepedencies(depPath)
          TempPlugin = require(depPath + '/main')
          @plugins[@sanitizePluginName path.basename(depPath)] = new TempPlugin(@)
          @loadKeymap(depPath, @plugins[@sanitizePluginName path.basename(depPath)])
      catch
        console.error("Unable to load dependency #{dep}")

  loadKeymap: (pluginPath, plugin) ->
    if fs.existsSync("#{pluginPath}/keymap.json")
      keymap = JSON.parse(fs.readFileSync("#{pluginPath}/keymap.json"))
      for key, func of keymap
        $(document).bind('keydown', key, plugin[func].bind(plugin))

  loadPackageJSON: (pluginPath) ->
    JSON.parse(fs.readFileSync("#{pluginPath}/package.json"))

  sanitizePluginName: (name) ->
    name.replace('-', '')
