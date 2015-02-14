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


## todo

* Cache the Virtual Types
  * search via name:
    * named the virtual type first
    * hashed to make name the virtual type if no name given


## Usage

### Develope a new Type:

These methods should be overrided:

* `_initialize(aOptions)`: initialize the options to the type object.
* `_assign(options)`: assign an options of type to itself.
* `_encode(aValue, aOptions)`: convert a value to string.
* `_decode(aString, aOptions)`: convert a string to a value. return undefined if decode failed.
* `_validate(aValue, aOptions)`: validate a value whether is valid.
* `_isEncoded(aValue)`: check the value whether is encoded.
* `ValueType` property: defaults to `Value` Class unless override it.

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
      throw TypeError('max should be equal or greater than min') if @min? and @max? and @max < @min
    return
  _encode: (aValue, aOptions)->
    aValue = String(aValue)
  _decode: (aString, aOptions)->
    if isInt aString
      aString = parseInt(aString)
    else if isFloat aString
      aString = parseFloat(aString)
    else
      aString = undefined
    aString
  _isEncoded: (aValue)->isString(aValue)
  _validate: (aValue, aOptions)->
    result = isNumber aValue
    if result
      if aOptions
        vMin = aOptions.min
        vMax = aOptions.max
        if vMin?
          result = aValue >= vMin
          if not result
            @error "should be equal or greater than minimum value: " + vMin
        if result and vMax?
          result = aValue <= vMax
          if not result
            @error "should be equal or less than maximum value: " + vMax
    result
```
### User

```coffee
Type  = require 'type-info'
Value = Type.Value

# get number type info object(Virtual Type):
# you can treat it as a global temporary type object.
number = Type 'Number', min:1, max:6

assert.equal number, Type('Number')

# get Number Type Class(Primitive Type):
NumberType = Type.registeredClass 'Number'

# create a number value:
n = Value(2)
# n = Value(2, number)
# n = number.create(2)
# n = number.createValue(2)

assert.ok    n.isValid()
assert.equal n+2, 4
assert.throw number.validate.bind(number, 13)

n.assign 5 # n = 5
assert.equal n+2, 7

# assign a new type options to the number type:
number.assign min:3, max:10
# or number.min = 3, number.max = 10

```

## API


### Type = require('type-info')

#### constructor(typeName, options)

get a global type instance object.

#### Type.create(typeName, options)

create a new Type instance object.

## License

MIT
