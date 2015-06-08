---
project: glue
tagline: everyday Lua functions
---

## `local glue = require'glue'`

----------------------------------------------------------------- ----------------------------------------------------------------
__tables__
glue.index(t) -> dt                                               [switch keys with values](#index)
glue.keys(t[, sorted | cmp]) -> dt                                [make a list of all the keys](#keys)
glue.update(dt,t1,...) -> dt                                      [merge tables - overwrites keys](#update)
glue.merge(dt,t1,...) -> dt                                       [merge tables - no overwriting](#merge)
glue.sortedpairs(t[, cmp])-> iterator<k,v>                        [like pairs() but in key order](#sortedpairs)
__lists__
glue.extend(dt,t1,...) -> dt                                      [extend a list](#extend)
glue.append(dt,v1,...) -> dt                                      [append non-nil values to a list](#append)
glue.shift(t,i,n) -> t                                            [shift list elements](#shift)
__strings__
glue.gsplit(s,sep[, plain]) -> iterator<e[,captures...]>          [split a string by a pattern](#gsplit)
glue.trim(s) -> s                                                 [remove padding](#trim)
glue.escape(s[,mode])-> s                                         [escape magic pattern characters](#escape)
glue.tohex(s) -> s                                                [string to hex](#tohex)
glue.fromhex(s) -> s                                              [hex to string](#fromhex)
__iterators__
glue.collect([i,]iterator)-> t                                    [collect iterated values into a list](#collect)
__closures__
glue.pass(...) -> ...                                             [does nothing, returns back all arguments](#pass)
__metatables__
glue.inherit(t,parent) -> t                                       [set or clear inheritance](#inherit)
glue.autotable([t]) -> t														[autotable pattern](#autotable)
__i/o__
glue.fileexists(file) -> true | false                             [check if a file exists and it's readable](#fileexists)
glue.readfile(file[,format]) -> s | nil, err                      [read the contents of a file into a string](#readfile)
glue.writefile(file,s[,format])                                   [write a string to a file](#writefile)
__errors__
glue.assert(v,[message[,args...]]) -> args                        [assert with error message formatting](#assert)
glue.unprotect(ok,result,...) -> result,... | nil,result,...      [unprotect a protected call](#unprotect)
glue.pcall(f,...) -> true,... | false,traceback                   [pcall with traceback](#pcall) _(not for Lua 5.1)_
glue.fpcall(f,...) -> result | nil,traceback                      [coding with finally and except](#fpcall)
glue.fcall(f,...) -> result
__modules__
glue.autoload(t, submodule) -> t                                  [autoload table keys from submodules](#autoload)
glue.autoload(t, key, module|loader) -> t                         [autoload table keys from submodules](#autoload)
glue.bin                                                          [get the script's directory](#bin)
glue.luapath(path[, index[, ext]])                                [insert a path in package.path](#luapath)
glue.cpath(path[, index])                                         [insert a path in package.cpath](#cpath)
__malloc__
glue.malloc([ctype, ]size) -> cdata                               [allocate an array using system's malloc](#malloc-array)
glue.malloc(ctype) -> cdata                                       [allocate a C type using system's malloc](#malloc-ctype)
glue.free(cdata)                                                  [free malloc'ed memory](#free)
----------------------------------------------------------------- ----------------------------------------------------------------

## `glue.index(t) -> dt` {#index}

Switch table keys with values.

### Examples

Extract a rfc850 date from a string. Use lookup tables for weekdays and months.

~~~{.lua}
local weekdays = glue.index{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}
local months = glue.index{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}

--weekday "," SP 2DIGIT "-" month "-" 2DIGIT SP 2DIGIT ":" 2DIGIT ":" 2DIGIT SP "GMT"
--eg. Sunday, 06-Nov-94 08:49:37 GMT
function rfc850date(s)
   local w,d,mo,y,h,m,s = s:match'([A-Za-z]+), (%d+)%-([A-Za-z]+)%-(%d+) (%d+):(%d+):(%d+) GMT'
   d,y,h,m,s = tonumber(d),tonumber(y),tonumber(h),tonumber(m),tonumber(s)
   w = assert(weekdays[w])
   mo = assert(months[mo])
   if y then y = y + (y > 50 and 1900 or 2000) end
   return {wday = w, day = d, year = y, month = mo, hour = h, min = m, sec = s}
end

for k,v in pairs(rfc850date'Sunday, 06-Nov-94 08:49:37 GMT') do
   print(k,v)
end
~~~

Output

	day	6
	sec	37
	wday	1
	min	49
	year	1994
	month	11
	hour	8


Copy-paste a bunch of defines from a C header file and create an inverse lookup table to find the name of a value at runtime.

~~~{.lua}
--from ibase.h
info_end_codes = {
   isc_info_end             = 1,  --normal ending
   isc_info_truncated       = 2,  --receiving buffer too small
   isc_info_error           = 3,  --error, check status vector
   isc_info_data_not_ready  = 4,  --data not available for some reason
   isc_info_svc_timeout     = 64, --timeout expired
}
info_end_code_names = glue.index(info_end_codes)
print(info_end_code_names[64])
~~~

Output

	isc_info_svc_timeout

--------------------------------------------------------------------------------------------------------------------------

## `glue.keys(t[, sorted | cmp]) -> dt` {#keys}

Make a list of all the keys of `t`, optionally sorted.

### Examples

An API expects a list of things but you have them as keys in a table because you are indexing something on them.

For instance, you have a table of the form `{socket = thread}` but `socket.select` wants a list of sockets.

See also: [glue.sortedpairs](#sortedpairs).

--------------------------------------------------------------------------------------------------------------------------

## `glue.update(dt,t1,...) -> dt` {#update}

Update a table with elements of other tables, overwriting any existing keys.

  * nil arguments are skipped.

### Examples

Create an options table by merging the options received as an argument (if any) over the default options.

~~~{.lua}
function f(opts)
   opts = glue.update({}, default_opts, opts)
end
~~~

Shallow table copy:

~~~{.lua}
t = glue.update({}, t)
~~~

Static multiple inheritance:

~~~{.lua}
C = glue.update({}, A, B) --#TODO: find real-world example of multiple inheritance
~~~

See also: [glue.extend](#extend), [glue.inherit](#inherit).

--------------------------------------------------------------------------------------------------------------------------

## `glue.merge(dt,t1,...) -> dt` {#merge}

Update a table with elements of other tables skipping on any existing keys.

  * nil arguments are skipped.

### Examples

Normalize a data object with default values:

~~~{.lua}
glue.merge(t, defaults)
~~~

See also: [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.sortedpairs(t[,cmp]) -> iterator<k,v>` {#sortedpairs}

Like pairs() but in key order.

The implementation creates a temporary table to sort the keys in.

See also: [glue.keys](#keys).

--------------------------------------------------------------------------------------------------------------------------

## `glue.extend(dt,t1,...) -> dt` {#extend}

Extend the list with the elements of other lists.

  * nil arguments are skipped.
  * list elements are the ones from 1 to `#dt`.

### Uses

Accumulating values from multiple list sources.

See also: [glue.append](#append), [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.append(dt,v1,...) -> dt` {#append}

Append non-nil arguments to a list.

### Uses

Appending an object to a flattened list of lists (eg. appending a path element to a 2d path).

See also: [glue.extend](#extend), [glue.update](#update).

--------------------------------------------------------------------------------------------------------------------------

## `glue.shift(t,i,n) -> t` {#shift}

Shift all the list elements starting at index `i`, `n` positions to the left or further to the right.

For a positive `n`, shift the elements further to the right, effectively creating room for `n` new elements at index `i`.
When `n` is 1, the effect is the same as for `table.insert(t, i, t[i])`.
The old values at index `i` to `i+n-1` are preserved, so `#t` still works after the shifting.

For a negative `n`, shift the elements to the left, effectively removing the `n` elements at index `i`.
When `n` is -1, the effect is the same as for `table.remove(t, i)`.

### Uses

Removing a portion of a list or making room for more elements inside the list.

See also: [glue.extend](#extend).

--------------------------------------------------------------------------------------------------------------------------

## `glue.gsplit(s,sep[,plain]) -> iterator<e[,captures...]>` {#gsplit}

Split a string by a separator pattern (or plain string) and iterate over the elements.

  * if sep is "" return the entire string in one iteration
  * if s is "" return s in one iteration
  * empty strings between separators are always returned, eg. `glue.gsplit(',', ',')` produces 2 empty strings
  * captures are allowed in sep and they are returned after the element, except for the last element for
    which they don't match (by definition).

### Examples

~~~{.lua}
for s in glue.gsplit('Spam eggs spam spam and ham', '%s*spam%s*') do
   print('"'..s..'"')
end

> "Spam eggs"
> ""
> "and ham"
~~~

### Design notes

  * name choice: associate with `gmatch` and `gsub`
  * allowing captures in `sep` doesn't have very readable semantics

--------------------------------------------------------------------------------------------------------------------------

## `glue.trim(s) -> s` {#trim}

Remove whitespace (defined as Lua pattern `%s`) from the beginning and end of a string.

--------------------------------------------------------------------------------------------------------------------------

## `glue.escape(s[,mode]) -> pat` {#escape}

Escape magic characters of the string `s` so that it can be used as a pattern to string matching functions.

  * the optional argument `mode` can have the value `"*i"` (for case insensitive), in which case each alphabetical
    character in `s` will also be escaped as `[aA]` so that it matches both its lowercase and uppercase variants.
  * escapes embedded zeroes as the `%z` pattern.

### Uses

  * workaround for lack of pattern syntax for "this part of a match is an arbitrary string"
  * workaround for lack of a case-insensitive flag in pattern matching functions

### Design notes

Test the performance of the case-insensitive hack to see if it's feasible.

--------------------------------------------------------------------------------------------------------------------------

## `glue.tohex(s[,upper]) -> s` {#tohex}

## `glue.tohex(n[,upper]) -> s`

Convert a binary string or a Lua number to its hex representation.

  * lowercase by default
  * uppercase if `upper` is anything non-false, like say, the string "upper"
  * numbers must be in the unsigned 32 bit integer range

See also: [glue.fromhex](#fromhex).

--------------------------------------------------------------------------------------------------------------------------

## `glue.fromhex(s) -> s` {#fromhex}

Convert a hex string to its binary representation.

See also: [glue.tohex](#tohex).

--------------------------------------------------------------------------------------------------------------------------

## `glue.collect([i, ]iterator) -> t` {#collect}

Iterate an iterator and collect its i'th return value of every step into a list.

  * i defaults to 1

### Examples

Implementation of `keys()` and `values()` in terms of `collect()`

~~~{.lua}
keys = function(t) return glue.collect(pairs(t)) end
values = function(t) return glue.collect(2,pairs(t)) end
~~~

Collecting string matches:

~~~{.lua}
s = 'a,b,c,'
t = glue.collect(s:gmatch'(.-),')
for i=1,#t do print(t[i]) end

> a
> b
> c
~~~

### Design notes

Alt. name: `ipack` - like pack but for iterators; collect is better at suggesting a process done in steps.

--------------------------------------------------------------------------------------------------------------------------

## `glue.pass(...) -> ...` {#pass}

The identity function. Does nothing, returns back all arguments.

### Uses

Default value for optional callback arguments:

~~~{.lua}
function urlopen(url, callback, errback)
   callback = callback or glue.pass
   errback = errback or glue.pass
   ...
   callback()
end
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.inherit(t, parent) -> t` {#inherit}

## `glue.inherit(t, nil) -> t`

Set a table to inherit attributes from a parent table, or clear inheritance.

If the table has no metatable (and inheritance has to be set, not cleared) make it one.

### Examples

Logging mixin:

~~~{.lua}
AbstractLogger = glue.inherit({}, function(t,k) error('abstract '..k) end)
NullLogger = glue.inherit({log = function() end}, AbstractLogger)
PrintLogger = glue.inherit({log = function(self,...) print(...) end}, AbstractLogger)

HttpRequest = glue.inherit({
   perform = function(self, url)
      self:log('Requesting', url, '...')
      ...
   end
}, NullLogger)

LoggedRequest = glue.inherit({log = PrintLogger.log}, HttpRequest)

LoggedRequest:perform'http://lua.org/'

> Requesting	http://lua.org/	...
~~~

Defining a module in Lua 5.2

~~~{.lua}
_ENV = glue.inherit({},_G)
...
~~~

Hints:

  * to get the effect of static (single or multiple) inheritance, use [glue.update](#update).
  * when setting inheritance, you can pass in a function.

### Design notes

`t = setmetatable({},{__index=parent})` is not much longer and it's idiomatic, but doesn't shout
inheritance at you (you have to process the indirection, like with functional idioms) and you can't
use it to change the parent (a minor quibble nevertheless).

Overriding of methods needs an easy way to access the "parent" or to invoke a method on the parent.
A top-level class could provide this simply by defining `function Object:parent() return getmetatable(self).__index end`.

--------------------------------------------------------------------------------------------------------------------------

## `glue.autotable([t]) -> t` {#autotable}

Set a table to create/return missing keys as autotables.

In the example below, `t.a`, `t.a.b`, `t.a.b.c` are created automatically
as autotables.

~~~{.lua}
local t = autotable()
t.a.b.c.d = 'hello'
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.fileexists(file) -> true | false` {#fileexists}

Checks whether a file exists and it's available for reading.

See also: [glue.readfile](#readfile).

--------------------------------------------------------------------------------------------------------------------------

## `glue.readfile(file[,format]) -> s | nil, err` {#readfile}

Read the contents of a file into a string.

  * `format` can be `t` in which case the file will be read in text mode (default is binary mode).

See also: [glue.writefile](#writefile), [glue.fileexists](#fileexists).

--------------------------------------------------------------------------------------------------------------------------

## `glue.writefile(file,s[,format])` {#writefile}

Write the contents of a string to a file.

  * `format` can be `t` in which case the file will be written in text mode (default is binary mode).

See also: [glue.readfile](#readfile).

--------------------------------------------------------------------------------------------------------------------------

## `glue.assert(v[, message[, format_args...]])` {#assert}

Like `assert` but supports formatting of the error message using string.format.

This is better than `assert(string.format(message, format_args...))` because it avoids creating
the message string when the assertion is true.

### Example

~~~{.lua}
glue.assert(depth <= maxdepth, 'maximum depth %d exceeded', maxdepth)
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.unprotect(ok,result,...) -> result,... | nil,result,...` {#unprotect}

In Lua, API functions conventionally signal errors by returning nil and an error message instead of raising exceptions.
In the implementation however, using assert() and error() is preferred to coding explicit conditional flows to cover
exceptional cases. Use this function to convert error-raising functions to nice nil,error-returning functions:

~~~{.lua}
function my_API_function()
  return glue.unprotect(pcall(function()
    ...
    assert(...)
    ...
    error(...)
    ...
    return result_value
  end))
end
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.pcall(f,...) -> true,... | false,error..'\n'..traceback` {#pcall}

With Lua's pcall() you lose the stack trace, and with usual uses of pcall()
you don't want that. This variant appends the traceback to the error message.

> __NOTE__: Lua 5.2 and LuaJIT only.

--------------------------------------------------------------------------------------------------------------------------

## `glue.fpcall(f,...) -> result | nil,error..'\n'..traceback` {#fpcall}

## `glue.fcall(f,...) -> result`

These constructs bring the ubiquitous try/finally/except idiom to Lua. The first variant returns nil,error
when errors occur while the second re-raises the error.

### Example

~~~{.lua}
local result = glue.fpcall(function(finally, except, ...)
  local temporary_resource = acquire_resource()
  finally(function() temporary_resource:free() end)
  ...
  local final_resource = acquire_resource()
  except(function() final_resource:free() end)
  ... code that might break ...
  return final_resource
end, ...)
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.autoload(t, submodules) -> t` {#autoload}
## `glue.autoload(t, key, module|loader) -> t`

Assign a metatable to `t` such that when a missing key is accessed, the module said to contain that key is require'd automatically.

The `submodules` argument is a table of form `{key = module_name | load_function}` specifying the corresponding
Lua module (or load function) that make each key available to `t`. The alternative syntax allows specifying
the key - submodule associations one by one.

### Motivation

Module autoloading allows you to split the implementation of a module in many submodules containing optional,
self-contained functionality, without having to make this visible in the user API. This effectively separates
how you split your APIs from how you split the implementation, allowing you to change the way the implementation
is split at a later time while keeping the API intact.

### Example

**main module (foo.lua):**

~~~{.lua}
local function bar() --function implemented in the main module
  ...
end

--create and return the module table
return glue.autoload({
   ...
   bar = bar,
}, {
   baz = 'foo_extra', --autoloaded function, implemented in module foo_extra
})
~~~

**submodule (foo_extra.lua):**

~~~{.lua}
local foo = require'foo'

function foo.baz(...)
  ...
end
~~~

**in usage:**

~~~{.lua}
local foo = require'foo'

foo.baz(...) -- foo_extra was now loaded automatically
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.bin` {#bin}

Get the script's directory, based on [lua-find-bin] by David Manura. This allows finding files in the script's
directory regardless of the directory that Lua is started in.

### Example

~~~{.lua}
local foobar = glue.readfile(glue.bin .. '/' .. file_near_this_script)
~~~

### Caveats

This only works if glue itself can already be found and required (chicken/egg catch22 and the rest).
The path is relative to the current directory, it stops working if the current directory is changed.
The assumption is that if you can do chdir() then you can also do getfullpath() or at least getcurrentdir(),
and thus correct `glue.bin` in time with:

	glue.bin = getfullpath(glue.bin)

or

	glue.bin = getcurrentdir() .. '/' .. glue.bin

--------------------------------------------------------------------------------------------------------------------------

## `glue.luapath(path[, index[, ext]])` {#luapath}

Insert a Lua search pattern in `package.path` such that `require` will be able
to load Lua modules from that path. The optional `index` arg specifies the
insert position (default is 1, that is, before all existing paths; can be
negative, to start counting from the end; can be the string 'after', which is
the same as 0). The optional `ext` arg specifies the file extension to use
(default is "lua").

## `glue.cpath(path[, index])` {#cpath}

Insert a Lua search pattern in `package.cpath` such that `require` will be
able to load Lua/C modules from that path. The `index` arg has the same
meaning as with `glue.luapath`.

### Example

~~~{.lua}
glue.luapath(glue.bin)
glue.cpath(glue.bin)

require'foo' --looking for `foo` in the same directory as the running script first
~~~

--------------------------------------------------------------------------------------------------------------------------

## `glue.malloc([ctype, ]size) -> cdata` {#malloc-array}

Allocate a `ctype[size]` array with system's malloc. Useful for allocating
larger chunks of memory without hitting the default allocator's 2 GB limit.

  * the returned cdata has the type `ctype(&)[size]` so ffi.sizeof(cdata)
  returns the correct size.
  * `ctype` defaults to `char`.
  * failure to allocate results in error.
  * the memory is freed when the cdata gets collected or with `glue.free()`.

__REMEMBER!__ Just like with `ffi.new`, casting the result cdata further will
get you _weak references_ to the allocated memory. To transfer ownership
of the memory, use `ffi.gc(original, nil); ffi.gc(pointer, glue.free)`.

> __NOTE__: LuaJIT only.

## `glue.malloc(ctype) -> cdata` {#malloc-ctype}

Allocate a `ctype` with system's malloc. The result has the type `ctype&`.

## `glue.free(cdata)` {#free}

Free malloc'ed memory.

### Example

~~~{.lua}
local data = glue.malloc(100)
assert(ffi.sizeof(data) == 100)
glue.free(data)

local data = glue.malloc('int', 100)
assert(ffi.sizeof(data) == 100 * ffi.sizeof'int')
glue.free(data)

local data = glue.malloc('struct S')
assert(ffi.typeof(data) ==
assert(ffi.sizeof(data) == ffi.sizeof'struct S')
glue.free(data)

~~~

--------------------------------------------------------------------------------------------------------------------------

## Tips

String functions are also in the `glue.string` table. You can extend the Lua `string` namespace:

	glue.update(string, glue.string)

so you can use them as string methods:

	s = s:trim()


## Keywords
_for syntax highlighting_

glue.index, glue.keys, glue.update, glue.merge, glue.extend, glue.append, glue.shift, glue.gsplit, glue.trim,
glue.escape, glue.collect, glue.pass, glue.inherit, glue.fileexists, glue.readfile, glue.writefile, glue.assert,
glue.unprotect, glue.pcall, glue.fpcall, glue.fcall, glue.autoload, glue.bin, glue.luapath, glue.cpath


## Design

[glue_design]


[lua-find-bin]:  https://github.com/davidm/lua-find-bin
