fs = require('fs')

module.exports =
class History
  constructor: (@pluginManager) ->
    $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', __dirname + '/css/style.css'))

    # Read html file
    html = fs.readFileSync(__dirname + '/html/index.html', 'utf8')
    $('#sidebar ul').prepend(html)

    history = @
    $('#sidebar ul .previous').click((event) ->
      history.back()
      event.preventDefault())
    $('#sidebar ul .next').click((event) ->
      history.next()
      event.preventDefault())

    @history = []
    @historyIndex = -1
    @avoidNewEntry = false

  addHistoryEntry: (entry) ->
    if not @avoidNewEntry
      @history = @history[0..@historyIndex]
      @history.push(entry)
      @historyIndex = -1 + @history.length

  goToEntry: (index) ->
    @avoidNewEntry = true
    try
      entry = @history[index]
      entry.plugin[entry.function] entry.args...
      @historyIndex = index
    catch error
      console.log("Cannot go to index #{index}: #{error}")
    @avoidNewEntry = false

  next: ->
    @goToEntry @historyIndex + 1

  back: ->
    @goToEntry @historyIndex - 1
