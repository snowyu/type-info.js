factory     = require("custom-factory")
isObject    = require("util-ex/lib/is/type/object")
isFunction  = require("util-ex/lib/is/type/function")
isString    = require("util-ex/lib/is/type/string")
extend      = require("util-ex/lib/extend")
createObject= require("inherits-ex/lib/createObject")
try Codec   = require("buffer-codec")

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
        encoding = Codec encoding if Codec and isString encoding
        if isFunction(encoding.encode) and isFunction(encoding.decode) and encoding.name
          @encoding = encoding
        else
          throw new TypeError "encoding should have name property, encode and decode functions."
      @assign(v, aOptions) if (v=aOptions.value)?
    return
  assign: (aValue, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    if aOptions and aOptions.isEncoded
      @value = @decode aValue, aOptions
    else
      @validate(aValue, checkValidity)
      @value = aValue
    return @
  path: ->
    @pathArray().join '/'
  pathArray: ->
    result = getProtoChain(@Class)
    result.push Type.ROOT_NAME
    result.reverse()
  encodeValue: (aValue, aOptions)->
    aValue = @encoding.encode aValue, aOptions if @encoding
    aValue = @_encode aValue, aOptions if @_encode
    aValue
  encode: (aValue, aOptions)->
    if @value and arguments.length <= 1
      aOptions = aValue
      aValue = @value
    checkValidity = aOptions.checkValidity if aOptions
    @validate(aValue, checkValidity) if checkValidity isnt false
    aValue = @encodeValue aValue, aOptions
    aValue
  decodeString: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    aString = @_decode aString, aOptions if @_decode
    aString
  decode: (aString, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    aString = @decodeString aString, checkValidity, aOptions
    @validate(aString, checkValidity) if checkValidity isnt false
    aString
  _validate: ->true
  validate: (aValue, raiseError)->
    result = @_validate(aValue)
    throw new TypeError(aValue + ' is not a valid ' + @name) if raiseError isnt false and not result
    result
  isValid: (aValue) ->
    aValue = @value if aValue is undefined
    @_validate(aValue)
  create: (aValue, aOptions)->
    aOptions = {} unless aOptions
    extend aOptions, @, (key)->not aOptions.hasOwnProperty key
    aOptions.value = aValue
    createObject @Class, aOptions
  createValue: @::create
  # Get aType class from the encoded string.
  from: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    throw new TypeError("should decode string to object") if isString(aString) and not isObject(aString)
    Type aString
  # Get a Type class from the json string.
  @fromJson: (aString)->
    aString = JSON.parse aString
    Type aString
  @createFromJson: (aString)->
    aString = JSON.parse aString
    vType = aString.name
    vType = Type.registeredClass vType
    if vType then new vType(aString)
      
  toString: ->String(@value) if @value
  toJson: (aOptions)->
    result = @toObject(aOptions)
    result = JSON.stringify result
    result
  toObject: (aOptions)->
    result = extend {}, @
    result.name = @name
    result.fullName = @path()
    result.encoding = @encoding.name if @encoding
    if aOptions
      if not aOptions.typeOnly and @value
        if aOptions.isEncoded
          result.value = @encode(aOptions)
          result.isEncoded = true
        else
          result.value = @value
    result
  valueOf: ->@value

