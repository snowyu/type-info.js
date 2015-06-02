inherits    = require 'inherits-ex/lib/inherits'
extend      = require 'util-ex/lib/extend'
isString    = require 'util-ex/lib/is/type/string'
Value       = require './'

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys = Object.keys

module.exports = class ObjectValue
  inherits ObjectValue, Value
  _assign:(aValue)->
    #if isString aValue
    #  aValue = JSON.parse aValue
    extend @, aValue, (k)-> k[0] isnt '$'
    return
  toString: -> @$type.toString()
  valueOf: -> @
  _toObject: (aOptions)->
    aValue = @
    result = {}
    vMeta = @$type.attributes
    for vName in getObjectKeys aValue
      continue if vName[0] is '$'
      if vMeta
        vType = vMeta[vName]
        result[vName]= if vType then vType.toObject vName else @[vName]
    result
