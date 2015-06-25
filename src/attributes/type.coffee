inherits        = require 'inherits-ex/lib/inherits'
Attributes      = require './abstract-type'

module.exports = class TypeAttributes

  inherits TypeAttributes, Attributes

  @attrs: attrs =
    name:
      name: 'name'
      required: true
      type: 'String'
    required:
      name: 'required'
      type: 'Boolean'

  constructor: (aOptions)->
    if not (this instanceof TypeAttributes)
      return new TypeAttributes aOptions
    return super aOptions

  _initialize: (aOptions)->
    @merge(attrs)
    super(aOptions)
    return
    