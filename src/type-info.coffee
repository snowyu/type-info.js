factory     = require("custom-factory")
isObject    = require("util-ex/lib/is/type/object")
isFunction  = require("util-ex/lib/is/type/function")
extend      = require("util-ex/lib/_extend")

getProtoChain = (ctor)->
  result = while ctor and ctor isnt Type
    name = ctor::name
    ctor = ctor.super_
    name

module.exports = class Type
  factory Type

  @ROOT_NAME: 'type'
  constructor: (aTypeName, aOptions)->
    return super
  initialize: (aOptions)->
    if aOptions
      if aOptions.encoding
        encoding = aOptions.encoding
        if isFunction(encoding.encode) and isFunction(encoding.decode)
          @encoding = encoding
        else
          throw new TypeError "encoding should have encode and decode functions."
      if aOptions.value?
        v = aOptions.value
        throw new TypeError(v + ' is not a valid ' + @name) if aOptions.checkValidity isnt false and not @validate(v)
        @value = v
      else if aOptions.valueStr
        @value = @decode aOptions.valueStr, aOptions
  path: ->
    @pathArray().join '/'
  pathArray: ->
    result = getProtoChain(@Class)
    result.push Type.ROOT_NAME
    result.reverse()
  encode: (aValue, aCheckValidity, aOptions)->
    if @value
      aOptions = aCheckValidity
      aCheckValidity = aValue
      aValue = @value
    if isObject aCheckValidity
      aOptions = aCheckValidity
      aCheckValidity = aOptions.checkValidity
    throw new TypeError(aValue + ' is not a valid ' + @name) if aCheckValidity isnt false and not @validate(aValue)
    aValue = @encoding.encode aValue, aOptions if @encoding
    aValue = @_encode aValue, aCheckValidity, aOptions if @_encode
    aValue
  decode: (aString, aCheckValidity, aOptions)->
    if isObject aCheckValidity
      aOptions = aCheckValidity
      aCheckValidity = aOptions.checkValidity
    aString = @encoding.decode aString, aOptions if @encoding
    aString = @_decode aString, aCheckValidity, aOptions if @_decode
    throw new TypeError(aString + ' is not a valid ' + @name) if aCheckValidity isnt false and not @validate(aString)
    aString
  validate: (aValue)->true
  create: (aValue, aOptions)->new @class aValue, extend {}, @, aOptions
  createValue: @::create
  # Get a Type class from the json string.
  @fromJson: (aString)->
    aString = JSON.parse aString
    Type aString
  @createFromJson: (aString)->
    aString = JSON.parse aString
    vType = aString.name
    vType = Type.registeredClass vType
    if vType then new vType(aString)
      
  toString: (aCheckValidity, aOptions)->
    if @value then @encode aCheckValidity, aOptions else @typeInfoToString()
  typeInfoToString: ->
    result = extend {}, @
    result.name = @name
    result.fullName = @path()
    result = JSON.stringify result
    result
  valueOf: ->@value

