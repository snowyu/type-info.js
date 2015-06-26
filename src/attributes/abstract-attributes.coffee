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
    for name, attr of attrs
      attr = type:attr if isString attr
      vAttr = @[name]
      if vAttr is undefined
        @[name] = attr
      else
        vAttr[k] = v for k, v of attr
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
      vAttr = @[k]
      value = vAttr.value
      if vAttr.enumerable is false and not dest.hasOwnProperty(v)
        defineProperty dest, v, value
      dest[v] = value unless value is undefined
  assignTo: (src, dest, aExclude)->
    vNames = @names
    if isString aExclude
      aExclude = [aExclude]
    else if not isArray aExclude
      aExclude = []
    for k, v of vNames
      continue if v in aExclude
      #continue if aSerialized and (k[0] is '$')
      vAttr = @[k]
      vValue = src[v] || src[k]
      if k is 'name'
        dest.name = vValue if vValue and vValue isnt dest.name
      else if vValue isnt undefined
        if @Type and vAttr.type? and vValue? and vValue isnt vAttr.value
          vType = @Type vAttr.type
          if vType and not vType.isValid vValue
            k = "assign attribute '#{v}' error"
            if vType.errors.length
              k += ": the value #{vValue}"
              for v in vType.errors
                k += "\n #{v.name}: #{v.message}"
              dest.errors = vType.errors if dest.errors
            throw new TypeError k
        # aSerialized and src[v] isnt vAttr.value:
        #  the parametric type object(options) do not need the defaults value.
        # but the mergeOptions need all attriubtes!!
        if !isFunction(vAttr.assign) or !vAttr.assign(dest, src, vValue, v)
          dest[v] = vValue
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
