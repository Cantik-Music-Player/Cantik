SidebarComponent = require('../view').SidebarComponent
showSidebar = require('../view').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'

describe "Sidebar Component", ->
  jsdom()

  beforeEach ->
    @links = {
      "cat1": [{
          "title": "test1",
          "onClick": ->,
          "active": true,
          "dataToggle": false
        },
        {
          "title": "test3",
          "onClick": ->,
          "active": false,
          "dataToggle": true
        }],
      "cat2": [{
          "title": "test2",
          "onClick": ->,
          "active": true,
          "dataToggle": true
        },
        {
          "title": "test4",
          "onClick": ->,
          "active": false,
          "dataToggle": true
        }],
    }

  it "Render", ->
    showSidebar(@links, document.getElementsByTagName("body")[0])

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/ data-reactroot=""/g, '')

    assert.equal(html,
    '<div class="panel panel-default" id="sidebar"><div class="panel-body"><ul class="nav nav-pills nav-stacked"><h4>cat1</h4><li class="active" id="sidebar-test1"><a class="withripple" href="#test1">test1</a></li><li id="sidebar-test3"><a class="withripple" data-toggle="tab" href="#test3">test3</a></li><h4>cat2</h4><li class="active" id="sidebar-test2"><a class="withripple" data-toggle="tab" href="#test2">test2</a></li><li id="sidebar-test4"><a class="withripple" data-toggle="tab" href="#test4">test4</a></li></ul></div></div>')
