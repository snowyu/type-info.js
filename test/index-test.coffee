chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type = require '../src'

allTypes = [
  'Number'
  'Int'
  'Float'
  'String'
  'Object'
  'Function'
  'Boolean'
]

describe 'TypeInfo', ->
  it 'should load all types', ->
    types = Object.keys Type::_objects
    allTypes.forEach (t)->
      expect(types).be.include t