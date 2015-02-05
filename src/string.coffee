extend = require 'util-ex/lib/extend'
module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

class StringType
  register StringType
  aliases StringType, 'string', 'str'

  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
      throw new TypeError('max should be equal or greater than min') if @min? and @max? and @max < @min
    return
  validate: (aValue)->
    result = isString(aValue)
    return result unless result
    result = aValue.length >= @min if @min
    result = aValue.length <= @max if result and @max
    result
