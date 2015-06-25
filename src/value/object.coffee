inherits    = require 'inherits-ex/lib/inherits'
extend      = require 'util-ex/lib/extend'
isString    = require 'util-ex/lib/is/type/string'
Attributes  = require '../attributes/object'
Value       = require './'

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys = Object.keys

STRICT = Attributes.attrs.strict.name || 'strict'

module.exports = class ObjectValue
  inherits ObjectValue, Value
  _assign:(aValue)->
    #if isString aValue
    #  aValue = JSON.parse aValue
    if @$type[STRICT]
      if aValue?
        for k, t of @$type.attributes
          continue if k[0] is '$'
          v = aValue[k]
          @[k] = v if v isnt undefined and t.isValid v
    else
      extend @, aValue, (k)-> k[0] isnt '$'
    return
  toString: -> @$type.toString()
  valueOf: -> @
  _toObject: (aOptions)->
    aValue = @
    result = {}
    vMeta = @$type.attributes
    vStrict = @$type[STRICT]
    for vName in getObjectKeys aValue
      continue if vName[0] is '$'
      if vMeta and (vType = vMeta[vName])
        result[vName] = vType.toObject vName
      else if not vStrict
        result[vName] = @[vName]
    result
