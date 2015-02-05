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
  describe ".toString()", ->
    it "should get type info via string", ->
      String(number).should.be.equal '{"max":34,"min":5,"name":"Number","fullName":"type/Number"}'


