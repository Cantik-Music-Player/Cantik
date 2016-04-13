var app = require('app');
var BrowserWindow = require('browser-window');
require('coffee-script/register');
require('crash-reporter').start();

var window = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
  if (process.platform != 'darwin') {
    app.quit();
  }
});

app.on('ready', function() {
  // Create the browser window.
  window = new BrowserWindow({title: 'Cantik', icon: 'static/images/icon.png'});
  window.maximize();
  window.setMenu(null);
  window.loadUrl('file://' + __dirname + '/../static/index.html');

  // Avoid the window title to change
  window.on('page-title-updated', function(event){
    event.preventDefault();
  });

  // If "dev" in command line args open the dev tools
  if(process.argv.indexOf('dev') > -1){
    window.webContents.openDevTools();
  }

  // Emitted when the window is closed.
  window.on('closed', function() {
    window = null;
  });
});
