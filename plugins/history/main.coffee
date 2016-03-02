require 'coffee-react/register'
HistoryComponent = require('./view.cjsx').HistoryComponent
showHistory = require('./view.cjsx').show

module.exports =
class History
  constructor: (@pluginManager, @element) ->
    @history = []
    @historyIndex = -1
    @avoidNewEntry = false
    do @show

  show: ->
    showHistory(@, @element)

  # Add an entry to the history
  # Format {
  #         function: function,
  #         args: list of args
  # }
  addHistoryEntry: (entry) ->
    if not @avoidNewEntry
      @history = @history[0..@historyIndex]
      @history.push(entry)
      @historyIndex = -1 + @history.length

  goToEntry: (index) ->
    # Avoid creating new history entry when accessing it thought history
    @avoidNewEntry = true
    try
      entry = @history[index]
      entry.function entry.args...
      @historyIndex = index
    catch error
      console.log "Cannot go to index #{index}: #{error}"
    @avoidNewEntry = false

  next: ->
    @goToEntry @historyIndex + 1

  back: ->
    @goToEntry @historyIndex - 1
