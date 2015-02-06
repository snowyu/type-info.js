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
    it "should encode value", ->
      string.encode('asv').should.be.equal "asv"
    it "should throw error when value not string type", ->
      should.throw string.encode.bind(string, 1), "is not a valid"
    it "should throw error when string length < min", ->
      string.initialize min: 2
      should.throw string.encode.bind(string, '1'), "is not a valid"
    it "should throw error when string length > max", ->
      string.initialize max: 3
      should.throw string.encode.bind(string, 'sd123'), "is not a valid"
  describe ".decode()", ->
    it "should decode value", ->
      string.decode("25").should.be.equal "25"
    it "should throw error when decode invalid string(exceed length limits)", ->
      should.throw string.decode.bind(string, 'asddf'), "is not a valid"
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = string.toObject typeOnly: true
      result.should.be.deep.equal max:3,min:2,name:"String",fullName:"type/String"
    it "should get value info to obj", ->
      result = string.create("asd")
      result = result.toObject() 
      result.should.be.deep.equal max:3,min:2,name:"String",fullName:"type/String", value:"asd"
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = string.toJson typeOnly: true
      result = JSON.parse result
      result.should.be.deep.equal max:3,min:2,name:"String",fullName:"type/String"
    it "should get value info via json string", ->
      result = string.create("asd")
      result = result.toJson() 
      result = JSON.parse result
      result.should.be.deep.equal max:3,min:2,name:"String",fullName:"type/String", value:"asd"
  describe ".createValue()/.create()", ->
    it "should create a value", ->
      s = string.create("123")
      assert.equal String(s), "123"
    it "should not create a value (exceed length limits)", ->
      assert.throw string.create.bind(string, "1234")
  describe ".assign()", ->
    it "should assign a value", ->
      n = string.create('12')
      assert.equal String(n.assign('bb')), 'bb'


