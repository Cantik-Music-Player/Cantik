fs = require('fs')
path = require('path')

module.exports =
class PluginManager
  constructor: ->
    console.log(__dirname)
    @pluginsBasePath = __dirname + '/../plugins'

    files = fs.readdirSync(@pluginsBasePath)
    @plugins = {}

    # Get the plugins
    for file in files
        if file[0] != '.'
            filePath = "#{@pluginsBasePath}/#{file}"
            stat = fs.statSync(filePath)

            # Load plugin
            if stat.isDirectory() and not @plugins[path.basename(filePath)]
              # Load dependencies
              dependencies = @loadPackageJSON(filePath).consumedServices ? {}
              for dep, depVersion of dependencies
                try
                  depPath = "#{@pluginsBasePath}/#{dep}"
                  TempPlugin = require(depPath + '/main')
                  @plugins[path.basename(depPath)] = new TempPlugin(@)
                catch
                  console.error("Unable to load dependency #{dep}")

              TempPlugin = require(filePath + '/main')
              @plugins[path.basename(filePath)] = new TempPlugin(@)

  loadPackageJSON: (pluginPath) ->
    JSON.parse(fs.readFileSync("#{pluginPath}/package.json"))
