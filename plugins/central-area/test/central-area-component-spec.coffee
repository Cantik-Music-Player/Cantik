CentralAreaComponent = require('../view').CentralAreaComponent
showCentralArea = require('../view').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'

describe "CentralArea Component", ->
  jsdom()

  beforeEach ->
    @centralArea = {panels: [{name: 'test', active: true}, {name: 'test2', active: false}]}

  it "Render", ->
    e = showCentralArea(@centralArea, document.getElementsByTagName("body")[0])

    assert(e instanceof HTMLElement)

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/ data-reactroot=""/g, '')

    assert.equal(html,
    '<div class="panel panel-default" id="content"><div class="panel-body"><div class="tab-content"><div class="tab-pane active" id="test"></div><div class="tab-pane " id="test2"></div></div></div></div>')
