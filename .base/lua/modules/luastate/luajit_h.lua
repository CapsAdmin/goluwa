--luajit.h extensions from lualib.h from luajit 2.0
require'luastate.lua_h'
require'ffi'.cdef[[
enum {
/* More external and GCobj tags for internal objects. */
	LUA_TPROTO = (LUA_TTHREAD+1),
	LUA_TCDATA = (LUA_TTHREAD+2)
};

int (luaopen_bit) (lua_State *L);
int (luaopen_ffi) (lua_State *L);
int (luaopen_jit) (lua_State *L);
]]
