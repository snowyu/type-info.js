## type-info [![npm][npm-svg]][npm]

[![Build Status][travis-svg]][travis]
[![Code Climate][codeclimate-svg]][codeclimate]
[![Test Coverage][codeclimate-test-svg]][codeclimate-test]
[![downloads][npm-download-svg]][npm]
[![license][npm-license-svg]][npm]

[npm]: https://npmjs.org/package/type-info
[npm-svg]: https://img.shields.io/npm/v/type-info.svg
[npm-download-svg]: https://img.shields.io/npm/dm/type-info.svg
[npm-license-svg]: https://img.shields.io/npm/l/type-info.svg
[travis-svg]: https://img.shields.io/travis/snowyu/type-info.js/master.svg
[travis]: http://travis-ci.org/snowyu/type-info.js
[codeclimate-svg]: https://codeclimate.com/github/snowyu/type-info.js/badges/gpa.svg
[codeclimate]: https://codeclimate.com/github/snowyu/type-info.js
[codeclimate-test-svg]: https://codeclimate.com/github/snowyu/type-info.js/badges/coverage.svg
[codeclimate-test]: https://codeclimate.com/github/snowyu/type-info.js/coverage

This run-time type information can be streamable via using toObject() method
to generate the parametric type object, or using JSON.stringify directly.
It can also be used to validate the value of the type.

Creating the new type is very simple and easy through this framework.
Just we need to understand the basic concepts of the following.

## Concepts

* Primitive Types
  * All registered types are primitive types.
* Virtual Types
  * It's a object of a primitive type.
  * It can not be registered.
  * It could be unlimited number of virtual types.
* Type Attributes: first determine(define) these attributes of the type, before creating a new type.
  It's used to constrain the Type.
  All types have the `name` and `required` attributes.
  * `name` *(string)*: the type name.
    * required   = true:  it must be required.
    * enumerable = false: it can not be enumerable.
  * `required` *(boolean)*: the attribute whether is required(must be exists, not optional).
* Value: the value with corresponding to the type information.


## Quick starts

0. npm install type-info

    ```js
    var Type = require('type-info')
    ```
1. get the type

    ```js
    var TNumber = Type('Number')
    ```
2. create the virtual type

    ```js
    var TPositiveNumber =
      Type('Number', {min:0, cached: 'PositiveNumber'})
    ```
3. validate a value

    ```js
    assert.notOk(TPositiveNumber.isValid(-1))
    assert.ok(TPositiveNumber.isValid(1))
    ```
3. create the value

    ```js
    var n = TPositiveNumber.create(123)
    assert.ok(n.isValid())
    assert.equal(Number(n) + 3, 126)
    var bool = Type('Boolean').create(true)
    assert.equal(Number(bool), 1)
    ```

### Known Types:

* [String Type][string-type]
  * `min`: the minimum string length
  * `max`: the maximum string length
* [Number Type][number-type]
  * `min`: the minimum number
  * `max`: the maximum number
  * Integer Type
  * Float Type
* [Date Type][date-type]
  * `min`: the minimum date to limit
  * `max`: the maximum date to limit
* [Boolean Type][boolean-type]
  * It is a special number type. you can cast to number.
  * 0 means false, 1 means true.
  * `boolNames`: the boolean value string names.
    * defaults to {true:['true', 'yes'], false: ['false,'no']}
    * enumerable: false
* [Function Type][function-type]
  * `globalScope`: the set of variables this function can access to.
  * `global`: the set of local functions this function can access to.
    It can not be exported.
* [Array Type][array-type]
  * `min`: the minimum array length to limit
  * `max`: the maximum array length to limit
  * `of`:  the each elment's type of the array to limit.
* [Object Type][object-type]
  * `attributes`: the object attribute list.
    * It's used to constrain the value of the object.
* [Class Type][class-type]: a special object type. the value of class is the constructor of this class.
  * TODO: not fined.

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

## Changes

### v1.0.0

* use the [abstract-type][abstract-type] package.
* The pacakge just collects types only.

### v0.8.0

+ [Type] $attributes to hold the type's meta attributes.
  + the type's meta attributes definition in the src/attributes directory.
+ [ObjectType] add AttributeType to defineAttribute
* [ObjectType] use the primitive type of attribute if possible.
+ [Type] isSame method to compare parametric object
- remove the parent attribute
- remove the encoding from type-info
  - remove `Type::encode` method
  - remove `Type::decode` method
* [Type] `Type(aTypeName, aOptions)`:
  * get the global instance if no aOptions or aOptions is same as the original default value of attributes.
  * create a new type object instance else

### v0.7.0

+ add JSON.stringify(aTypeObject) supports
+ add Type.createFrom(string, encoding) static(class) method
- remove Type::`_encode` method
- remove Type::`_decode` method
- remove Type::`_isEncoded` method
+ add Value::`_encode`, Value::`_decode` optional methods
  * make sure the value can be converted to json correctly.
+ add Value::fromJson(string)
+ add Value::createFromJson(string)
+ add Value::toString(aOptions)
+ add Value.tryGetTypeName(aValue)
* Type::mergeOptions(options, exclude, serialized) distinguish serialized and non-serialized parameters

## TODO


## Usage

See [abstract-type][abstract-type].

```coffee
Type  = require 'type-info'
Value = Type.Value

# get number type info object
# you can treat it as a global temporary type object.
num = Type 'Number'
assert.equal num, Type('Number')

# get a new number type info object(Virtual Type):
# create a virtual type object always if the options exists:
number = Type 'Number', min:1, max:6
assert.notEqual number, num

# get Number Type Class(Primitive Type):
NumberType = Type.registeredClass 'Number'

# create a number value:
n = Value(2) # try to guess the value type.
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


See [abstract-type][abstract-type].

## License

MIT


[abstract-type]: https://github.com/snowyu/abstract-type.js
[string-type]: https://github.com/snowyu/string-type.js
[number-type]: https://github.com/snowyu/number-type.js
[boolean-type]: https://github.com/snowyu/boolean-type.js
[object-type]: https://github.com/snowyu/object-type.js
[function-type]: https://github.com/snowyu/function-type.js
[class-type]: https://github.com/snowyu/class-type.js
[date-type]: https://github.com/snowyu/date-type.js
