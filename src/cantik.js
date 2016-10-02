require('coffee-script/register');
var PluginManager = require('./plugins-manager');

exports.pluginManager = new PluginManager();
exports.utils = require('./utils.coffee')
