
--Lua C API ffi binding for Lua 5.1 and LuaJIT2.
--Written by Cosmin Apreutesei. Public Domain.

require'luastate.luajit_h'
local ffi = require'ffi'
local C = ffi.C
local M = {C = C}

--states

function M.open()
	local L = C.luaL_newstate()
	assert(L ~= nil, 'out of memory')
	ffi.gc(L, M.close)
	return L
end

function M.close(L)
	ffi.gc(L, nil)
	C.lua_close(L)
end

M.status = C.lua_status --0, error or LUA_YIELD

M.newthread = C.lua_newthread

--compiler

local function check(L, ret)
	if ret == 0 then return true end
	return false, M.tostring(L, -1)
end

function M.loadbuffer(L, buf, sz, chunkname)
	return check(L, C.luaL_loadbuffer(L, buf, sz, chunkname))
end

function M.loadstring(L, s, name)
	return M.loadbuffer(L, s, #s, name)
end

function M.loadfile(L, filename)
	return check(L, C.luaL_loadfile(L, filename))
end

function M.load(L, reader, data, chunkname)
	local reader_cb
	if type(reader) == 'function' then
		reader_cb = ffi.cast('lua_Reader', reader)
	end
	local ret = C.lua_load(L, reader_cb or reader, data, chunkname)
	if reader_cb then reader_cb:free() end
	return check(L, ret)
end

local lib_openers = {
	base = C.luaopen_base,
	table = C.luaopen_table,
	io = C.luaopen_io,
	os = C.luaopen_os,
	string = C.luaopen_string,
	math = C.luaopen_math,
	debug = C.luaopen_debug,
	package = C.luaopen_package,
	--luajit extensions
	ffi = C.luaopen_ffi,
	jit = C.luaopen_jit,
}

function M.openlibs(L, ...) --open specific libs (or all libs if no args given)
	local n = select('#', ...)
	if n == 0 then
		C.luaL_openlibs(L)
		return
	end
	for i=1,n do
		C.lua_pushcclosure(L, assert(lib_openers[select(i,...)]), 0)
		C.lua_call(L, 0, 0)
	end
	return L
end

--stack (indices)

function M.abs_index(L, i)
	return (i > 0 or i <= C.LUA_REGISTRYINDEX) and i or C.lua_gettop(L) + i + 1
end

M.gettop = C.lua_gettop
M.settop = C.lua_settop

function M.pop(L, n)
	C.lua_settop(L, -(n or 1) - 1)
end

function M.checkstack(L, n)
	assert(C.lua_checkstack(L, n) ~= 0, 'stack overflow')
end

--stack (read)

local lua_types = {
	[C.LUA_TNIL] = 'nil',
	[C.LUA_TBOOLEAN] = 'boolean',
	[C.LUA_TLIGHTUSERDATA] = 'lightuserdata',
	[C.LUA_TNUMBER] = 'number',
	[C.LUA_TSTRING] = 'string',
	[C.LUA_TTABLE] = 'table',
	[C.LUA_TFUNCTION] = 'function',
	[C.LUA_TUSERDATA] = 'userdata',
	[C.LUA_TTHREAD] = 'thread',
	[C.LUA_TCDATA] = 'cdata',
}

function M.type(L, index)
	local t = C.lua_type(L, index)
	assert(t ~= C.LUA_TNONE)
	return lua_types[t]
end

M.objlen = C.lua_objlen
M.strlen = C.lua_objlen

function M.isfunction(L, i) return C.lua_type(L, i) == C.LUA_TFUNCTION end
function M.istable(L, i) return C.lua_type(L, i) == C.LUA_TTABLE end
function M.islightuserdata(L, i) return C.lua_type(L, i) == C.LUA_TLIGHTUSERDATA end
function M.isnil(L, i) return C.lua_type(L, i) == C.LUA_TNIL end
function M.isboolean(L, i) return C.lua_type(L, i) == C.LUA_TBOOLEAN end
function M.isthread(L, i) return C.lua_type(L, i) == C.LUA_TTHREAD end
function M.isnone(L, i) return C.lua_type(L, i) == C.LUA_TNONE end
function M.isnoneornil(L, i) return C.lua_type(L, i) <= 0 end

function M.toboolean(L, index)
	return C.lua_toboolean(L, index) == 1
end

M.tonumber = C.lua_tonumber
M.tothread = C.lua_tothread
M.touserdata = C.lua_touserdata

local sz
function M.tolstring(L, index)
	sz = sz or ffi.new('size_t[1]')
	return C.lua_tolstring(L, index, sz), sz[0]
end

function M.tostring(L, index)
	return ffi.string(M.tolstring(L, index))
end

function M.next(L, index)
	return C.lua_next(L, index) ~= 0
end

M.gettable = C.lua_gettable
M.getfield = C.lua_getfield
M.rawget = C.lua_rawget
M.rawgeti = C.lua_rawgeti
M.getmetatable = C.lua_getmetatable

function M.get(L, index)
	index = index or -1
	local t = M.type(L, index)
	if t == 'nil' then
		return nil
	elseif t == 'boolean' then
		return M.toboolean(L, index)
	elseif t == 'number' then
		return M.tonumber(L, index)
	elseif t == 'string' then
		return M.tostring(L, index)
	elseif t == 'function' then
		index = M.abs_index(L, index)
		M.checkstack(L, 4)
		M.getglobal(L, 'string')
		M.getfield(L, -1, 'dump')
		M.pushvalue(L, index)
		C.lua_call(L, 1, 1)
		local s = M.get(L)
		M.pop(L, 3)
		return assert(loadstring(s))
	elseif t == 'table' then
		--NOTE: doesn't check duplicate refs
		--NOTE: stack-bound on table depth
		local top = M.gettop(L)
		M.checkstack(L, 2)
		local dt = {}
		index = M.abs_index(L, index)
		C.lua_pushnil(L) -- first key
		while C.lua_next(L, index) ~= 0 do
			local k = M.get(L, -2)
			local v = M.get(L, -1)
			dt[k] = v
			M.pop(L) -- remove 'value'; keep 'key' for next iteration
		end
		assert(M.gettop(L) == top)
		return dt
	elseif t == 'lightuserdata' then
		return M.touserdata(L, index)
	elseif t == 'userdata' then
		error'NYI'
	elseif t == 'thread' then
		error'NYI'
	elseif t == 'cdata' then
		error'NYI'
	end
end

--stack (write)

M.pushnil = C.lua_pushnil
M.pushboolean = C.lua_pushboolean
M.pushinteger = C.lua_pushinteger
M.pushnumber = C.lua_pushnumber
M.pushcclosure = C.lua_pushcclosure
function M.pushcfunction(L, f)
	C.lua_pushcclosure(L, f, 0)
end
M.pushlightuserdata = C.lua_pushlightuserdata
M.pushlstring = C.lua_pushlstring
function M.pushstring(L, s, sz)
	C.lua_pushlstring(L, s, sz or #s)
end
M.pushthread = C.lua_pushthread
M.pushvalue = C.lua_pushvalue --push stack element

M.settable = C.lua_settable
M.setfield = C.lua_setfield
M.rawset = C.lua_rawset
M.rawseti = C.lua_rawseti
M.setmetatable = C.lua_setmetatable
M.createtable = C.lua_createtable
function M.newtable(L)
	C.lua_createtable(L, 0, 0)
end

function M.push(L, v)
	if type(v) == 'nil' then
		M.pushnil(L)
	elseif type(v) == 'boolean' then
		M.pushboolean(L, v)
	elseif type(v) == 'number' then
		M.pushnumber(L, v)
	elseif type(v) == 'string' then
		M.pushstring(L, v)
	elseif type(v) == 'function' then
		M.loadstring(L, string.dump(v))
	elseif type(v) == 'table' then
		--NOTE: doesn't check duplicate refs
		--NOTE: stack-bound on table depth
		M.checkstack(L, 3)
		M.newtable(L)
		local top = M.gettop(L)
		for k,v in pairs(v) do
			M.push(L, k)
			M.push(L, v)
			M.settable(L, top)
		end
		assert(M.gettop(L) == top)
	elseif type(v) == 'userdata' then
		error'NYI'
	elseif type(v) == 'thread' then
		M.pushthread(L, v)
	elseif type(v) == 'cdata' then
		error'NYI'
	end
end

--interpreter

--push multiple values
function M.pushvalues(L, ...)
	local argc = select('#', ...)
	for i = 1, argc do
		M.push(L, select(i, ...))
	end
	return argc
end

--pop multiple values and return them
function M.popvalues(L, top_before_call)
	local n = M.gettop(L) - top_before_call + 1
	if n == 0 then
		return true
	elseif n == 1 then
		local ret = M.get(L, -1)
		M.pop(L)
		return true, ret
	else
		--collect/pop/unpack return values
		local t = {}
		for i = 1, n do
			t[i] = M.get(L, i - n - 1)
		end
		M.pop(L, n)
		return true, unpack(t, 1, n)
	end
end

--call the function at the top of the stack,
--wrapping the passing of args and the returning of return values.
function M.pcall(L, ...)
	local top = M.gettop(L)
	local argc = M.pushvalues(L, ...)
	local ok, err = check(L, C.lua_pcall(L, argc, C.LUA_MULTRET, 0))
	if not ok then
		return false, err
	end
	return M.popvalues(L, top)
end

local function pass(ok, ...)
	if not ok then error(..., 2) end
	return ...
end

function M.call(L, ...)
	return pass(M.pcall(L, ...))
end

--resume the coroutine at the top of the stack,
--wrapping the passing of args and the returning of yielded values.
function M.resume(L, ...)
	local top = M.gettop(L)
	local argc = M.pushvalues(L, ...)
	local ret = C.lua_resume(L, argc)
	local ok = ret == 0 or ret == C.LUA_YIELD
	return ok, M.popvalues(L, top)
end

--gc

M.gc = C.lua_gc

function M.getgccount(L)
	return C.lua_gc(L, C.LUA_GCCOUNT, 0)
end

-- macros from lua.h

function M.upvalueindex(i)
	return C.LUA_GLOBALSINDEX - i
end

function M.register(L, n, f)
	C.lua_pushcfunction(L, f)
	C.lua_setglobal(L, n)
end

function M.getglobal(L, s)
	C.lua_getfield(L, C.LUA_GLOBALSINDEX, s)
end

function M.setglobal(L, s)
	C.lua_setfield(L, C.LUA_GLOBALSINDEX, s)
end

function M.getregistry(L)
	C.lua_pushvalue(L, C.LUA_REGISTRYINDEX)
end

--object interface

ffi.metatype('lua_State', {__index = {
	--states
	close = M.close,
	status = M.status,
	newthread = M.newthread,
	resume = M.resume,
	--compiler
	loadbuffer = M.loadbuffer,
	loadstring = M.loadstring,
	loadfile = M.loadfile,
	load = M.load,
	openlibs = M.openlibs,
	--stack / indices
	abs_index = M.abs_index,
	gettop = M.gettop,
	settop = M.settop,
	pop = M.pop,
	checkstack = M.checkstack,
	--stack / read
	type = M.type,
	objlen = M.objlen,
	strlen = M.strlen,
	toboolean = M.toboolean,
	tonumber = M.tonumber,
	tolstring = M.tolstring,
	tostring = M.tostring,
	tothread = M.tothread,
	touserdata = M.touserdata,
	--stack / read / tables
	next = M.next,
	gettable = M.gettable,
	getfield = M.getfield,
	rawget = M.rawget,
	rawgeti = M.rawgeti,
	getmetatable = M.getmetatable,
	--stack / get / synthesis
	get = M.get,
	--stack / write
	pushnil = M.pushnil,
	pushboolean = M.pushboolean,
	pushinteger = M.pushinteger,
	pushcclosure = M.pushcclosure,
	pushcfunction = M.pushcfunction,
	pushlightuserdata = M.pushlightuserdata,
	pushlstring = M.pushlstring,
	pushstring = M.pushstring,
	pushthread = M.pushthread,
	pushvalue = M.pushvalue,
	--stack / write / tables
	createtable = M.createtable,
	newtable = M.newtable,
	settable = M.settable,
	setfield = M.setfield,
	rawset = M.rawset,
	rawseti = M.rawseti,
	setmetatable = M.setmetatable,
	--stack / write / synthesis
	push = M.push,
	--interpreter
	pushvalues = M.pushvalues,
	popvalues = M.popvalues,
	pcall = M.pcall,
	call = M.call,
	--gc
	gc = M.gc,
	getgccount = M.getgccount,
	--macros
	upvalueindex = M.upvalueindex,
	register = M.register,
	setglobal = M.setglobal,
	getglobal = M.getglobal,
	getregistry = M.getregistry,
}})


return M
