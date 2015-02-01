factory = require("custom-factory")

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
    result = getProtoChain(@constructor)
    result.push Type.ROOT_NAME
    result.reverse()
    #result.push(@name)
    result
  encode: (aValue)->
  decode: (aString)->
  # create a TypeInfo class from the json string.
  @createFromJson: (aString)->
  toJson: ->
    result = JSON.stringify @

