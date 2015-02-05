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

  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
      throw new TypeError('max should be equal or greater than min') if @min? and @max? and @max < @min
    return
  _encode: (aValue)->
    aValue = String(aValue)
  _decode: (aString, checkValidity)->
    if isInt aString
      aString = parseInt(aString)
    else if isFloat aString
      aString = parseFloat(aString)
    else if checkValidity isnt false
      throw new TypeError('string "'+aString+ '" is not a valid number')
    aString
  validate: (aValue)->
    aValue = @decode(aValue, false) if isString aValue
    result = isNumber aValue
    result = aValue >= @min if @min
    result = aValue <= @max if result and @max
    result
