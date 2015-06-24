extend          = require 'util-ex/lib/_extend'
inherits        = require 'inherits-ex/lib/inherits'
defineProperty  = require 'util-ex/lib/defineProperty'
Attributes      = require './type'

getObjectKeys   = Object.keys

module.exports = class FunctionAttributes
  inherits FunctionAttributes, Attributes

  @attrs: attrs =
    scope:
      type: 'Object'
    $globalScope:
      type: 'Object'

  _initialize: (aOptions)->
    super(aOptions)
    @concat(attrs)
    return
