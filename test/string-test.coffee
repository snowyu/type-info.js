chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type            = require '../src/string'
setImmediate    = setImmediate || process.nextTick

describe "StringType", ->
  string = Type("String")
  it "should have String type", ->
    should.exist string
    string.should.be.an.instanceOf Type['String']
    string.pathArray().should.be.deep.equal ['type','String']
  describe ".encode()", ->
    it "should encode type info", ->
      string.encode().should.be.equal '
        {"name":"String","fullName":"/type/String"}'
  describe ".decode()", ->
    it "should decode type info", ->
      s = '{"name":"String","fullName":"/type/String"}'
      result = string.decode(s)
      console.log result
      result.should.be.deep.equal "name":"String","fullName":"/type/String"
    it "should throw error when decode invalid string", ->
      should.throw string.decode.bind(string, 'asddf')
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = string.createType(min:2,max:3).toObject
        typeOnly: true
      result.should.be.deep.equal
        max:3
        min:2
        name:"String"
        fullName:"/type/String"
    it "should get value info to obj", ->
      result = string.create("asd")
      result = result.toObject()
      result.should.be.equal "asd"
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = string.createType(min:2,max:3).toJson
        typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal
        max:3
        min:2
        name:"String"
        fullName:"/type/String"
    it "should get value info via json string", ->
      result = string.create("asd")
      result = result.toJson()
      result = JSON.parse result
      result.should.be.equal "asd"
  describe ".createValue()/.create()", ->
    it "should create a value", ->
      s = string.create("123")
      assert.equal String(s), "123"
    it "should not create a value (exceed length limits)", ->
      string.initialize max:3, min:2
      assert.throw string.create.bind(string, "1234")
    it "should throw error when value not string type", ->
      should.throw string.create.bind(string, 1), "is an invalid"
    it "should throw error when string length < min", ->
      string.initialize min: 2
      should.throw string.create.bind(string, '1'), "is an invalid"
    it "should throw error when string length > max", ->
      string.initialize max: 3
      should.throw string.create.bind(string, 'sd123'), "is an invalid"
  describe ".assign()", ->
    it "should assign a value", ->
      n = string.create('12')
      assert.equal String(n.assign('bb')), 'bb'
