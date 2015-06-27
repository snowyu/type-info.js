chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

TypeInfo        = require '../src/type-info'
Attributes      = require '../src/attributes/type'
setImmediate    = setImmediate || process.nextTick
register        = TypeInfo.register
attrs = null

class TestType
  constructor: ->return super
  $attributes: attrs = Attributes
    haha: 'Boolean'
    $hidden: 'Number'
    hidden:
      type: 'Number'
      enumerable: false
      value: 5
    min:
      name: 'min'
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
  it "should customize the name attribute", ->
    TestType::$attributes.name.name = '名'
    #Attributes.attrs.name.name = '名'
    t = TypeInfo '名': 'Test'
    should.exist t
    t.should.be.equal TypeInfo('Test')
    # restore the old name
    Attributes.attrs.name.name = 'name'
  it "should change the type attributes name", ->
    attrs.initialize
      min:
        name: '最小'
    t = attrs.min.value
    should.exist t
    t.should.be.equal 1
    t = attrs.min.type
    should.exist t
    t.should.be.equal 'Number'
    t = TestType '最小':2
    should.exist t
    t.should.be.not.equal TypeInfo('Test')
    t.should.have.property 'min', 2
    t.should.not.have.property 'max'
    t.should.have.property 'name', 'Test'
    t = TestType 'min':6
    should.exist t
    t.should.be.not.equal TypeInfo('Test')
    t.should.have.property 'min', 6
    t.should.not.have.property 'max'
    t.should.have.property 'name', 'Test'
    t.toObject().should.deep.equal
      name: 'Test'
      '最小': 6
    # restore the old name
    attrs.initialize
      min:
        name: 'min'
  it "should get proper $attributes", ->
    result = {}
    for k, v of attrs
      result[k] = v if attrs.hasOwnProperty k
    result.should.be.deep.equal
      name:
        name: 'name'
        "enumerable": false
        "required": true
        "type": "String"
      required:
        "name": "required"
        "type": "Boolean"
      $hidden:
        type: 'Number'
      hidden:
        type: 'Number'
        enumerable: false
        value: 5
      haha:
        type: 'Boolean'
      min:
        name: 'min'
        type: 'Number'
        value: 1
      max:
        type:
          name: 'Number'
          max: 3
  it "should not export hidden attributes", ->
    t = TestType min:-1, hidden: 34, max:3, $hidden:122
    should.exist t
    t.should.be.not.equal TypeInfo('Test')
    t.should.have.property 'min', -1
    t.should.have.property 'hidden', 34
    t.should.have.property '$hidden', 122
    t.should.have.property 'max', 3
    t.should.have.property 'name', 'Test'
    t.toObject().should.be.deep.equal
      "name": "Test"
      min: -1
      max: 3
