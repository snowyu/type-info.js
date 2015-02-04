extend    = require 'util-ex/lib/extend'
isFloat   = require 'util-ex/lib/is/string/float'
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases

class Number
  register Number
  aliases Number, 'number'

  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
    return
  _encode: (aValue)->
    aValue = String(aValue)
  _decode: (aString, checkValidity)->
    if isFloat aString
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
