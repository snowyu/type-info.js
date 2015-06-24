extend          = require 'util-ex/lib/_extend'
inherits        = require 'inherits-ex/lib/inherits'
defineProperty  = require 'util-ex/lib/defineProperty'
Attributes      = require './type'

getObjectKeys   = Object.keys

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
    @concat(attrs)
    return
  assignTo: (src, dest, aExclude, aSerialized)->
    result = super
    if dest.min? and dest.max? and dest.max < dest.min
      throw new TypeError('max should be equal or greater than min')
    result
    
