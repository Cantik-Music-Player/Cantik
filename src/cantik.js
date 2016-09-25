require('coffee-script/register');
var PluginManager = require('./plugins-manager');

var pluginManager = new PluginManager();

var cantik = {
  pluginManager: pluginManager,
  utils: require('./utils.coffee'),
};

module.exports = cantik;
