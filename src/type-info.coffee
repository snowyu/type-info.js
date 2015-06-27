isInheritedFrom = require('inherits-ex/lib/isInheritedFrom')
factory         = require('custom-factory')
deepEqual       = require('deep-equal')
isObject        = require('util-ex/lib/is/type/object')
isFunction      = require('util-ex/lib/is/type/function')
isString        = require('util-ex/lib/is/type/string')
isArray         = require('util-ex/lib/is/type/array')
isUndefined     = require('util-ex/lib/is/type/undefined')
extend          = require('util-ex/lib/extend')
defineProperty  = require('util-ex/lib/defineProperty')
createObject    = require('inherits-ex/lib/createObject')
Attributes      = require('./attributes/abstract-attributes')
attributes      = createObject require('./attributes/type')
#try Codec       = require('buffer-codec')

objectToString  = Object::toString
getObjectKeys   = Object.keys

metaNames = attributes.names
NAME = metaNames.name
REQUIRED = metaNames.required

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
    @assign(aValue, aOptions)
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
#End Value class


module.exports = class Type
  factory Type

  Attributes::Type = Type

  @ROOT_NAME: 'type'
  # export the Value Class from here
  @Value: Value
  # override for inherited type class:
  ValueType: Value
  $attributes: attributes

  constructor: (aTypeName, aOptions)->
    # create a new instance object if aOptions is not the original
    # options of the type.
    if not (this instanceof Type) and not (aTypeName instanceof Type)
      if aTypeName
        if isObject aTypeName
          aOptions = aTypeName
          aTypeName = aOptions.name || aOptions[attributes.name.name]
        else if not isString aTypeName
          aOptions = aTypeName
          aTypeName = undefined
      if not aTypeName
        # arguments.callee is forbidden if strict mode enabled.
        try vCaller = arguments.callee.caller
        if vCaller and isInheritedFrom vCaller, Type
          aTypeName = vCaller
          vCaller = vCaller.caller
          #get farest hierarchical registered class
          while isInheritedFrom vCaller, aTypeName
            aTypeName = vCaller
            vCaller = vCaller.caller
          aTypeName = Type.getNameFromClass(aTypeName) if aTypeName
        return unless aTypeName
      vTypeClass = Type.registeredClass aTypeName
      if vTypeClass and aOptions and
         not vTypeClass::$attributes.isOriginal(aOptions)
        return createObject vTypeClass, aOptions
    return super
  initialize: (aOptions)->
    defineProperty @, 'errors', null
    @$attributes.initializeTo @ if @$attributes
    @_initialize aOptions if @_initialize
    @assign(aOptions) if aOptions?
  finalize: (aOptions)->
    @errors = null if @errors
    #@encoding = null if @encoding
    @_finalize(aOptions) if @_finalize
  assign: (aOptions)->
    @errors = []
    if aOptions
      #@encoding = @getEncoding aOptions.encoding
      # assign aOptions to @
      if @$attributes
        @$attributes.assignTo(aOptions, @)
      else
        @[REQUIRED] = aOptions[REQUIRED] if aOptions[REQUIRED]?
        vName = aOptions[NAME] || aOptions.name
        @name = vName if vName and vName isnt @name
    #else
    #  @encoding = @getEncoding()
    @_assign aOptions if @_assign
    @
  # merge self to options(do not modify the original options)
  mergeTo: (aObject, aExclude, aSerialized, aNameRequired)->
    aObject = {} unless isObject aObject

    if isString aExclude
      aExclude = [aExclude]
    else if not isArray aExclude
      aExclude = []

    vAttributes = @$attributes
    if vAttributes
      for k,v of vAttributes.names
        continue if k in aExclude or aObject.hasOwnProperty(v)
        continue if v in aExclude
        continue if k is 'name'
        value = @[k]
        vAttr = vAttributes[k]
        vDefaultValue = vAttr.value
        continue if aSerialized and
           (k[0] is '$' or
            vAttr.enumerable is false or
            value is undefined or
            value is vDefaultValue)
        value = vDefaultValue if value is undefined
        v = k unless aSerialized
        aObject[v] = value
      if aNameRequired
        k = if aSerialized then vAttributes.names.name else 'name'
        aObject[k] = @name
    else
      extend aObject, @, (key, value)->
        result = not aObject.hasOwnProperty(key) and not (key in aExclude)
        if aSerialized
          result = result and key[0] isnt '$' and value isnt undefined
        result
      aObject.name = @name if aNameRequired
    aObject
  _validate: (aValue, aOptions)->true
  error: (aMessage, aOptions)->
    name = (aOptions && (aOptions[NAME] || aOptions.name)) || String(@)
    @errors.push name: name, message: aMessage
    return
  isRequired: (aValue, aOptions = @)->
    vRequired = aOptions[REQUIRED]
    result = not vRequired or (vRequired is true and aValue?)
  validateRequired: (aValue, aOptions)->
    result = @isRequired aValue, aOptions
    @error 'is required', aOptions unless result
    result
  validate: (aValue, raiseError, aOptions)->
    @errors = []
    if isObject raiseError
      aOptions    = raiseError
      raiseError  = aOptions.raiseError
    aOptions = @mergeTo(aOptions)
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
    for k,v of @mergeTo()
      return false unless deepEqual aOptions[k], v
    return true

  createValue: (aValue, aOptions)->
    if aOptions and not @isSame(aOptions)
      aOptions = @mergeTo(aOptions)
      # TODO: seperate the cache-able ability
      if isFunction Type.getCacheItem
        # this Type Factory is cache-able.
        aOptions.cached = true unless aOptions.cached?
        vType = Factory.getCacheItem @Class, aOptions
      else
        vType = @createType aOptions
    else
      vType = @
    createObject vType.ValueType, aValue, vType, aOptions
  create: @::createValue
  createType: (aOptions)->
    delete aOptions.value if aOptions
    result = createObject @Class, aOptions
    result
  cloneType: (aOptions)->
    aOptions = @mergeTo(aOptions, null, true)
    aOptions.name = @name unless aOptions.name
    @createType aOptions
  clone: @::cloneType
  # Get(create) a global Type class or create new Value from the json string.
  # it will create a new type object if options is not the original type
  # options.
  @fromJson: (aString)->
    #aString = JSON.parse aString
    Type.from JSON.parse(aString)
  # create a new Type instance  or create new Value from json string.
  @createFromJson: (aString)->
    Type.createFrom JSON.parse aString

  ###
  encode: (aOptions)->
    aOptions = @mergeTo(aOptions, null, true)
    aOptions.encoding.encode @toObject(aOptions)
  decode: (aEncoded, aOptions) ->
    aOptions = aOptions.encoding.decode aEncoded
    aOptions = @mergeTo(aOptions)
  ###

  # Get(create) a global Type class or create new Value from the parametric
  # type object.
  # it will create a new type object if options is not the original(default)
  # type options.
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
    '[type '+ @name+']'
  toJSON: ()-> @toObject()
  toJson: (aOptions)->
    result = @toObject(aOptions)
    result = JSON.stringify result
    result
  _toObject:(aOptions, aNameRequired = true)->
    result = @mergeTo aOptions, null, true, aNameRequired
    ###
    vEncoding = result.encoding
    if vEncoding and vEncoding.name isnt Type.DEFAULT_ENCODING.name
      result.encoding = vEncoding.name
    else
      delete result.encoding
    ###
    result
  toObject: (aOptions, aNameRequired)->
    if aOptions
      if not aOptions.typeOnly and not isUndefined aOptions.value
        value = aOptions.value
      delete aOptions.typeOnly
    result = @_toObject(aOptions, aNameRequired)
    result.value = value unless isUndefined value
    result
