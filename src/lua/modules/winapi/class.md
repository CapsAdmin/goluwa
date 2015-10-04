---
tagline: single inheritance object model
---

This module defines an user API and an implementation protocol for
implementing a single-inheritance object model.

The API is comprised of 2 functions:

  * `subclass(derived[, super]) -> derived`
  * `isinstance(object, class) -> true|false`

`subclass()` calls `super:__subclass(derived)` to perform the actual
subclassing and returns `derived`. This means that each class is free
to define how subclassing should be performed (copy all members to
the derived class aka static inheritance, assign an `__index`
metamethod aka dynamic inheritance, etc.). If the super class doesn't
define a `__subclass` method, nothing gets inherited and `derived`
is returned untouched.

`isinstance()` calls `object:__super()` recursively until it matches
the wanted class. Classes must implement `__super()` for this to work.

Note that there's no API or implementation protocol for instantiation.
The root class should define these.

The [Object][winapi.object] class implements this model using dynamic
inheritance.
