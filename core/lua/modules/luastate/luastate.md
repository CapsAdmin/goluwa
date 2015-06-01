---
tagline: Lua/LuaJIT C API binding
---

## `local luastate = require'luastate'`

A ffi binding to the Lua/LuaJIT C API, allowing the creation and manipulation
of Lua states.

--------------------------------------- --------------------------------------
__states__
luastate.open() -> state                create a new Lua state
state:close()                           free the Lua state
state:status() -> 0 | err | LUA_YIELD   state runtime status
state:newthread() -> state              create a new coroutine as a Lua state
state:resume(...) -> ok, ...            same as coroutine.resume()
__compiler__
state:loadbuffer(buf, sz, chunkname)    load a Lua chunk from a buffer
state:loadstring(s, name)               load a Lua chunk from a string
state:loadfile(filename)                load a Lua chunk from a file
state:load(reader, data, chunkname)     load a Lua chunk from a reader function
state:openlibs(lib1, ...)               open standard libs (open all, if no args given)
__stack / indices__
state:abs_index() -> i                  absolute stack index
state:gettop() -> i                     top stack index
state:settop(i)                         set stack top index
state:pop(n)                            pop n positions from stack
state:checkstack(n)                     assert that stack can grow at least n positions
__stack / read__
state:type(i) -> type                   type at index (same as type())
state:objlen(i) -> n                    string/table/userdata length
state:strlen(i) -> n                    string length
state:toboolean(i) -> true | false      get as boolean
state:tonumber(i) -> n                  get as number
state:tolstring(i) -> buf, sz           get as C string
state:tostring(i) -> s                  get as Lua string
state:tothread(i) -> state              get as Lua state
state:touserdata(i) -> ptr              get as userdata
__stack / read / tables__
state:next(i) -> true | false           pop k and push the next k, v at i
state:gettable(i)                       push t[k], where t at i and k at top
state:getfield(i, k)                    push t[k], where t at i
state:rawget(i)                         like gettable() but does raw access
state:rawgeti(i, n)                     push t[n], where t at i
state:getmetatable(tname)               push metatable of `tname` from registry
__stack / get / any value__
state:get(i) -> v                       get the value at i
__stack / write__
state:pushnil()                         push nil
state:pushboolean(bool)                 push a boolean
state:pushinteger(n)                    push an integer
state:pushcclosure(cfunc, nupvalues)    push a lua_CFunction with upvalues
state:pushcfunction(cfunc)              push a lua_CFunction
state:pushlightuserdata(ptr)            push a lightuserdata
state:pushlstring(buf, sz)              push a string buffer
state:pushstring(s)                     push a string
state:pushthread(state)                 push a coroutine
state:pushvalue(i)                      push value in stack at i
__stack / write / tables__
state:createtable(narr, nrec)           push a new empty table with preallocations
state:newtable()                        push a new empty table
state:settable(i)                       t[k] = v, where t at i, v at top, k at top-1
state:setfield(i, k)                    t[k] = v, where t at i, v at top
state:rawset(i)                         as settable() but does raw assignment
state:rawseti(i, n)                     t[n] = v, where t at i, v at top
state:setmetatable(i)                   pop mt and setmetatable(t, mt), where t at i
__stack / write / any value__
state:push(i, v)                        push any value (see note below)
__interpreter__
state:pushvalues(...)                   push multiple values
state:popvalues(top_before_call) -> ... pop multiple values and return then
state:pcall(...) -> ok, ...             pop func and args and pcall it
state:call(...) -> ...                  pop func and args and call it
__gc__
state:gc(luastate.C.LUA_GC*, n)         control the garbage collector
state:getgccount() -> n                 get the number of garbage items
__macros__
state:upvalueindex(i) -> i              get upvalue pseudo-index
state:register(name, func)              set _G[name] = func
state:setglobal(name)                   pop v and set _G[name] = v
state:getglobal(name)                   push _G[name]
state:getregistry()                     push the registry table
__C__
luastate.C                              C namespace (i.e. the ffi clib object)
--------------------------------------- --------------------------------------

Note: when pushing tables into the stack, duplicate keys or values
are dereferenced and table depth is stack-bound.
