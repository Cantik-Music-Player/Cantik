utils = require '../src/utils'
assert = require 'assert'

describe "Utils", ->
  it "Normalize String", ->
    assert.deepEqual(utils.normalizeString('Test TOTO'), 'test-toto')

  it "Format number of seconds", ->
    assert.deepEqual(utils.formatTime(245), '04:05')

  it "Delete value from array", ->
    assert.deepEqual(utils.deleteValueFromArray(2, [1, 2, 3]), [1, 3])
