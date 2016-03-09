require 'coffee-react/register'
CentralAreaComponent = require('../view.cjsx').CentralAreaComponent
showCentralArea = require('../view.cjsx').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'

describe "CentralArea Component", ->
  jsdom()

  beforeEach ->
    @panels = {
      'test': '<p>toto</p>',
      'toto': '<p>test</p>'
    }

  it "Render", ->
    showCentralArea(@panels, document.getElementsByTagName("body")[0])

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/data-reactid="[\.a-z0-9\$]*"/g, '')

    assert.equal(html,
    '<div class="panel panel-default" id="content" ><div class="panel-body" ><div class="tab-content" ><div class="tab-pane" id="test" ><p>toto</p></div><div class="tab-pane" id="toto" ><p>test</p></div></div></div></div>')
