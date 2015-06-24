inherits        = require 'inherits-ex/lib/inherits'
Attributes      = require './type'

module.exports = class NumberAttributes
  inherits NumberAttributes, Attributes

  @attrs: attrs =
    min:
      name: 'min'
      type: 'Number'
    max:
      name: 'max'
      type: 'Number'

  _initialize: (aOptions)->
    super(aOptions)
    @merge(attrs)
    return
  assignTo: (src, dest, aExclude, aSerialized)->
    result = super
    if dest.min? and dest.max? and dest.max < dest.min
      throw new TypeError('max should be equal or greater than min')
    result
    
