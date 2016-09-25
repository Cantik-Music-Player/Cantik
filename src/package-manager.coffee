ncp = require('ncp').ncp
exec = require('child_process').exec
path = require 'path'
process = require 'process'
electron = require 'electron'
cantik = require './cantik'
app = electron.remote.app

module.exports =
class PackageManager
  constructor: ->
    @pluginsPath = "#{app.getPath('userData')}/plugins/"

  installPackage: (folder) ->
    pluginPath = "#{@pluginsPath}/#{path.basename(folder)}"

    if fs.existsSync pluginPath
      return console.log "Package already installed: #{folder}"

    ncp(folder, pluginPath, (err) ->
      if err
        return console.error "Unable to install package: #{folder}: #{err}"

      dirBack = process.cwd()
      cmd = "cd #{pluginPath} && npm install && cd #{dirBack}"

      exec(cmd, (error, stdout, stderr) ->
          cantik.pluginManager.loadPlugin(pluginPath))
    )
