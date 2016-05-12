mock = require 'mock-require'

mock('electron', {
  remote: ''
})

require 'coffee-react/register'
PlaylistComponent = require('../view.cjsx').PlaylistComponent
showPlaylist = require('../view.cjsx').show

assert = require 'assert'
jsdom = require 'mocha-jsdom'
sinon = require 'sinon'

describe "Playlist Component", ->
  jsdom()

  beforeEach ->
    track = {
      metadata: {
        title: 'Title',
        artist: ['Artist 1', 'Artist 2'],
        album: 'Album',
        duration: 100
      }
    }

    track1 = {
      metadata: {
        title: 'Title 2',
        artist: ['Artist 1', 'Artist 2'],
        album: 'Album',
        duration: 100
      }
    }

    @playlist = {tracklist: [track, track1], tracklistIndex: 1, on: sinon.spy()}

  it "Render", ->
    showPlaylist(@playlist, document.getElementsByTagName("body")[0])

    assert(@playlist.on.calledWith('tracklist_changed'))
    assert(@playlist.on.calledWith('track_changed'))

    # Clean data-react-id
    html = document.getElementsByTagName("body")[0].innerHTML.replace(/ data-reactroot=""/g, '')

    assert.equal(html,
    '<div id="playlist"><table class="table table-striped table-hover fixed"><thead><tr><th>Title</th><th>Artist</th><th>Album</th><th>Duration</th></tr></thead></table><table class="table table-striped table-hover list"><tbody><tr draggable="true" class="null track" data-id="0"><td>Title</td><td>Artist 1</td><td>Album</td><td>01:40</td></tr><tr draggable="true" class="info track" data-id="1"><td>Title 2</td><td>Artist 1</td><td>Album</td><td>01:40</td></tr></tbody></table></div>')
