chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Type            = require '../src/function'
setImmediate    = setImmediate || process.nextTick

describe "FunctionType", ->
  func = Type "Function",
    scope:
      A: 12
      B: 15
      log: console.log
    ,
    globalScope:
      log: console.log
      echo: (a)->a
  it "should have Function type", ->
    should.exist Function
    func.should.be.an.instanceOf Type['Function']
    func.pathArray().should.be.deep.equal ['type','Function']
  describe ".encode()", ->
    it "should encode type info", ->
      func.encode().should.be.equal '
        {"scope":{"A":12,"B":15,"log":"log"},"name":"Function","fullName":"/type/Function"}'
  describe ".decode()", ->
    it "should decode type info to parametric object", ->
      obj = func.encode()
      func.decode(obj).should.be.deep.equal func.toObject()
    it "should throw error when decode invalid string(exceed length limits)", ->
      should.throw func.decode.bind(func, 'asddf')
  describe ".toObject()", ->
    it "should get type info to obj", ->
      result = func.toObject typeOnly: true
      result.should.be.deep.equal
        "scope":{"A":12,"B":15,"log":"log"}
        "name":"Function"
        "fullName":"/type/Function"
    it "should get value and type info to obj", ->
      f = ->
      v = func.createValue(f)
      result = func.toObject(value:v, typeOnly: false)
      result.should.be.deep.equal
        "scope":{"A":12,"B":15,"log":"log"}
        name:"Function"
        fullName:"/type/Function"
        value:v
  describe ".toJson()", ->
    it "should get type info via json string", ->
      result = func.toJson()
      result = JSON.parse result
      result.should.be.deep.equal
        "scope":{"A":12,"B":15,"log":"log"}
        name:"Function"
        fullName:"/type/Function"
    it "should get type info via JSON.stringify", ->
      result = JSON.stringify func
      result = JSON.parse result
      result.should.be.deep.equal
        "scope":{"A":12,"B":15,"log":"log"}
        name:"Function"
        fullName:"/type/Function"
    it "should get value info via json string", ->
      f = -> log('hi my f')
      v = func.createValue(f)
      result = func.toJson(value: v)
      result = JSON.parse result
      result.should.be.deep.equal
        "scope":{"A":12,"B":15,"log":"log"}
        name:"Function"
        fullName:"/type/Function"
        value: "function () {\n          return log('hi my f');\n        }"
  describe ".createValue()/.create()", ->
    it "should create a value", ->
      f = -> log('hi my f')
      v = func.create(f)
      assert.equal v.valueOf(), f
      assert.equal String(v),
        'function () {\n          return log(\'hi my f\');\n        }'
    it "should not create a value (not function)", ->
      assert.throw func.create.bind(func, "1234")
  describe ".assign()", ->
    it "should assign a function value", ->
      f = -> log('hi my f')
      v = func.create(->)
      assert.equal String(v.assign(f)),
        'function () {\n          return log(\'hi my f\');\n        }'
    it "should assign a function string value", ->
      f = 'function (){log(\'hi\')}'
      v = func.create(->)
      assert.equal String(v.assign(f)), f
    it "should assign a function value with scope", ->
      f = 'function () {return "hi my "+my;}'
      v = func.create f, scope:
        my: 123
      result = v.valueOf()
      result = result()
      assert.equal result, 'hi my 123'
    it "should assign a function value with scope func", ->
      f = 'function (a) {return echo("hi"+a)}'
      v = func.create f, scope:
        my: 123
        echo: 'echo'
      result = v.valueOf()
      result = result(123)
      assert.equal result, 'hi123'
