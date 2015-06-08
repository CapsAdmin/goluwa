# luajit-msgpack-pure

## Presentation

This is yet another implementation of MessagePack for LuaJIT.
However, unlike [luajit-msgpack](https://github.com/catwell/luajit-msgpack),
luajit-msgpack-pure does not depend on the MessagePack C library.
Everything is re-implemented in LuaJIT code (using the FFI but only to
manipulate data structures).

## Alternatives

If I had to pick a single MessagePack implementation, it would be [lua-MessagePack](https://github.com/fperrad/lua-MessagePack). It is pure Lua, its performance is very close to luajit-msgpack-pure and it supports the latest revision of the standard. If it had existed earlier, I would not have written this one. *If you start a new project, use it.*

Another interesting implementation is [lua-cmsgpack](https://github.com/antirez/lua-cmsgpack), written in C specifically for use in Redis.

Other implementations:

 - [lua-msgpack](https://github.com/kengonakajima/lua-msgpack) (pure Lua)
 - [lua-msgpack-native](https://github.com/kengonakajima/lua-msgpack-native)
   (Lua-specific C implementation targeting luvit)
 - [MPLua](https://github.com/nobu-k/mplua) (binding)

Before luajit-msgpack-pure, I had written [luajit-msgpack](https://github.com/catwell/cw-lua/tree/master/luajit-msgpack), a FFI binding which is now deprecated.

## TODO

- Missing datatype tests
- Comparison tests vs. other implementations

## Usage

### Basics

```lua
local mp = require "luajit-msgpack-pure"
local my_data = {this = {"is",4,"test"}}
local encoded = mp.pack(my_data)
local offset,decoded = mp.unpack(encoded)
assert(offset == #encoded)
```

### Concatenating encoded data

```lua
local mp = require "luajit-msgpack-pure"
local my_data_1 = 42
local my_data_2 = "foo"
local encoded = mp.pack(my_data_1) .. mp.pack(my_data_2)
local offset_1,decoded_1 = mp.unpack(encoded)
assert(decoded_1 == 42)
local offset_2,decoded_2 = mp.unpack(encoded,offset_1)
assert(decoded_2 == "foo")
local offset_3,decoded_3 = mp.unpack(encoded,offset_2)
assert((not offset_3) and (decoded_3 == nil))
```

### Setting floating point precision

```lua
local mp = require "luajit-msgpack-pure"
local my_data = math.pi
local encoded_1 = mp.pack(my_data) -- default is double
local offset_1,decoded_1 = mp.unpack(encoded_1)
assert(offset_1 == 9) -- 1 byte overhead + 8 bytes double
assert(decoded_1 == math.pi)
mp.set_fp_type("float")
local encoded_2 = mp.pack(my_data)
local offset_2,decoded_2 = mp.unpack(encoded_2)
assert(offset_2 == 5) -- 1 byte overhead + 5 bytes float
assert(decoded_2 ~= math.pi) -- loss of precision
mp.set_fp_type("double") -- back to double precision
local encoded_3 = mp.pack(my_data)
local offset_3,decoded_3 = mp.unpack(encoded_3)
assert((offset_3 == 9) and (decoded_3 == math.pi))
```
## Copyright

Copyright (c) 2011-2014 Pierre Chapuis
