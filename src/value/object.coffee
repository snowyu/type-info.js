inherits    = require 'inherits-ex/lib/inherits'
extend      = require 'util-ex/lib/extend'
Value       = require './'

getOwnPropertyNames = Object.getOwnPropertyNames

module.exports = class ObjectValue
  inherits ObjectValue, Value
  _assign:(aValue)->
    extend @, aValue, (k)-> k[0] isnt '$'
    return
  toString: -> @$type.toString()
  valueOf: -> @
  _toObject: ->
    result = {}
    vMeta = @$type.attributes
    for vName in getOwnPropertyNames @
      continue if vName[0] is '$'
      if vMeta
        vType = vMeta[vName]
        result[vName]= if vType then vType.toObject vName else @[vName]
    result
