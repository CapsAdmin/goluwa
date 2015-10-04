---
tagline: objects with virtual properties
---

## `require'winapi.vobject'`

This module defines the `VObject` class which implements virtual properties.

Virtual properties means that:

  * `x = foo.bar` calls `foo:get_bar() -> x`, and
  * `foo.bar = x` calls `foo:set_bar(x)`.

If there's a `set_bar` but no `get_bar` defined, setting `foo.bar = x`
sets `foo.__state.bar = x` and later `x = foo.bar` returns the value
of `foo._state.bar`. These are called "stored properties".

If there's a `get_bar` but no `set_bar`, doing `foo.bar = x` raises an error.
These are called "read-only properties".

## VObject

### Hierarchy

* [Object][winapi.object]
	* VObject

### Methods

-------------------------------------------- --------------------------------------------
__subclassing__
`__gen_vproperties(names, getter, setter)`	generate virtual properties in bulk
__introspection__
`__vproperties() -> iter() -> prop, info`		iterate all virtual properties
-------------------------------------------- --------------------------------------------

### Generating properties in bulk

Calling `Foo:__gen_vproperties({foo = true, bar = true}, getter, setter)`
generates getters and setters for `foo` and `bar` properties
based on `getter` and `setter` such that:

	get_foo(self)           calls getter(self, 'foo')
	get_bar(self)           calls getter(self, 'bar')
	set_foo(self, val)      calls setter(self, 'foo', val)
	set_bar(self, val)      calls setter(self, 'bar', val)
