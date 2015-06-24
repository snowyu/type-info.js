isString        = require 'util-ex/lib/is/type/string'
isArray         = require 'util-ex/lib/is/type/array'
isFunction      = require 'util-ex/lib/is/type/function'
defineProperty  = require 'util-ex/lib/defineProperty'
getObjectKeys   = Object.keys

###
  Usage 1:
  Attributes = require 'type-info/lib/attribute'
  $attributes: Attributes
    required:
      name: 'required'
      type: 'Boolean'
###
module.exports = class AbstractTypeAttributes
  merge: (attrs)->
    for k,v of attrs
      @[k] = v
    return
  _initialize: (aOptions)-> @merge(aOptions)
  initialize: (aOptions)->
    @_initialize(aOptions)
    @names = @getNames()
    return
  constructor: (aOptions)->
    if not (this instanceof AbstractTypeAttributes)
      return new AbstractTypeAttributes aOptions
    defineProperty @, 'names', {}
    @initialize(aOptions)

  initializeTo: (dest)->
    for k,v of @names
      continue if k is 'name'
      value = @[k].value
      dest[v] = value unless value is undefined
  assignTo: (src, dest, aExclude, aSerialized)->
    vNames = @names
    if isString aExclude
      aExclude = [aExclude]
    else if not isArray aExclude
      aExclude = []
    for k, v of vNames
      continue if v in aExclude
      continue if aSerialized and (k[0] is '$')
      vAttr = @[k]
      if k is 'name'
        vName = src[v] || src.name
        dest.name = vName if vName and vName isnt dest.name
      else if !aSerialized or (src[v]? and src[v] isnt vAttr.value)
        if aSerialized or !isFunction(vAttr.assign) or !vAttr.assign(dest, src, v)
          dest[v] = src[v]
    return dest
  isOriginal: (aObject)->
    result = true
    for k,v of @names
      continue if k is 'name'
      unless aObject[v] is @[k].value
        result = false
        break
    result
  getNames: ->
    result = {}
    for k in getObjectKeys @
      v = @[k]
      result[k] = v.name || k
    result
