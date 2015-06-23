chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

extend          = require 'util-ex/lib/_extend'
require '../src/number'
require '../src/string'
Type            = require '../src/object'
ObjectValue     = require '../src/value/object'
setImmediate    = setImmediate || process.nextTick

register        = Type.register

###
class PasswordType
  register PasswordType, Type.String
  _initialize: (aOptions)->
    super(aOptions)
    @min = 6 # redefine the min property.
###

describe "ObjectType", ->
  object = Type("Object")
  it "should have object type", ->
    should.exist object
    object.should.be.an.instanceOf Type['Object']
    object.pathArray().should.be.deep.equal ['type','Object']
  describe ".encode()", ->
    it "should encode type info", ->
      result = object.encode()
      result = JSON.parse result
      result.should.be.deep.equal
        "name":"Object"
        "fullName":"/type/Object"
        "attributes":{}
  describe ".decode()", ->
    it "should decode type info", ->
      s = '{"attributes":{},"name":"Object","fullName":"/type/Object"}'
      object.decode(s).should.be.deep.equal
        "attributes":{},"name":"Object","fullName":"/type/Object"
    it "should throw error when decode invalid string object", ->
      should.throw object.decode.bind(object, 'as')
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = object.toObject typeOnly: true
      result.should.be.deep.equal
        "attributes": {}
        "name":"Object"
        "fullName":"/type/Object"
    it "should get type info to obj with simple attributes", ->
      attrs = 
        a:"string"
        d:
          type: "object"
          attributes:
            d1:"number"
      t = object.cloneType attributes: attrs
      result = t.toObject()
      result.should.be.deep.equal
        name: 'Object'
        fullName: '/type/Object'
        attributes:
          a: "String"
          d:
            type: "Object"
            attributes:
              d1: "Number"
    it "should get type info to obj with attributes", ->
      attrs = 
        a:"string"
        b:
          type:"number"
          min: 2
          max: 10
        c:
          type: "string"
          required: true
        d:
          type: "object"
          attributes:
            d1:"number"
            d2:
              type:"string"
              required: true
            d3:
              type: "number"
              min: 3
              max: 5
      t = object.cloneType attributes: attrs
      result = t.toObject()
      result.should.be.deep.equal
        name: 'Object'
        fullName: '/type/Object'
        attributes:
          a: "String"
          b:
            type:"Number"
            min: 2
            max: 10
          c:
            type: "String"
            required: true
          d:
            type: "Object"
            attributes:
              d1: "Number"
              d2:
                type:"String"
                required: true
              d3:
                type: "Number"
                min: 3
                max: 5
    it "should get value info to obj", ->
      result = object.create({a:1}) #create object value
      result = result.toObject()
      #result = extend {}, result #TODO why deep equal is not same?
      #result = JSON.parse JSON.stringify result
      expected = { a: 1 }
      result.should.be.deep.equal expected
  describe ".toString()", ->
    it "should get type name if no value", ->
      result = String(object)
      result.should.be.equal '[type Object]'
    it "should get value string if value", ->
      result = object.create({a:13})
      result = String(result)
      result.should.be.equal '[type Object]'
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = object.toJson typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal
        "attributes": {}
        "name":"Object"
        "fullName":"/type/Object"
    it "should get value info to obj", ->
      result = object.create a:13
      result = result.toJson()
      result = JSON.parse result
      result.should.be.deep.equal {a:13}
  describe ".createValue()", ->
    it "should create a value", ->
      n = object.create({a:12})
      n.should.have.property 'a', 12
      n.should.be.instanceOf ObjectValue
    it "should not create a value (invalid object)", ->
      assert.throw object.create.bind(object, 1234)
  describe ".assign()", ->
    it "should assign a value", ->
      n = object.createValue({})
      n.assign({a:13})
      n.should.have.property 'a', 13
  describe ".wrapValue()", ->
    it "should wrap an object value", ->
      n = object.wrapValue({a:24})
      n.should.have.property 'a', 24
      n.should.be.instanceOf ObjectValue

  describe ".validate()", ->
    t = object.cloneType attributes:
      a:"string"
      b:
        type:"number"
        min: 2
        max: 10
      c:
        type: "string"
        required: true
      d:
        type: "object"
        attributes:
          d1:"number"
          d2:
            type:"string"
            required: true
          d3:
            type: "number"
            min: 3
            max: 5
    it "should validate a value and do not raise error", ->
      t.validate({c:"hi"}).should.be.equal true
      t.validate({a:""}, false).should.be.equal false
      t.errors.should.be.deep.equal ["name": "c", "message": "is required"]
      t.validate({b:12}, false).should.be.equal false
      t.errors.should.be.deep.equal [
        "name": "b"
        "message": "should be equal or less than maximum value: 10"
      ,
        "name": "c"
        "message": "is required"
      ]
    it "should validate a object attribute value and do not raise error", ->
      t.validate({c:"hi", d:{d2:""}}).should.be.equal true
      t.validate({c:"hi", d:{d1:1}}, false).should.be.equal false
      t.errors.should.be.deep.equal ["name": "d.d2", "message": "is required"]
      t.validate({c:"hi", d:{d1:1, d3: 6}}, false).should.be.equal false
      t.errors.should.be.deep.equal [
        "name": "d.d2"
        "message": "is required"
      ,
        "name": "d.d3"
        "message": "should be equal or less than maximum value: 5"
      ]
    it "should validate a value and raise error", ->
      should.throw t.validate.bind(t, 0), 'is an invalid'
      should.throw t.validate.bind(t, 11), 'is an invalid'
    it "should validate an encoded value", ->
      t.validate('{"c":""}').should.be.equal true
    it "should validate on strict mode", ->
      t1 = t.cloneType strict:true
      t1.validate({"e":"","c":""}, false).should.be.equal false
      t1.errors.should.be.deep.equal [
        "name": "e"
        "message": "is unknown"
      ]
    it "should validate object string on strict mode", ->
      t1 = t.cloneType strict:true
      t1.validate('{"e":"","c":""}', false).should.be.equal false
      t1.errors.should.be.deep.equal [
        "name": "e"
        "message": "is unknown"
      ]
