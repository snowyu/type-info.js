chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

TypeInfo        = require '../index'
Attributes      = require '../src/attributes/'
setImmediate    = setImmediate || process.nextTick
register        = TypeInfo.register

class TestType
  constructor: ->return super
  $attributes: Attributes
    min:
      type: 'Number'
      value: 1
    max:
      type:
        name: 'Number'
        max: 3

describe "TypeAttributes", ->
  before ->
    result = register TestType
    result.should.be.true
  after ->
    TypeInfo.unregister 'Test'
  it "should get type info object directly", ->
    t = TestType()
    should.exist t
    t.should.be.equal TypeInfo('Test')
    t.should.have.property 'min', 1
    t.should.not.have.property 'max'
    t.should.have.property 'name', 'Test'
  it "should create type info object directly", ->
    # the min 2 is not the original/default value 1 now.
    # so create a new type instance.
    t = TestType min:2
    should.exist t
    t.should.be.not.equal TypeInfo('Test')
    t.should.have.property 'min', 2
    t.should.not.have.property 'max'
    t.should.have.property 'name', 'Test'
  it "should raise error when max exceed range", ->
    should.throw TestType.bind(null, max:4), 'assign attribute \'max\' error'
  it "should create type info object when max in the range", ->
    t = TestType max:2
    should.exist t
    t.should.be.not.equal TypeInfo('Test')
    t.should.have.property 'min', 1
    t.should.have.property 'max', 2
    t.should.have.property 'name', 'Test'
