require('coffee-script/register');
var electron = require('electron')
var PluginManager = require('./plugins-manager');

exports.pluginManager = new PluginManager();
exports.utils = require('./utils.coffee');
exports.app = electron.remote.app;
