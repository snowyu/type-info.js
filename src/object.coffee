extend          = require 'util-ex/lib/extend'
isFloat         = require 'util-ex/lib/is/string/float'
isInt           = require 'util-ex/lib/is/string/int'
isObject        = require 'util-ex/lib/is/type/object'
isNumber        = require 'util-ex/lib/is/type/number'
isString        = require 'util-ex/lib/is/type/string'
defineProperty  = require 'util-ex/lib/defineProperty'
inheritsObject  = require 'inherits-ex/lib/inheritsObject'
ObjectValue     = require './value/object'
module.exports  = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases

class ObjectType
  register ObjectType
  aliases ObjectType, 'object'

  @defaultType: Type('string')
  ValueType: ObjectValue
  defineAttribute: (aName, aOptions)->
    throw TypeError('defineAttribute has no attribute name') unless aName and aName.length
    throw TypeError('the attribute "' + aName + '" has already defined.') if @attributes[aName]?
    if isString aOptions
      vType = Type(aOptions)
      throw TypeError("no such type registered:"+aOptions) unless vType
      aOptions = null
    else if aOptions.type
      vType = Type(aOptions.type)
      throw TypeError('no such type registered:'+aOptions.type) unless vType
    else
      vType = ObjectType.defaultType
    aOptions = @mergeOptions(aOptions, ['attributes', 'name'])
    aOptions.name = aName
    aOptions.parent = vParent = @
    vType = vType.cloneType(aOptions)
    vName = [aName]
    while vParent && vParent.name isnt 'Object'
      vName.push vParent.name
      vParent = vParent.parent
    vName.reverse()
    vType.name = vName.join('.')
    @attributes[aName] = vType
  ###
    attributes = 
      attrName:
        required: true
        type: 'string'
  ###
  defineAttributes: (aAttributes)->
    for k,v of aAttributes
      continue if not k? or not v?
      @defineAttribute k, v
    return
  _initialize: (aOptions)->
    #defineProperty @, 'attributes', {}
    @attributes = {}
    return
  _assign: (aOptions)->
    @defineAttributes(aOptions.attributes) if aOptions and aOptions.attributes
    return
  _encode: (aValue, aOptions)->
    JSON.stringify(aValue)
  _decode: (aString, aOptions)->
    try result = JSON.parse aString
    result
  _isEncoded: (aValue)->isString(aValue)
  _validate: (aValue, aOptions)->
    result = isObject aValue
    if result
      if aOptions and aOptions.attributes
        for vName, vType of aOptions.attributes
          if not vType.validate aValue[vName], false
            if vType.errors.length
              @errors = @errors.concat vType.errors
            else
              @errors.push name: String(vType), message: "is invalid"
            result = false
    result
  # can wrap a common object to an ObjectValue.
  wrapValue:(aObjectValue)->
    if isObject aObjectValue
      if not (aObjectValue instanceof ObjectValue)
        inheritsObject aObjectValue, ObjectValue
      if aObjectValue.hasOwnProperty '$type'
        @$type = @
      else
        defineProperty aObjectValue, '$type', @
    aObjectValue

