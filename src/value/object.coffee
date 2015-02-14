inherits    = require 'inherits-ex/lib/inherits'
extend      = require 'util-ex/lib/extend'
Value       = require './'

module.exports = class ObjectValue
  inherits ObjectValue, Value
  _assign:(aValue)->
    extend @, aValue, (k)-> k[0] isnt '$'
    return
  toString: -> @$type.toString()
  valueOf: -> @

