---
tagline: the root class
---

## `require'winapi.object'`

This module defines the `Object` class which is the base class of
every other class in winapi.

## Object

Object implements the single-inheritance object model specified in
[winapi.class]. This means that you can use `subclass()` to subclass
from `Object` and `isinstance()` on every instance or subclass of `Object`.

It also defines how instantiation works: calling `Foo(args...)` creates
an instance of `Foo`, calls `__init(self, args...)` on it, and returns it.

Instances:

  * inhert class fields dynamically
  * inherit instance metamethods statically
  * inherit super class fields dynamically
  * inherit super class metamethods statically

### Hierarchy

* Object

### Methods

----------------------------------------- ----------------------------------------------------------
__subclassing__
`__subclass(class) -> class`					subclassing constructor
__instantiation__
`__init(...)`										stub object constructor (implemented in concrete classes)
__introspection__
`__super() -> class`								access the super class
`__supers() -> iter() -> class`				iterate over the class hierarchy
`__allpairs() -> iter() -> k, v, class`	iterate instance and class members recursively
`__pairs() -> iter() -> k, v`					iterate the flattened map of instance and class members
`__properties() -> iter() -> k, class`		iterate the flattened map of instance and class members
----------------------------------------- ----------------------------------------------------------
