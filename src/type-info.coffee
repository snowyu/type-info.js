factory         = require("custom-factory")
deepEqual       = require('deep-equal')
isObject        = require("util-ex/lib/is/type/object")
isFunction      = require("util-ex/lib/is/type/function")
isString        = require("util-ex/lib/is/type/string")
isArray         = require("util-ex/lib/is/type/array")
isUndefined     = require("util-ex/lib/is/type/undefined")
#inject          = require("util-ex/lib/inject")
#isBoolean     = require("util-ex/lib/is/type/boolean")
extend          = require("util-ex/lib/extend")
defineProperty  = require("util-ex/lib/defineProperty")
createObject    = require("inherits-ex/lib/createObject")
try Codec       = require("buffer-codec")
#Value           = require("./value")

objectToString = Object::toString

class Value
  @tryGetTypeName: (aValue)->
    if aValue instanceof Object
      result = objectToString.call aValue
      i = result.lastIndexOf ' '
      result = result.substring(i+1, result.length-1) if i >= 0
    else
      result = typeof aValue
    result
  constructor: (aValue, aType, aOptions)->
    if not (aType instanceof Type)
      aOptions = aType
      vTypeName = Value.tryGetTypeName(aValue)
      if aOptions
        # TODO: whether cache this type?
        aType = Type.create vTypeName, aOptions
      else
        aType = Type vTypeName
      throw new TypeError 'can not determine the value type.' unless aType
    if not (this instanceof Value)
      return createObject aType.ValueType, aValue, aType, aOptions
    defineProperty @, '$type', aType
    @_initialize(aValue, aType, aOptions)
    @assign(aValue)
  isValid: ()->@$type.isValid(@valueOf())
  _initialize: (aValue, aType, aOptions)->
    defineProperty @, 'value', null
  _assign:(aValue)->
    @value = aValue
    return
  assign: (aValue, aOptions)->
    checkValidity = aOptions.checkValidity if aOptions
    if aValue instanceof Value
      aValue = aValue.valueOf()
    else if @$type._decodeValue
      aValue = @$type._decodeValue aValue
    @$type.validate(aValue, checkValidity) if checkValidity isnt false
    @_assign aValue
    @
  create: (aValue, aOptions)->
    @$type.createValue aValue, aOptions
  clone: (aOptions) ->
    @create @valueOf(), aOptions
  toString: (aOptions)->
    String(@valueOf())
  valueOf: ->@value
  _toObject: (aOptions)->@valueOf()
  toObject: (aOptions)->
    result = @_toObject(aOptions)
    result
  toObjectInfo: (aOptions)->
    result = @toObject(aOptions)
    aOptions = {} unless aOptions
    aOptions.value = result
    @$type.toObject(aOptions)
  # assign value from JSON string.
  fromJson: (aString)->
    aString = JSON.parse aString
    decode = @$type._decodeValue
    aString = decode aString if decode
    @assign aString
  # create a new value object from JSON string.
  createFromJson: (aString)->
    aString = JSON.parse aString
    decode = @$type._decodeValue
    aString = decode aString if decode
    createObject @$type.ValueType, aString, @$type
  toJSON: (aOptions)->
    result = @toObject(aOptions)
    encode = @$type._encodeValue
    result = encode result if encode
    result
  toJson: (aOptions)->
    result = @toJSON(aOptions)
    JSON.stringify result


module.exports = class Type
  factory Type

  @ROOT_NAME: 'type'
  # export the Value Class from here
  @Value: Value
  # override for inherited type class:
  ValueType: Value

  @JSON_ENCODING:
    name: 'json'
    encode: JSON.stringify
    decode: JSON.parse
  @DEFAULT_ENCODING: @JSON_ENCODING
  @getEncoding: (encoding)->
    if !encoding or encoding is Type.DEFAULT_ENCODING.name
      return Type.DEFAULT_ENCODING
    if isString encoding
      if Codec
        encoding = Codec encoding
      else
        throw new TypeError "
          Should install buffer-codec package first
          to enable encoding name supports.
        "
    if !isFunction(encoding.encode) or
       !isFunction(encoding.decode) or !encoding.name
      throw new TypeError "
        encoding should have name property, encode and decode functions.
      "
    encoding

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
      @encoding = Type.getEncoding aOptions.encoding
      @required = aOptions.required if aOptions.required?
      @parent   = aOptions.parent if aOptions.parent
      @name = aOptions.name if aOptions.name
    else
      @encoding = Type.getEncoding()
    @_assign aOptions if @_assign
    @
  #TODO: serialize the encoding etc attributes to custom value here.
  mergeOptions: (aOptions, aExclude, aSerialized)->
    aOptions = {} unless isObject aOptions
    if isString aExclude
      aExclude = [aExclude]
    else if not isArray aExclude
      aExclude = []
    extend aOptions, @, (key, value)->
      result = not aOptions.hasOwnProperty(key) and not (key in aExclude) and
        value isnt undefined and
        (!aSerialized or key[0] isnt '$')
      result
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
    result = @validateRequired aValue, aOptions
    result = @_validate(aValue, aOptions) if result and aValue?
    if raiseError isnt false and not result
      throw new TypeError('"'+aValue + '" is an invalid ' + @name)
    result
  isValid: (aValue) ->
    @validate(aValue, false)
  # TODO: deeply compare type options
  #   need ignore redundant properties in aOptions,
  #   skip some properties, custom filter.
  isSame: (aOptions)->
    #deepEqual @, aOptions
    for k,v of @
      if k is 'encoding'
        if (v.name isnt Type.DEFAULT_ENCODING.name) or aOptions[k]?
          return false unless aOptions[k].name is v.name
        continue
      return false unless deepEqual aOptions[k], v
    return true

  createValue: (aValue, aOptions)->
    if aOptions and not @isSame(aOptions)
      aOptions = @mergeOptions(aOptions)
      # TODO: seperate the cache-able ability
      if isFunction Type.getCacheItem
        # this Type Factory is cache-able.
        aOptions.cached = true unless aOptions.cached?
        vType = Factory.getCacheItem @Class, aOptions
      else
        vType = @createType aOptions
    else
      vType = @
    #Value(aValue, vType, aOptions)
    createObject vType.ValueType, aValue, vType, aOptions
  create: @::createValue
  createType: (aOptions)->
    delete aOptions.value if aOptions
    createObject @Class, aOptions
  cloneType: (aOptions)->
    aOptions = @mergeOptions(aOptions)
    aOptions.name = @name unless aOptions.name
    @createType aOptions
  clone: @::cloneType
  # Get a global Type class or create new Value from the json string.
  @fromJson: (aString)->
    #aString = JSON.parse aString
    Type.from JSON.parse(aString)
  # create a new Type instance  or create new Value from json string.
  @createFromJson: (aString)->
    Type.createFrom JSON.parse aString

  encode: (aOptions)->
    aOptions = @mergeOptions(aOptions, null, true)
    aOptions.encoding.encode @toObject(aOptions)
  decode: (aEncoded, aOptions) ->
    aOptions = @mergeOptions(aOptions)
    aOptions.encoding.decode aEncoded

  @from: (aObject) ->
    result = Type aObject
    if aObject.value? and result
      result = result.createValue aObject.value
    result
  @createFrom: (aObject)->
    value   = aObject.value
    result  = Type.create aObject.name, aObject
    result  = result.createValue value if value? and result
    result

  toString: (aOptions)->
    if not @parent then '[type '+ @name+']' else '[attribute ' +@name+']'
  toJSON: ()-> @toObject()
  toJson: (aOptions)->
    result = @toObject(aOptions)
    result = JSON.stringify result
    result
  _toObject:(aOptions)->
    result = @mergeOptions aOptions, null, true
    result.name = @name
    result.fullName = @path()
    vEncoding = result.encoding
    if vEncoding and vEncoding.name isnt Type.DEFAULT_ENCODING.name
      result.encoding = vEncoding.name
    else
      delete result.encoding
    result
  toObject: (aOptions)->
    if aOptions
      if not aOptions.typeOnly and not isUndefined aOptions.value
        value = aOptions.value
      delete aOptions.typeOnly
    result = @_toObject(aOptions)
    result.value = value unless isUndefined value
    result
