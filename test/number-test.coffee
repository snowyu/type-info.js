chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type            = require '../src/number'
setImmediate    = setImmediate || process.nextTick

describe "NumberType", ->
  number = Type("Number")
  it "should have Number type", ->
    should.exist number
    number.should.be.an.instanceOf Type['Number']
    number.pathArray().should.be.deep.equal ['type','Number']
  describe ".encode()", ->
    it "should encode value", ->
      number.encode(0xff).should.be.equal "255"
    it "should throw error when encode invalid value", ->
      should.throw number.encode.bind(number, 'as'), "is not a valid"
    it "should throw error when value < min", ->
      number.initialize min: 5 
      should.throw number.encode.bind(number, '1'), "is not a valid"
    it "should throw error when value > max", ->
      number.initialize max: 34
      should.throw number.encode.bind(number, '125'), "is not a valid"
  describe ".decode()", ->
    it "should decode value", ->
      number.decode("25").should.be.equal 25
    it "should throw error when decode invalid string number", ->
      should.throw number.decode.bind(number, 'as'), "is not a valid"
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = number.toObject typeOnly: true
      result.should.be.deep.equal "max":34,"min":5,"name":"Number","fullName":"type/Number"
    it "should get value info to obj", ->
      result = number.create(13)
      result = result.toObject()
      result.should.be.deep.equal "max":34,"min":5,"name":"Number","fullName":"type/Number", value: 13
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = number.toJson typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal "max":34,"min":5,"name":"Number","fullName":"type/Number"
    it "should get value info to obj", ->
      result = number.create(13)
      result = result.toJson()
      result = JSON.parse result
      result.should.be.deep.equal "max":34,"min":5,"name":"Number","fullName":"type/Number", value: 13
  describe ".createValue()/.create()", ->
    it "should create a value", ->
      n = number.create(12)
      assert.equal Number(n), 12
    it "should not create a value (exceed limits)", ->
      assert.throw number.create.bind(number, 1234)
  describe ".assign()", ->
    it "should assign a value", ->
      n = number.create(12)
      assert.equal Number(n.assign(13)), 13

  describe ".validate()", ->
    t = number.cloneType min: 1, max: 10
    it "should validate a value and do not raise error", ->
      t.validate(2).should.be.equal true
      t.validate(0, false).should.be.equal false
      t.validate(11, false).should.be.equal false
    it "should validate a value and raise error", ->
      should.throw t.validate.bind(t, 0), 'is not a valid'
      should.throw t.validate.bind(t, 11), 'is not a valid'
    it "should validate an encoded value", ->
      t.validate("5").should.be.equal true

