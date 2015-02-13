extend    = require 'util-ex/lib/extend'
isFloat   = require 'util-ex/lib/is/string/float'
isInt     = require 'util-ex/lib/is/string/int'
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases

class NumberType
  register NumberType
  aliases NumberType, 'number'

  _initialize: (aOptions)->
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
      throw new TypeError('max should be equal or greater than min') if @min? and @max? and @max < @min
    return
  _encode: (aValue, aOptions)->
    aValue = String(aValue)
  _decode: (aString, aOptions)->
    if isInt aString
      aString = parseInt(aString)
    else if isFloat aString
      aString = parseFloat(aString)
    else
      aString = undefined
    aString
  _isEncoded: (aValue)->isString(aValue)
  _validate: (aValue, aOptions)->
    result = isNumber aValue
    if result
      if aOptions
        vMin = aOptions.min
        vMax = aOptions.max
        if vMin?
          result = aValue >= vMin
          if not result
            @error "should be equal or greater than minimum value: " + vMin
        if result and vMax?
          result = aValue <= vMax
          if not result
            @error "should be equal or less than maximum value: " + vMax
    result
