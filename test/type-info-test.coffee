extend          = require 'util-ex/lib/extend'
chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

TypeInfo        = require '../src/type-info'
setImmediate    = setImmediate || process.nextTick
register        = TypeInfo.register

class TestType
  register TestType
  constructor: ->return super
  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max']
    return


describe "TypeInfo", ->
  describe ".pathArray()", ->
    it "should get default type path array", ->
      t = TypeInfo('Test')
      t.pathArray().should.be.deep.equal ['type','Test']
    it "should get cutomize root type path array", ->
      TypeInfo.ROOT_NAME = 'atype'
      t = TypeInfo('Test')
      t.pathArray().should.be.deep.equal ['atype','Test']

  describe ".fromJson()", ->
    it "should get type info object from json", ->
      t = TypeInfo.fromJson('{"name":"Test","min":2, "max":3}')
      should.exist t
      t.should.be.equal TypeInfo('Test')
      t.should.have.property 'max', 3
      t.should.have.property 'min', 2
  describe ".createFromJson()", ->
    it "should create a new type info object from json", ->
      T = TypeInfo.registeredClass 'Test'
      should.exist T
      T.should.be.equal TestType
      t = TypeInfo.createFromJson('{"name":"Test","min":1, "max":10}')
      should.exist t
      t.should.be.instanceOf TestType
      t.should.not.be.equal TypeInfo('Test')
      t.should.have.property 'max', 10
      t.should.have.property 'min', 1
    it "should create a new value object from json", ->
      obj = 
        name: "Test"
        min:2
        max:6
        value:5
      t = TypeInfo.createFromJson JSON.stringify obj
      should.exist t
      t.should.be.instanceOf TestType
      t.should.not.be.equal TypeInfo('Test')
      t.should.have.property 'max', 6
      t.should.have.property 'min', 2
      (""+t).should.be.equal "5"
      (t + 3).should.be.equal 8

