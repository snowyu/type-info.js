inherits        = require 'inherits-ex/lib/inherits'
Attributes      = require './type'

module.exports = class ObjectAttributes
  inherits ObjectAttributes, Attributes

  @attrs: attrs =
    attributes:
      type: 'Object'
      assign: (dest, src, value, key)->
        if dest.defineAttributes
          dest.defineAttributes(value)
          true
        else
          false
    strict:
      type: 'Boolean'

  _initialize: (aOptions)->
    super(aOptions)
    @merge(attrs)
    return
