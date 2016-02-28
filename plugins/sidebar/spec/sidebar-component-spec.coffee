jsdom = require('mocha-jsdom')
React = require('react')
TestUtils= require('react/addons').addons.TestUtils
require('coffee-react/register')
SidebarComponent = require('../view.cjsx').SidebarComponent
showSidebar = require('../view.cjsx').show
assert = require 'assert'

describe "Sidebar Component", ->
  jsdom()

  beforeEach ->
    @links = {
      "cat1": [{
          "title": "test1",
          "onClick": ->,
          "active": true
        },
        {
          "title": "test3",
          "onClick": ->,
          "active": false
        }],
      "cat2": [{
          "title": "test2",
          "onClick": ->,
          "active": true
        },
        {
          "title": "test4",
          "onClick": ->,
          "active": false
        }],
    }

  it "Render", ->
    showSidebar(@links, document.getElementsByTagName("body")[0])

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/data-reactid="[\.a-z0-9\$]*"/g, '')

    assert.equal(html,
    '<div class="panel panel-default" id="sidebar" ><div class="panel-body" ><ul class="nav nav-pills nav-stacked" ><h4 >cat1</h4><li class="active" ><a class="withripple" data-toggle="pill" href="#test1" >test1</a></li><li ><a class="withripple" data-toggle="pill" href="#test3" >test3</a></li><h4 >cat2</h4><li class="active" ><a class="withripple" data-toggle="pill" href="#test2" >test2</a></li><li ><a class="withripple" data-toggle="pill" href="#test4" >test4</a></li></ul></div></div>')
