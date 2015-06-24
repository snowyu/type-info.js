createObject    = require 'inherits-ex/lib/createObject'
extend          = require 'util-ex/lib/extend'
isFloat         = require 'util-ex/lib/is/string/float'
isInt           = require 'util-ex/lib/is/string/int'
isNumber        = require 'util-ex/lib/is/type/number'
isString        = require 'util-ex/lib/is/type/string'
attributes      = createObject require './attributes/number'
module.exports  = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases

class NumberType
  register NumberType
  aliases NumberType, 'number'

  $attributes: attributes

  _encodeValue: (aValue)->
    aValue = String(aValue)
  _decodeValue: (aString)->
    if isInt aString
      aString = parseInt(aString)
    else if isFloat aString
      aString = parseFloat(aString)
    else
      aString = undefined
    aString
  _validate: (aValue, aOptions)->
    aValue = @_decodeValue(aValue) if isString aValue
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
