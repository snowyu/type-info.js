extend = require 'util-ex/lib/extend'
module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

class StringType
  register StringType
  aliases StringType, 'string', 'str'

  _assign: (aOptions)->
    if aOptions
      extend @, aOptions, (k,v)=>
        result = k in ['min', 'max']
        if result
          result = isNumber v
          delete @[k] unless result
        result
      if @min? and @max? and @max < @min
        throw new TypeError('max should be equal or greater than min')
    return
  _validate: (aValue, aOptions)->
    result = isString(aValue)
    return result unless result
    if aOptions
      vMin = aOptions.min
      vMax = aOptions.max
      if vMin?
        result = aValue.length >= vMin
        if not result
          @error "should be equal or greater than minimum length: " + vMin
      if result and vMax?
        result = aValue.length <= vMax
        if not result
          @error "should be equal or less than maximum length: " + vMax
    result
