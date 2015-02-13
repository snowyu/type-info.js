chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

require '../src/number'
require '../src/string'
Type            = require '../src/object'
setImmediate    = setImmediate || process.nextTick

describe "ObjectType", ->
  object = Type("Object")
  it "should have object type", ->
    should.exist object
    object.should.be.an.instanceOf Type['Object']
    object.pathArray().should.be.deep.equal ['type','Object']
  describe ".encode()", ->
    it "should encode value", ->
      object.encode({}).should.be.equal "{}"
    it "should throw error when encode invalid value", ->
      should.throw object.encode.bind(object, 'as'), "is not a valid"
  describe ".decode()", ->
    it "should decode value", ->
      object.decode("{}").should.be.deep.equal {}
    it "should throw error when decode invalid string object", ->
      should.throw object.decode.bind(object, 'as'), "is not a valid"
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = object.toObject typeOnly: true
      result.should.be.deep.equal "name":"Object","fullName":"type/Object"
    it "should get value info to obj", ->
      result = object.create({a:1})
      result = result.toObject()
      result.should.be.deep.equal "attributes": {}, "name":"Object","fullName":"type/Object", value: {a:1}
  describe ".toString()", ->
    it "should get type name if no value", ->
      result = String(object)
      result.should.be.equal '[type Object]'
    it "should get value string if value", ->
      result = object.create({a:13})
      result = String(result)
      result.should.be.equal '[object Object]'
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = object.toJson typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal "name":"Object","fullName":"type/Object"
    it "should get value info to obj", ->
      result = object.create a:13
      result = result.toJson()
      result = JSON.parse result
      result.should.be.deep.equal "attributes": {},"name":"Object","fullName":"type/Object", value: {a:13}
  describe ".createValue()/.create()", ->
    #TODO
    it "should create a value", ->
      n = object.create({a:12})
      assert.deepEqual n.valueOf(), a:12
    it "should not create a value (exceed limits)", ->
      assert.throw object.create.bind(object, 1234)
  describe ".assign()", ->
    #TODO
    it "should assign a value", ->
      n = object.create({})
      assert.deepEqual n.assign({a:13}).valueOf(), {a:13}

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
    it "should validate a value and do not raise error", ->
      t.validate({c:"hi"}).should.be.equal true
      t.validate({a:""}, false).should.be.equal false
      t.errors.should.be.deep.equal ["name": "[attribute c]", "message": "is required"]
      t.validate({b:12}, false).should.be.equal false
      t.errors.should.be.deep.equal [
        "name": "[attribute b]"
        "message": "should be equal or less than maximum value: 10"
      ,
        "name": "[attribute c]"
        "message": "is required"
      ]
    it "should validate a object attribute value and do not raise error", ->
      t.validate({c:"hi", d:{d2:""}}).should.be.equal true
      t.validate({c:"hi", d:{d1:1}}, false).should.be.equal false
      t.errors.should.be.deep.equal ["name": "[attribute d2]", "message": "is required"]
    it "should validate a value and raise error", ->
      should.throw t.validate.bind(t, 0), 'is not a valid'
      should.throw t.validate.bind(t, 11), 'is not a valid'
    it "should validate an encoded value", ->
      t.validate('{"c":""}').should.be.equal true

