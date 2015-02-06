## type-info [![npm](https://img.shields.io/npm/v/type-info.svg)](https://npmjs.org/package/type-info)

[![Build Status](https://img.shields.io/travis/snowyu/type-info.js/master.svg)](http://travis-ci.org/snowyu/type-info.js) 
[![downloads](https://img.shields.io/npm/dm/type-info.svg)](https://npmjs.org/package/type-info) 
[![license](https://img.shields.io/npm/l/type-info.svg)](https://npmjs.org/package/type-info) 

The mini Run-time Type Infomation.

all typed value could be encode to a string. The encoded string could be decode to a value.


## Concepts

* Primitive Types
  * All registered types are primitive types.
* Virtual Types
  * It's a object of a primitive type.
  * It can not be registered.
  * It could be unlimited number of virtual types.

## Usage

### Develope a new Type:

These methods should be overrided:

* `_encode(aValue, aOptions)`: convert a value to string.
* `_decode(aString, aOptions)`: convert a string to a value. return undefined if decode failed.
* `_initialize(aOptions)`: initialize the options to the type object.
* `_validate(aValue, aOptions)`: validate a value whether is valid.
* `_isEncoded(aValue)`: check the value whether is encoded.

```coffee

extend    = require 'util-ex/lib/extend'
isFloat   = require 'util-ex/lib/is/string/float'
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

module.exports = Type = require 'type-info'


register  = Type.register
aliases   = Type.aliases

class NumberType
  register NumberType
  aliases NumberType, 'number'

  _initialize: (aOptions)->
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
    return
  _encode: (aValue, aOptions)->
    aValue = String(aValue)
  _decode: (aString, aOptions)->
    if isFloat aString
      aString = parseFloat(aString)
    else
      aString = undefined
    aString
  _isEncoded: (aValue) -> isString aValue
  _validate: (aValue, aOptions)->
    result = isNumber aValue
    if result
      if aOptions
        vMin = aOptions.min
        vMax = aOptions.max
        result = aValue >= vMin if vMin?
        result = aValue <= vMax if result and vMax?
    result

```
### User

```coffee
Type = require 'type-info'

# get number type info object(Virtual Type):
# you can treat it as a gobal temporary type object.
numberType = Type 'Number', min:1, max:6

assert.equal numberType, Type('Number')

# get Number Type Class(Primitive Type):

NumberType = Type.registeredClass 'Number'

# create a number value:

n = numberType.create(2)
# or n = numberType.createValue(2)

assert.ok    n.isValid()
assert.equal n+2, 4
assert.throw numberType.validate.bind(numberType, 13)

n.assign 5
assert.equal n+2, 7

# re-initialize the numberType:
numberType.initialize min:3, max:10
# or numberType.min = 3, numberType.max = 10

```

## API

## License

MIT



