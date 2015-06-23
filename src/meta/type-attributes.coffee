isString        = require 'util-ex/lib/is/type/string'
isArray         = require 'util-ex/lib/is/type/array'
isFunction      = require 'util-ex/lib/is/type/function'
defineProperty  = require 'util-ex/lib/defineProperty'
getObjectKeys   = Object.keys

module.exports = class TypeAttributes
  @attrs: attrs =
    name:
      name: 'name'
      required: true
      type: 'String'
    required:
      name: 'required'
      type: 'Boolean'

  _initialize: (attrs)->
    for k,v of attrs
      @[k] = v
    return
  initialize: (aOptions)->
    @_initialize(attrs)
    return
  constructor: (aOptions)->
    if not (this instanceof TypeAttributes)
      return new TypeAttributes(aOptions)
    defineProperty @, 'names', {}
    @initialize(aOptions)
    @names = @getNames()

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
  getNames: ->
    result = {}
    for k in getObjectKeys @
      v = @[k]
      result[k] = v.name || k
    result
