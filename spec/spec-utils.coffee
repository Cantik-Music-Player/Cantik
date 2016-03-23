utils = require '../src/utils'
assert = require 'assert'

describe "Utils", ->
  it "Normalize String", ->
    assert.deepEqual(utils.normalizeString('Test TOTO'), 'test-toto')

  it "Format number of seconds", ->
    assert.deepEqual(utils.formatTime(245), '04:05')
