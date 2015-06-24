inherits        = require 'inherits-ex/lib/inherits'
Attributes      = require './type'

module.exports = class FunctionAttributes

  inherits FunctionAttributes, Attributes

  @attrs: attrs =
    scope:
      type: 'Object'
    $globalScope:
      type: 'Object'

  _initialize: (aOptions)->
    super(aOptions)
    @merge(attrs)
    return
