chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type            = require '../src/type-info'
Value           = require '../src/value'
require '../src/number'
require '../src/string'

setImmediate    = setImmediate || process.nextTick

describe 'Value', ->
  describe '.constructor', ->
    it 'should create a value via number type', ->
      number = Type('Number', min: undefined, max: undefined)
      should.exist number
      val = Value(1, number)
      should.exist val
      val.should.be.an.instanceOf Value
      assert.equal Number(val), 1
      assert.equal val.$type, number
      assert.equal number, Type('Number')
    it 'should create a value via string type', ->
      mytype = Type('String', min: undefined, max: undefined)
      should.exist mytype
      val = Value('hallo', mytype)
      should.exist val
      val.should.be.an.instanceOf Value
      assert.equal String(val), 'hallo'
      assert.equal val.$type, mytype
      assert.equal mytype, Type('String')
    it 'should create a number value via no type object', ->
      number = Type('Number', min: undefined, max: undefined)
      should.exist number
      val = Value(1)
      should.exist val
      val.should.be.an.instanceOf Value
      assert.equal Number(val), 1
      assert.equal val.$type, number
      assert.equal number, Type('Number')
    it 'should create a string value via no type object', ->
      mytype = Type('String', min: undefined, max: undefined)
      should.exist mytype
      val = Value('hallo')
      should.exist val
      val.should.be.an.instanceOf Value
      assert.equal String(val), 'hallo'
      assert.equal val.$type, mytype
      assert.equal mytype, Type('String')
    it 'should create a string value with specified limits via no type object', ->
      val = Value('hallo', max:10, min:1)
      should.exist val
      val.should.be.an.instanceOf Value
      assert.equal String(val), 'hallo'
      mytype = val.$type
      assert.notEqual mytype, Type('String')
      mytype.should.have.property 'min', 1
      mytype.should.have.property 'max', 10
  describe '.assign', ->
    mytype = Type.create('String', min: 1, max: 10)
    it 'should assign a new value', ->
      val = Value('1', mytype)
      assert.equal String(val), '1'
      val.assign 'hi world'
      assert.equal String(val), 'hi world'
    it 'should assign a new value and dont check validity', ->
      val = Value('1', mytype)
      val.assign 'hi world over ten chars', checkValidity: false
      assert.equal String(val), 'hi world over ten chars'
      assert.equal val.isValid(), false
  describe '.toObject', ->
    it 'should convert value to object', ->
      val = Value('1234567890', max:10, min:1)
      result = val.toObject()
      result.should.be.deep.equal 
        max: 10
        min: 1
        name: 'String'
        fullName: 'type/String'
        value: '1234567890'
  describe '.toJson', ->
    it 'should convert value to json object', ->
      val = Value('1234567890', max:10, min:1)
      result = val.toJson()
      result = JSON.parse result
      result.should.be.deep.equal 
        max: 10
        min: 1
        name: 'String'
        fullName: 'type/String'
        value: '1234567890'

