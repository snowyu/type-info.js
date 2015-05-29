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


## Cache the Virtual Types

Install cache-factory first.

  npm install cache-factory


```coffee
Type = require 'type-info'
cacheable = require 'cache-factory'

# apply the cache-able ability to Type
cacheable Type

# now cache the virtual types with name.
passwordType = Type 'String', min:6, cached: {name: 'Password'}
# or no named it:
passwordType1 = Type 'String', min:6, cached: true

p2 = Type 'String', min:6, cached: true
p3 = Type 'String', min:6, cached: {name: 'Password'}
assert p2 is passwordType1
assert p3 is passwordType
assert passwordType isnt passwordType1
```

more detail see [cache-factory](https://github.com/snowyu/cache-factory)

## TODO

* ObjectType should use ValueType.toObject to transform value.

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

  _assign: (aOptions)->
    if aOptions
      extend @, aOptions, (k,v)=>
        result = k in ['min', 'max']
        if result
          result = isNumber v
          delete @[k] unless result
        result
      if @min? and @max? and @max < @min
        throw TypeError('max should be equal or greater than min')
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

* Type(aTypeName, aOptions)
  * get the type info object from glabal cache.
* Type.createType(aObject)
  * create a new type info object instance.
  * the aObject.name should be exists as the type name.


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

the type info class.

#### constructor(typeName, options)

get a global type info instance object.

__arguments__

* `typeName` *(string)*: the type name.
* `options` *(object)*: optional type options to apply. different types have different options.
  * `parent` *(TypeInfo)*: it should be an attribute if the `parent` exists
  * `required` *(boolean)*: this type is required.
  * `encoding` *(string or object)*:
    * 'string': the encoding name. it should install the [buffer-codec](https://github.com/snwyu/node-buffer-codec)
    * 'object':
      * `name` *(string)*: the encoding name.
      * `encode` *(function)*: the encode function.
      * `decode` *(function)*: the decode function.

__return__

* *(object)*: the type object instance from global cache.

#### Type.create(typeName, options)

This class method is used to create a new Type instance object.

__arguments__

* `typeName` *(string)*: the type name.
* `options` *(object)*: optional type options. different types have different options.

__return__

* *(object)*: the created type object instance.

#### cloneType()

clone the type object.

* alias: clone

__return__

* *(object)*: the created type object instance with same type info.

#### createType(options)

create a new the type object of this type with the type options.

__arguments__

* `options` *(object)*: optional type options. different types have different options.
  * it is the same as `cloneType()` if no options

__return__

* *(object)*: the created type object instance with the type info options.

#### createFromJson(json)

create a new the type object of this type from a json string.

__arguments__

* `json` *(string)*: the json string with type info.

__return__

* *(object)*:
  * the created type object instance with the type info if no value in it.
  * the created value object instance if value in it.

#### createValue(value, options)

* alias: create

create a value from the type.

__arguments__

* `value` *(Type)*: the value of this type to create
* `options` *(object)*: optional type options
  * the new virtual type of the value will be created if exists

__return__

* *(object)*: the created value object instance.

#### toObject(options)

convert the type info to an object. It could be streamable your type.

__arguments__

* `options` *(object)*: optional options
  * `value` *(Type)*: optional value, when value exists, the following options used:
    * `isEncoded` *(boolean)*:  whether encode the value. defaults to false
    * `typeOnly` *(boolean)*: just type info if true. defaults to false.

__return__

* *(object)*: the created object with type info.

#### toJson(options)

convert the type info to a json string. It could be streamable your type.

__arguments__

* `options` *(object)*: optional options
  * `value` *(Type)*: optional value, when value exists, the following options used:
    * `isEncoded` *(boolean)*:  whether encode the value. defaults to false
    * `typeOnly` *(boolean)*: just type info if true. defaults to false.

__return__

* *(string)*: the json string with type info.

#### validate(value, raiseError, options)

validate a specified value whether is valid.

__arguments__

* `value` *(Type)*: the value to validate
* `raiseError` *(boolean)*:  whether throw error if validate failed. defaults to true.
* `options` *(object)*: optional type options to override. defaults to this type options.

__return__

* *(boolean)*: whether is valid if no raise error.


### Value = require('type-info').Value

the value class.

#### constructor(value[[, type], options])

__arguments__

* `value` *(Type)*: the value to be created.
  * it will guess the type if no type object.
* `type` *(Object)*: the optional type object.
* `options` *(object)*: optional type options.
  * checkValidity *(boolean)*: whether check the value is valid. defaults to true.

__return__

* *(object)*: the created value object instance.

#### property $type

point to a type object. It can not be enumerable.

#### clone()

clone the value object.

__return__

* *(object)*: the created new value object instance with same as original info.

#### create(value, options)

create a new the value object.

__arguments__

* `value` *(Type)*: the value to be created. MUST BE the same type.
* `options` *(object)*: optional type options.
  * checkValidity *(boolean)*: whether check the value is valid. defaults to true.

__return__

* *(object)*: the created value object instance.

#### assign(value, options)

assign a value to itself.

__arguments__

* `value` *(Type)*: the value to be assigned. MUST BE the same type.
* `options` *(object)*: optional type options.
  * checkValidity *(boolean)*: whether check the value is valid. defaults to true.
  * isEncoded *(boolean)*: whether the value is encoded. defaults to false.

__return__

* *(object)*: `this` object.

#### isValid()

validate the value whether is valid.

__return__

* *(boolean)*: whether the value is valid.

#### toObject(options)

convert the value to an object. include type info. It could be streamable your value.

__arguments__

* `options` *(object)*: optional options
  * `isEncoded` *(boolean)*:  whether encode the value. defaults to false
  * `typeOnly` *(boolean)*: just type info if true. defaults to false.

__return__

* *(object)*: the created object with value and type info.

```coffee
Type  = require 'type-info'
Value = Type.Value

val = Value(3, min: 1, max: 3)

console.log val.toObject()
{
  min:1
  max:3
  name: 'Number'
  fullName: 'type/Number'
  value:3
}

```

#### toJson(options)

convert the value to a json string. include type info. It could be streamable your value.

__arguments__

* `options` *(object)*: optional options
  * `isEncoded` *(boolean)*:  whether encode the value. defaults to false
  * `typeOnly` *(boolean)*: just type info if true. defaults to false.

__return__

* *(string)*: the json string with type info and value.

## License

MIT
