HistoryComponent = require('../view').HistoryComponent
showHistory = require('../view').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'

describe "History Component", ->
  jsdom()

  beforeEach ->
    @history =  {
      'next': -> true,
      'back': -> true
    }

  it "Render", ->
    showHistory(@history, document.getElementsByTagName("body")[0])

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/ data-reactroot=""/g, '')

    assert.equal(html,
    '<div class="history"><div class="form-group left"><button class="withripple"><i class="material-icons previous">keyboard_arrow_left</i></button></div><div class="form-group"><button class="withripple"><i class="material-icons next">keyboard_arrow_right</i></button></div></div>')
