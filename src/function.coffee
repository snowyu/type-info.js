isNumber        = require 'util-ex/lib/is/type/number'
isString        = require 'util-ex/lib/is/type/string'
isFunction      = require 'util-ex/lib/is/type/function'
isFunctionStr   = require 'util-ex/lib/is/string/function'
isObject        = require 'util-ex/lib/is/type/object'
defineProperty  = require 'util-ex/lib/defineProperty'
extend          = require 'util-ex/lib/extend'
createFunc      = require 'util-ex/lib/_create-function'
FunctionValue   = require './value/function'
module.exports  = Type = require './type-info'

register    = Type.register
aliases     = Type.aliases

getObjKey = (obj, value)->
  for k,v of obj
    return k if v is value

class FunctionType
  register FunctionType
  aliases FunctionType, 'function', 'func', 'method', 'Method'

  _assign: (aOptions)->
    if aOptions
      #TODO: I have no idea howto save it to JSON.
      # use the global scope to resolve above.
      vGlobalScope = aOptions.globalScope or aOptions.$globalScope
      @$globalScope = extend {}, vGlobalScope if isObject vGlobalScope
      vGlobalScope = @$globalScope

      vScope = aOptions.scope
      if vGlobalScope
        for k,v of vScope
          if isString(v) and vGlobalScope[v]?
            vScope[k] = vGlobalScope[v]
      @scope = extend {}, vScope
    return
  _encodeValue: (aValue)->String(aValue)
  _decodeValue: (aValue)->createFunc aValue, @scope
  _toObject: (aOptions)->
    result = super aOptions
    vScope = result.scope
    vGlobal = @$globalScope
    if isObject(vScope) and isObject vGlobal
      for k,v of vScope
        vName = getObjKey(vGlobal, v)
        vScope[k] = vName if vName
    result
  _validate: (aValue, aOptions)->
    isFunction(aValue) or isFunctionStr(aValue)
