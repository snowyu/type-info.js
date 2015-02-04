extend = require './extend'
module.exports = Type = require './type-info'


register  = Type.register
aliases   = Type.aliases
isNumber  = (v)->'number' is typeof v
isString  = (v)->'string' is typeof v

class String
  register String
  aliases String, 'string', 'str'

  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
    return
  encode: (aValue)->
    aValue = String(aValue)
    return super(aValue)
  validate: (aValue)->
    result = isString(aValue)
    return result unless result
    result = aValue.length >= @min if @min
    result = aValue.length <= @max if result and @max
    result
