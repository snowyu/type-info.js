factory         = require("custom-factory")
isObject        = require("util-ex/lib/is/type/object")
isFunction      = require("util-ex/lib/is/type/function")
isString        = require("util-ex/lib/is/type/string")
isArray         = require("util-ex/lib/is/type/array")
isUndefined     = require("util-ex/lib/is/type/undefined")
#isBoolean     = require("util-ex/lib/is/type/boolean")
extend          = require("util-ex/lib/extend")
defineProperty  = require("util-ex/lib/defineProperty")
createObject    = require("inherits-ex/lib/createObject")
try Codec       = require("buffer-codec")

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
    defineProperty @, 'errors', []
    if aOptions
      if aOptions.encoding
        encoding = aOptions.encoding
        encoding = Codec encoding if Codec and isString encoding
        if isFunction(encoding.encode) and isFunction(encoding.decode) and encoding.name
          @encoding = encoding
        else
          throw new TypeError "encoding should have name property, encode and decode functions."
      @required = aOptions.required if aOptions.required?
      @assign(v, aOptions) if (v=aOptions.value)?
      @_initialize aOptions if @_initialize
    return
  _isEncoded:->false
  isEncoded: (aValue, aOptions)->
    result = aOptions.isEncoded if aOptions
    result = @_isEncoded(aValue, aOptions) unless result?
    result
  assign: (aValue, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    if aOptions and aOptions.isEncoded
      @value = @decode aValue, aOptions
    else
      @validate(aValue, checkValidity, aOptions) if checkValidity isnt false
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
    checkValidity = aOptions.checkValidity or aOptions.raiseError if aOptions
    if isUndefined(aString)
      @error 'decode string to value error', aOptions
      if checkValidity isnt false
        throw new TypeError('decode error:string "'+aString+ '" is not a valid '+@name)
    aString
  decode: (aString, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    aString = @decodeString aString, aOptions
    @validate(aString, checkValidity, aOptions) if checkValidity isnt false
    aString
  mergeOptions: (aOptions, aExclude)->
    aOptions = {} unless isObject aOptions
    if isString aExclude
      aExclude = [aExclude]
    else if not isArray aExclude
      aExclude = []
    extend aOptions, @, (key)->not (aOptions.hasOwnProperty(key) or (key in aExclude))
    aOptions
  _validate: (aValue, aOptions)->true
  error: (aMessage, aOptions)->
    name = (aOptions && aOptions.name) || @name
    @errors.push name: name, message: aMessage
    return
  validateRequired: (aValue, aOptions)->
    result = not aOptions.required or (aOptions.required is true and aValue?)
    if not result
      @error 'is required'
    result
  validate: (aValue, raiseError, aOptions)->
    @errors = []
    if isObject raiseError
      aOptions    = raiseError
      raiseError  = aOptions.raiseError
    aOptions = @mergeOptions(aOptions)
    aOptions.raiseError = true if raiseError
    aValue = @decodeString aValue, aOptions if @isEncoded(aValue, aOptions)
    result = @validateRequired aValue, aOptions
    result = @_validate(aValue, aOptions) if result and aValue?
    throw new TypeError(aValue + ' is not a valid ' + @name) if raiseError isnt false and not result
    result
  isValid: (aValue) ->
    aValue = @value if isUndefined aValue
    @_validate(aValue, @)
  create: (aValue, aOptions)->
    aOptions = @mergeOptions(aOptions)
    aOptions.value = aValue if aValue?
    aOptions.name = @name unless aOptions.name
    createObject @Class, aOptions
  createValue: @::create
  clone: (aOptions)->@create(null, aOptions)
  createType: (aOptions)->
    delete aOptions.value if aOptions
    createObject @Class, aOptions
  cloneType: (aOptions)->
    aOptions = @mergeOptions(aOptions)
    aOptions.name = @name unless aOptions.name
    @createType aOptions
  # Get aType class from the encoded string.
  from: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    throw new TypeError("should decode string to object") if isString(aString) and not isObject(aString)
    Type aString
  createfrom: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    throw new TypeError("should decode string to object") if isString(aString) and not isObject(aString)
    vType = aString.name
    vType = Type.registeredClass vType
    if vType then createObject vType, aString
  # Get a Type class from the json string.
  @fromJson: (aString)->
    aString = JSON.parse aString
    Type aString
  @createFromJson: (aString)->
    aString = JSON.parse aString
    Type.create aString.name, aString
      
  toString: ->if @value then String(@value) else '[type '+ @name+']'
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
      value = if aOptions.value? then aOptions.value else @value
      if not aOptions.typeOnly and value?
        if aOptions.isEncoded
          result.value = @encode(value, aOptions)
          result.isEncoded = true
        else
          result.value = value
    result
  valueOf: ->@value

