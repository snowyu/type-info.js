factory   = require("custom-factory")
isObject  = require("util-ex/lib/is/type/object")

getProtoChain = (ctor)->
  result = while ctor and ctor isnt Type
    name = ctor::name
    ctor = ctor.super_
    name

module.exports = class Type
  factory Type

  @ROOT_NAME: 'type'
  constructor: (aTypeName, aOptions)-> return super
  initialize: (aOptions)->
    @encoding = aOptions.encoding if aOptions and aOptions.encoding
  path: -> 
    result = getProtoChain(@Class)
    result.push Type.ROOT_NAME
    result.reverse()
    result
  encode: (aValue, aCheckValidity, aOptions)->
    throw new TypeError(aValue + ' is not a valid ' + @name) if aCheckValidity isnt false and not @validate(aValue)
    aValue = @encoding.encode aValue if @encoding
    aValue = @_encode aValue if @_encode
    aValue
  decode: (aString, aCheckValidity, aOptions)->
    aString = @encoding.decode aString if @encoding
    aString = @_decode aString, aCheckValidity if @_decode
    aString
  validate: (aValue)->true
  # Get a Type class from the json string.
  @fromJson: (aString)->
    Type JSON.parse aString
  toString: ->
    result = JSON.stringify @
    result.name = @name
    result.fullName = @path()
    result

