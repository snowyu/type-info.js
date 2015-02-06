## type-info [![npm](https://img.shields.io/npm/v/type-info.svg)](https://npmjs.org/package/type-info)

[![Build Status](https://img.shields.io/travis/snowyu/type-info.js/master.svg)](http://travis-ci.org/snowyu/type-info.js) 
[![downloads](https://img.shields.io/npm/dm/type-info.svg)](https://npmjs.org/package/type-info) 
[![license](https://img.shields.io/npm/l/type-info.svg)](https://npmjs.org/package/type-info) 

The mini Run-time Type Infomation.

all typed value could be encode to string. The encoded string could be decode to value.

## Usage

### Develope a new Type:

```coffee

extend    = require 'util-ex/lib/extend'
isFloat   = require 'util-ex/lib/is/string/float'
isInt     = require 'util-ex/lib/is/string/int'
isNumber  = require 'util-ex/lib/is/type/number'
isString  = require 'util-ex/lib/is/type/string'

module.exports = Type = require 'type-info'


register  = Type.register
aliases   = Type.aliases

class NumberType
  register NumberType
  aliases NumberType, 'number'

  initialize: (aOptions)->
    super(aOptions)
    if aOptions
      extend @, aOptions, (k,v)->k in ['min', 'max'] and isNumber v
    return
  _encode: (aValue, aOptions)->
    aValue = String(aValue)
  _decode: (aString, aOptions)->
    if isFloat aString
      aString = parseFloat(aString)
    else if aOptions and aOptions.checkValidity isnt false
      throw new TypeError('string "'+aString+ '" is not a valid number')
    aString
  _validate: (aValue)->
    aValue = @decodeString(aValue) if isString aValue
    result = isNumber aValue
    result = aValue >= @min if @min
    result = aValue <= @max if result and @max
    result

```
### User

```coffee
Type = require 'type-info'

# get number type info object:

numberType = Type 'Number', min:1, max:6

assert.equal numberType, Type('Number')

# get Number Type Class:

NumberType = Type.registeredClass 'Number'

# create a number value:

n = numberType.create(2)
# or n = numberType.createValue(2)
# or n = new NumberType min:1, max: 6, value:2

assert.ok    n.isValid()
assert.equal n+2, 4
assert.throw numberType.validate.bind(numberType, 13)

n.assign 5
assert.equal n+2, 7

```

## API

## License

MIT



