AdmZip = require 'adm-zip'
fs = require 'fs'
request = require 'request'
ncp = require('ncp').ncp
exec = require('child_process').exec
path = require 'path'
uuid = require 'uuid'
process = require 'process'
electron = require 'electron'
cantik = require './cantik'
app = electron.remote.app

module.exports =
class PackageManager
  constructor: ->
    @pluginsPath = "#{app.getPath('userData')}/plugins/"

  installPackage: (folder) ->
    packageJson = JSON.parse(fs.readFileSync("#{folder}/package.json"))
    pluginPath = "#{@pluginsPath}/#{packageJson['name']}"

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

  extractZipAndInstall: (filename) ->
    zip = new AdmZip(filename)
    zip.extractAllTo("#{filename.replace('.zip', '')}/", true)
    subFolder = fs.readdirSync("#{filename.replace('.zip', '')}/")[0]
    @installPackage "#{filename.replace('.zip', '')}/#{subFolder}"

  installPackageFromGithubURL: (url) ->
    zipUrl = "#{url}/archive/master.zip"
    filename = "#{app.getPath('temp')}/#{uuid.v4()}.zip"
    request(zipUrl).pipe(fs.createWriteStream(filename)).on('close', @extractZipAndInstall.bind(@, filename))

  installDefaultPackages: ->
    if fs.readdirSync(@pluginsPath).length == 0
      defaultPackages = JSON.parse(fs.readFileSync("#{app.getAppPath()}/dot-cantik/default-packages.json"))
      Object.keys(defaultPackages['packages']).forEach((key) =>
        githubUrl = defaultPackages['packages'][key]
        @installPackageFromGithubURL githubUrl
      )
