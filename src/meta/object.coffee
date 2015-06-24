extend          = require 'util-ex/lib/_extend'
inherits        = require 'inherits-ex/lib/inherits'
defineProperty  = require 'util-ex/lib/defineProperty'
Attributes      = require './type-attributes'

getObjectKeys   = Object.keys

module.exports = class ObjectAttributes
  inherits ObjectAttributes, Attributes

  @attrs: attrs =
    attributes:
      type: 'Object'
      assign: (dest, src, key)->
        if dest.defineAttributes
          dest.defineAttributes(src[key])
          true
        else
          false
    strict:
      type: 'Boolean'

  _initialize: (aOptions)->
    super(aOptions)
    @concat(attrs)
    return
