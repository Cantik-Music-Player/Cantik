require 'coffee-react/register'
CentralAreaComponent = require('../view.cjsx').CentralAreaComponent
showCentralArea = require('../view.cjsx').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'

describe "CentralArea Component", ->
  jsdom()

  beforeEach ->
    @centralArea = {panels: ['test', 'test2']}

  it "Render", ->
    e = showCentralArea(@centralArea, document.getElementsByTagName("body")[0])

    assert(e instanceof HTMLElement)

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/data-reactid="[\.a-z0-9\$]*"/g, '')

    assert.equal(html,
    '<div class="panel panel-default" id="content" ><div class="panel-body" ><div class="tab-content" ><div class="tab-pane" id="test" ></div><div class="tab-pane" id="test2" ></div></div></div></div>')
