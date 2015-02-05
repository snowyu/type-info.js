factory   = require("custom-factory")
isObject  = require("util-ex/lib/is/type/object")
extend    = require("util-ex/lib/_extend")

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
    @pathArray().join '/'
  pathArray: ->
    result = getProtoChain(@Class)
    result.push Type.ROOT_NAME
    result.reverse()
  encode: (aValue, aCheckValidity, aOptions)->
    if isObject aCheckValidity
      aOptions = aCheckValidity
      aCheckValidity = aOptions.checkValidity
    throw new TypeError(aValue + ' is not a valid ' + @name) if aCheckValidity isnt false and not @validate(aValue)
    aValue = @encoding.encode aValue, aOptions if @encoding
    aValue = @_encode aValue if @_encode
    aValue
  decode: (aString, aCheckValidity, aOptions)->
    if isObject aCheckValidity
      aOptions = aCheckValidity
      aCheckValidity = aOptions.checkValidity
    aString = @encoding.decode aString, aOptions if @encoding
    aString = @_decode aString, aCheckValidity if @_decode
    throw new TypeError(aString + ' is not a valid ' + @name) if aCheckValidity isnt false and not @validate(aString)
    aString
  validate: (aValue)->true
  # Get a Type class from the json string.
  @fromJson: (aString)->
    Type JSON.parse aString
  toString: ->
    result = extend {}, @
    result.name = @name
    result.fullName = @path()
    result = JSON.stringify result
    result

