extend    = require 'util-ex/lib/extend'
isFloat   = require 'util-ex/lib/is/string/float'
isInt     = require 'util-ex/lib/is/string/int'
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'
isBoolean = require 'util-ex/lib/is/type/boolean'

module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases

class BooleanType
  register BooleanType
  aliases BooleanType, 'boolean', 'bool'

  strBool: [
    ['false', 'no']
    ['true', 'yes']
  ]
  _initialize: (aOptions)->
  _assign: (aOptions)->
  _encodeValue: (aValue)->
    aValue = String(aValue)
  _decodeValue: (aString)->
    if isString(aString) and aString.length
      aString = aString.toLowerCase()
      if aString in @strBool[0]
        false
      else if aString in @strBool[1]
        true
      else
        null
    else if isNumber aString
      Boolean(aString)
    else
      aString
  _validate: (aValue, aOptions)->
    aValue = @_decodeValue(aValue)# if isString aValue
    result = isBoolean aValue
