AdmZip = require 'adm-zip'
fs = require 'fs'
request = require 'request'
ncp = require('ncp').ncp
exec = require('child_process').exec
path = require 'path'
uuid = require 'uuid'
electron = require 'electron'
cantik = require './cantik'
app = electron.remote.app

module.exports =
class PackageManager
  constructor: ->
    @pluginsPath = "#{app.getPath('userData')}/plugins/"

  installPackage: (folder, callback) ->
    packageJson = JSON.parse(fs.readFileSync("#{folder}/package.json"))
    pluginPath = "#{@pluginsPath}/#{packageJson['name']}"

    if fs.existsSync pluginPath
      return console.log "Package already installed: #{folder}"

    ncp(folder, pluginPath, (err) ->
      if err
        return console.error "Unable to install package: #{folder}: #{err}"

      cmd = "npm --prefix #{pluginPath} install #{pluginPath}"

      exec(cmd, (error, stdout, stderr) ->
        console.error error if error?
        console.error stderr if stderr?
        do callback)
    )

  extractZipAndInstall: (filename, callback) ->
    zip = new AdmZip(filename)
    zip.extractAllTo("#{filename.replace('.zip', '')}/", true)
    subFolder = fs.readdirSync("#{filename.replace('.zip', '')}/")[0]
    @installPackage("#{filename.replace('.zip', '')}/#{subFolder}", callback)

  installPackageFromGithubURL: (url, callback) ->
    zipUrl = "#{url}/archive/master.zip"
    filename = "#{app.getPath('temp')}/#{uuid.v4()}.zip"
    request(zipUrl).pipe(fs.createWriteStream(filename)).on('close', @extractZipAndInstall.bind(@, filename, callback))

  installDefaultPackages: ->
    if fs.readdirSync(@pluginsPath).length == 0
      defaultPackages = null
      try  # SHould work on packaged version
        defaultPackages = JSON.parse(fs.readFileSync("#{app.getAppPath()}/dot-cantik/default-packages.json"))
      catch error  # Should work on dev version
        if fs.existsSync("dot-cantik/default-packages.json")
          defaultPackages = JSON.parse(fs.readFileSync("dot-cantik/default-packages.json"))

      if defaultPackages?
        @toInstall = defaultPackages
        Object.keys(defaultPackages['packages']).forEach((key) =>
          githubUrl = defaultPackages['packages'][key]
          @installPackageFromGithubURL(githubUrl, =>
            # If all packages are installed, load them
            @toInstall.splice(@toInstall.indexOf(key), 1)
            if @toInstall.length == 0
              do cantik.pluginManager.loadPlugins))
