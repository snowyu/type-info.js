inherits        = require 'inherits-ex/lib/inherits'
Attributes      = require './type'

module.exports = class AttributeAttributes
  inherits AttributeAttributes, Attributes

  @attrs: attrs =
    type:
      name: 'type'
      required: true
      type: 'Type'
    configurable:
      type: 'Boolean'
    enumerable:
      type: 'Boolean'
    writable:
      type: 'Boolean'
      value: true
    value: #default value
      type: undefined #Any
    get:
      type: 'Function'
    set:
      type: 'Function'

  _initialize: (aOptions)->
    super(aOptions)
    @merge(attrs)
    return
