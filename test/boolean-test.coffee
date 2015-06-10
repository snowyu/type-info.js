chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type            = require '../src/boolean'
setImmediate    = setImmediate || process.nextTick

describe "BooleanType", ->
  bool = Type("Boolean")
  it "should have this type", ->
    should.exist bool
    bool.should.be.an.instanceOf Type['Boolean']
    bool.pathArray().should.be.deep.equal ['type','Boolean']
  describe ".encode()", ->
    it "should encode type info", ->
      bool.encode().should.be.equal '
        {"name":"Boolean","fullName":"/type/Boolean"}'
  describe ".decode()", ->
    it "should decode type info", ->
      s = '{"name":"Boolean","fullName":"/type/Boolean"}'
      bool.decode(s).should.be.deep.equal
        "name":"Boolean"
        "fullName":"/type/Boolean"
    it "should throw error when decode invalid boolean type object", ->
      should.throw bool.decode.bind(bool, undefined)
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = bool.createType()
      result = result.toObject()
      result.should.be.deep.equal
        "name":"Boolean"
        "fullName":"/type/Boolean"
  describe "value.toObject()", ->
    it "should get value info to obj", ->
      result = bool.createType()
      result = result.createValue true
      result = result.toObject()
      result.should.be.equal true
  describe "value.toObjectInfo()", ->
    it "should get value with type info to obj", ->
      result = bool.create(false)
      result = result.toObjectInfo()
      result.should.be.deep.equal
        "name":"Boolean"
        "fullName":"/type/Boolean"
        value: false
  describe ".toString()", ->
    it "should get type name if no value", ->
      result = String(bool)
      result.should.be.equal '[type Boolean]'
    it "should get value string if value", ->
      result = bool.create(true)
      result = String(result)
      result.should.be.equal 'true'
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = bool.clone().toJson typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal
        "name":"Boolean"
        "fullName":"/type/Boolean"
    it "should get value info to obj", ->
      result = bool.create(true)
      Number(result).should.be.equal 1
  describe ".createValue()/.create()", ->
    it "should create a value", ->
      n = bool.create(false)
      assert.equal Number(n), 0
  describe ".assign()", ->
    it "should assign a value", ->
      n = bool.create(false)
      assert.equal Number(n.assign(true)), 1
      assert.equal Number(n.assign('no')), 0

  describe ".validate()", ->
    t = bool.cloneType()
    it "should validate a value and do not raise error", ->
      t.validate(true).should.be.equal true
      t.validate('yes').should.be.equal true
      t.validate('no').should.be.equal true
      t.validate('true').should.be.equal true
      t.validate('false').should.be.equal true
      t.validate('yska', false).should.be.equal false
    it "should validate a value and raise error", ->
      should.throw t.validate.bind(t, '1ssa'), 'is an invalid'
      should.throw t.validate.bind(t, 'dsd23'), 'is an invalid'
    it "should validate an encoded value", ->
      t.validate('true').should.be.equal true
      t.validate(1).should.be.equal true
    it "should validate an encoded value via added to strBool array", ->
      t.strBool[0].push '否'
      t.strBool[1].push '是'
      t.validate('是').should.be.equal true
      t.validate('否').should.be.equal true
      n = t.createValue(false)
      Number(n.assign('是')).should.be.equal 1
      Number(n.assign('否')).should.be.equal 0
