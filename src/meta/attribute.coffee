module.exports =
  name:
    name: 'name'
    required: true
    type: 'String'
  parent:
    name: 'parent'
    type: 'Type'
  type:
    name: 'type'
    required: true
    type: 'Type'
  required:
    name: 'required'
    type: 'Boolean'
  configurable:
    type: 'Boolean'
  enumerable:
    type: 'Boolean'
  writable:
    type: 'Boolean'
    value: true
  value: #default value
    type: undefined #Any
  get:
    type: 'Function'
  set:
    type: 'Function'
