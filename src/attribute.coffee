createObject    = require 'inherits-ex/lib/createObject'
extend          = require 'util-ex/lib/extend'
isFloat         = require 'util-ex/lib/is/string/float'
isInt           = require 'util-ex/lib/is/string/int'
isObject        = require 'util-ex/lib/is/type/object'
isNumber        = require 'util-ex/lib/is/type/number'
isString        = require 'util-ex/lib/is/type/string'
defineProperty  = require 'util-ex/lib/defineProperty'
inheritsObject  = require 'inherits-ex/lib/inheritsObject'
attributes      = createObject require './attributes/attribute'
module.exports  = Type = require './type-info'

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys       = Object.keys

register  = Type.register
aliases   = Type.aliases

metaNames = attributes.names

NAME = metaNames.name
TYPE = metaNames.type
REQUIRED = metaNames.required

class AttributeType
  register AttributeType
  aliases AttributeType, 'attribute'

  $attributes: attributes
  @defaultType: Type('string')
  _assign: (aOptions)->
    if isString aOptions
      vType = aOptions
      aOptions = {}
      vType = Type(vType, aOptions)
      throw TypeError("no such type registered:"+aOptions) unless vType
      @[TYPE] = vType
    else if aOptions instanceof AttributeType
      for k,v of aOptions
        @[k] = v if @hasOwnProperty k
    else if aOptions instanceof Type
      @[TYPE] = aOptions
    else if aOptions?
      for k,v of aOptions
        @[k] = v if @hasOwnProperty k
      vType = aOptions[TYPE]
      if vType
        if not (vType instanceof Type)
          vType = Type(vType)
          unless vType
            throw TypeError("no such type registered:"+aOptions[TYPE])
          vType = vType.clone(aOptions) unless vType.isSame(aOptions)
          @[TYPE] = vType
      else
        @[TYPE] = AttributeType.defaultType

    return
  ###
  getFullName: ->
    vName = [@[NAME]]
    vParent = @parent
    while vParent && vParent[NAME] isnt 'Object'
      vName.push vParent[NAME]
      vParent = vParent.parent
    vName.reverse()
    vName.join('.')
  ###
  #getName: -> @[NAME]
  toString: -> '[Attribute ' + @name + ']'
  _toObject: (aOptions)->
    result = super(aOptions)
    vType = @[TYPE].toObject(aOptions)
    result[TYPE] = vType[NAME]
    delete vType[NAME]
    # if it's a customize type(special options type):
    if not @[TYPE].hasOwnProperty 'name'
      for k,v of vType
        result[k] = v
    result
  _decodeValue: (aValue)->
    try result = JSON.parse aValue
    result
  _validate: (aValue, aOptions)->
    if aOptions
      vType   = aOptions[TYPE]
      if vType
        result  = vType.validate aValue, false
        if not result
          if vType.errors.length
            @errors = vType.errors
            vType.errors = []
          else
            @errors.push name: String(vType), message: "is invalid"
    result
