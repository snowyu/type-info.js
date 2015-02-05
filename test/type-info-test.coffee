chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

TypeInfo        = require '../src/type-info'
setImmediate    = setImmediate || process.nextTick
register        = TypeInfo.register

class NumberType
  register NumberType
  constructor: TypeInfo

describe "TypeInfo", ->
  describe ".pathArray()", ->
    it "should get default type path array", ->
      t = TypeInfo('Number')
      t.pathArray().should.be.deep.equal ['type','Number']
    it "should get cutomize root type path array", ->
      TypeInfo.ROOT_NAME = 'atype'
      t = TypeInfo('Number')
      t.pathArray().should.be.deep.equal ['atype','Number']


