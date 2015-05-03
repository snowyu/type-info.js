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
#Value           = require("./value")

objectToString = Object::toString

getTypeName = (aValue)->
  if aValue instanceof Object
    result = objectToString.call aValue
    i = result.lastIndexOf ' '
    result = result.substring(i+1, result.length-1) if i >= 0
  else
    result = typeof aValue
  result

class Value
  constructor: (aValue, aType, aOptions)->
    if not (this instanceof Value)
      if not (aType instanceof Type)
        aOptions = aType
        if aOptions
          aType = Type.create getTypeName(aValue), aOptions
        else
          aType = Type getTypeName(aValue)
      return createObject aType.ValueType, aValue, aType
    defineProperty @, '$type', aType
    @assign(aValue)
  isValid: ()->@$type.isValid(@valueOf())
  _assign:(aValue)->
    @value = aValue
    return
  assign: (aValue, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    if aOptions and aOptions.isEncoded
      @_assign @$type.decode aValue, aOptions
    else
      @$type.validate(aValue, checkValidity) if checkValidity isnt false
      @_assign aValue
    return @
  create: (aValue, aOptions)->
    @$type.createValue aValue, aOptions
  clone: @::create
  toString: ->String(@value)
  valueOf: ->@value
  toObject: (aOptions)->
    aOptions = {} unless aOptions
    aOptions.value = @valueOf()
    result = @$type.toObject(aOptions)
    result
  toJson: (aOptions)->
    result = @toObject(aOptions)
    result = JSON.stringify result
    result

module.exports = class Type
  factory Type

  @ROOT_NAME: 'type'
  @Value: Value
  ValueType: Value
  constructor: (aTypeName, aOptions)->
    return super
  initialize: (aOptions)->
    defineProperty @, 'errors', null
    @_initialize aOptions if @_initialize
    @assign(aOptions)
  finalize: (aOptions)->
    @errors = null if @errors
    @encoding = null if @encoding
    @_finalize(aOptions) if @_finalize
  assign: (aOptions)->
    @errors = []
    if aOptions
      if aOptions.encoding
        encoding = aOptions.encoding
        encoding = Codec encoding if Codec and isString encoding
        if isFunction(encoding.encode) and
           isFunction(encoding.decode) and encoding.name
          @encoding = encoding
        else
          throw new TypeError "
            encoding should have name property, encode and decode functions.
          "
      @required = aOptions.required if aOptions.required?
      @parent   = aOptions.parent if aOptions.parent
      @name = aOptions.name if aOptions.name
    @_assign aOptions if @_assign
    @
  _isEncoded:->false
  isEncoded: (aValue, aOptions)->
    result = aOptions.isEncoded if aOptions
    result = @_isEncoded(aValue, aOptions) unless result?
    result
  pathArray: (aRootName = Type.ROOT_NAME)->
    return super(aRootName)
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
        throw new TypeError('decode error:string "'+aString+ '" is a invalid '+@name)
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
    name = (aOptions && aOptions.name) || String(@)
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
    if raiseError isnt false and not result
      throw new TypeError('"'+aValue + '" is a invalid ' + @name)
    result
  isValid: (aValue) ->
    @validate(aValue, false)
  createValue: (aValue, aOptions)->
    if aOptions
      aOptions = @mergeOptions(aOptions)
      vType = createObject @Class, aOptions
    else
      vType = @
    Value aValue, vType
  create: @::createValue
  createType: (aOptions)->
    delete aOptions.value if aOptions
    createObject @Class, aOptions
  cloneType: (aOptions)->
    aOptions = @mergeOptions(aOptions)
    aOptions.name = @name unless aOptions.name
    @createType aOptions
  clone: @::cloneType
  # Get aType class from the encoded string.
  fromString: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    throw new TypeError("should decode string to object") if isString(aString) and not isObject(aString)
    Type aString
  createfromString: (aString, aOptions)->
    aString = @encoding.decode aString, aOptions if @encoding
    throw new TypeError("should decode string to object") if isString(aString) and not isObject(aString)
    vType = aString.name
    vType = Type.registeredClass vType
    if vType then createObject vType, aString
  # Get a Type class from the json string.
  @fromJson: (aString)->
    aString = JSON.parse aString
    result = Type aString
    if aString.value? and result
      result.createValue aString.value, aString
    result
  @createFromJson: (aString)->
    aString = JSON.parse aString
    result = Type.create aString.name, aString
    if aString.value? and result
      result = result.createValue aString.value, aString
    result

  toString: ->if not @parent then '[type '+ @name+']' else '[attribute ' +@name+']'
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
      value = aOptions.value if aOptions.value?
      if not aOptions.typeOnly and value?
        if aOptions.isEncoded
          result.value = @encode(value, aOptions)
          result.isEncoded = true
        else
          result.value = value
    result
