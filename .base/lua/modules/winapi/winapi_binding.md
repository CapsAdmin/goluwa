---
project: winapi
tagline: developer documentation
---

## How to use the binding infrastructure

Pass the result of winapi calls to `checknz`, `checkh` and friends according
to what constitutes an error in the result: you get automatic error handling
and clear code.

Use `own(object, finalizer)` on all newly created objects but call
`disown(object)` right after any successful api call that assigns that object
an owner responsible for freeing it, and use `own()` again every time a call
leaves an object without an owner. Doing this consistently will complicate
the implementation sometimes but it prevents leaks and you get automatic object
lifetime management (for what is worth, given the non-deterministic nature
of the gc).

Avoid surfacing ABI boilerplate like buffers, buffer sizes and internal data
structures. Sometimes you may want to reuse a buffer to avoid heap trashing
especially on a function you know it could be called repeatedly many times.
In this case add the buffer as an optional trailing argument - if given it
will be used, if not, an internal buffer will be created. If there's a need
to pass state around beyond this, make a class (that is, do it in the
object layer).

Use `wcs(arg)` on all string args: if arg is a Lua string, it's assumed to be
an utf8 encoded string and it's converted to wcs, otherwise it's assumed a
wcs and passed through as is. This makes the API accept both Lua strings and
wcs strings transparently.

Use `flags(arg)` on all flag args so that you can pass a string of the form
`'FLAG1 FLAG2 ...'` as an alternative to `bit.bor(FLAG1, FLAG2, ...)`. It
also changes nil into 0 to allow for optional flag args to be passed where
winapi expects an int.

Count from 1! Use `countfrom0` on all positional args: this will decrement
the arg but only if it's strictly > 0 so that negative numbers are passed
through as they are since we want to preserve values with special meaning
like -1.

### Simple type constructors

Use `arg = types.FOO(arg)` instead of `arg = ffi.new('FOO', arg)`.
This allows passing a pre-allocated FOO as argument. Publish
common types in the winapi namespace: `FOO = types.FOO` and then use `FOO`
instead of `types.FOO`.

### Array constructors

Use `arg = arrays.FOO(arg)` instead of `arg = ffi.new('FOO[?]', #arg, arg)`.
This allows passing in a pre-allocated array as argument, and when passing
in a table, the array size will be #arg.

### Struct constructors

Don't allocate structs with ffi.new('FOO', arg). Instead, make a struct
constructor FOO = struct{...}, and pass all FOO args through it: arg = FOO(arg).

This can enable some magic, depending on how much you add to your definition:

  * the user can pass in a pre-allocated FOO which will be passed through.
  * if passing in a table, as it's usually the case,
    * the size (usually cbSize) field (if any) can be set automatically.
    * the struct's mask field (if any) can be set automatically to reflect
	 that only certain fields (those present in the table) need to be set.
	 * default values (eg. a version field) can be set automatically.
  * virtual fields with a getter and setter can be added which will be
  available alongside the cdata fields for all cdata of that type.

#### Virtual fields

Making a struct definition sets a metatable on the underlying ctype
(using ffi.metatype()), making any virtual fields available to all cdata
of that ctype. Accessing a struct through the virtual fields instead of the
C fields has some advantages:

  * the struct's mask field, if any, will be set based on which fields are
  set, provided a bitmask is specified in the struct's definition of that
  field. Setting a masked field to nil will clear its bitmask in the mask
  field. Getting the value of a field with its mask cleared returns nil,
  regardless of its data type.

  * bits of masked bitfields can be read and set individually, provided you
    define the data field, the mask field, and the prefix for the mask
    constants in the struct definition.

  * output (an in/out) buffers can be allocated and anchored to the struct
  automatically: you can add those in an `init` function.

#### Example:

~~~{.lua}
FOO = struct{
	ctype = 'FOO',    --the C struct that is to be created.
	size = 'cbSize',  --the field that must be set to sizeof(FOO), if any.
	mask = 'fMask',   --the field that masks other fields, if any.
	defaults = {
		nVersion = 1,  --set on creation.
		...
	},
	fields = mfields{ --mfields is the field def constructor for masked fields.
		'bar_field',    'barField',    MASK_BAR, setter, getter,
		'baz_field',    'bazField',    MASK_BAZ, pass,   pass,     -- setting baz_field sets MASK_BAZ in fMask.
		'zup_field',    'zupField',    MASK_ZUP, wcs,    mbs,      -- zup_field works with Lua strings.
		...
		'__state',      'stateField',     MASK_STATE, pass, pass,  -- bitfield, see below
		'__stateMask',  'stateMaskField', MASK_STATE, pass, pass,
	},
	bitfields = {
		-- setting state_FOO sets or clears the mask PREFIX_FOO in __state,
		-- and sets PREFIX_FOO to __stateMask (and sets MASK_STATE in fMask).
		-- getting state_FOO checks the mask PREFIX_FOO in __stateMask,
		-- and if set, checks the mask PREFIX_FOO in __state.
		state = {'__state', '__stateMask', 'PREFIX'},
	},
}
~~~

#### Naming virtual fields

Use the "lowercase with underscores" naming convention for virtual field names.
Use names like caption, x, y, w, h, pos, parent, etc. consistently throughout.

## How to use the OO system

The easiest way to bind a new control is to use the code of an existing
control as a template. Basically, you subclass from `Control` (or a specific
control, if your control is a refinement of a standard control) after you
define the style bitmasks, default values, and event name mappings, if any.
You override the constructor and/or any methods and define any new properties
by way of getters and setters.

