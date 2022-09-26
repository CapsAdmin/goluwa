			local ffi = require("ffi")
			local lib = ffi.C
			ffi.cdef([[struct lua_State {};
struct lua_Debug {int event;const char*name;const char*namewhat;const char*what;const char*source;int currentline;int nups;int linedefined;int lastlinedefined;char short_src[60];int i_ci;};
struct luaL_Reg {const char*name;int(*func)(struct lua_State*);};
struct luaL_Buffer {char*p;int lvl;struct lua_State*L;};
char*(luaL_prepbuffer)(struct luaL_Buffer*);
const char*(luaL_checklstring)(struct lua_State*,int,unsigned long*);
const char*(luaL_findtable)(struct lua_State*,int,const char*,int);
const char*(luaL_gsub)(struct lua_State*,const char*,const char*,const char*);
const char*(luaL_optlstring)(struct lua_State*,int,const char*,unsigned long*);
const char*(lua_getlocal)(struct lua_State*,const struct lua_Debug*,int);
const char*(lua_getupvalue)(struct lua_State*,int,int);
const char*(lua_pushfstring)(struct lua_State*,const char*,...);
const char*(lua_pushvfstring)(struct lua_State*,const char*,__builtin_va_list);
const char*(lua_setlocal)(struct lua_State*,const struct lua_Debug*,int);
const char*(lua_setupvalue)(struct lua_State*,int,int);
const char*(lua_tolstring)(struct lua_State*,int,unsigned long*);
const char*(lua_typename)(struct lua_State*,int);
const double*(lua_version)(struct lua_State*);
const void*(lua_topointer)(struct lua_State*,int);
double(luaL_checknumber)(struct lua_State*,int);
double(luaL_optnumber)(struct lua_State*,int,double);
double(lua_tonumber)(struct lua_State*,int);
double(lua_tonumberx)(struct lua_State*,int,int*);
int(luaL_argerror)(struct lua_State*,int,const char*);
int(luaL_callmeta)(struct lua_State*,int,const char*);
int(luaL_checkoption)(struct lua_State*,int,const char*,const char*const lst);
int(luaL_error)(struct lua_State*,const char*,...);
int(luaL_execresult)(struct lua_State*,int);
int(luaL_fileresult)(struct lua_State*,int,const char*);
int(luaL_getmetafield)(struct lua_State*,int,const char*);
int(luaL_loadbuffer)(struct lua_State*,const char*,unsigned long,const char*);
int(luaL_loadbufferx)(struct lua_State*,const char*,unsigned long,const char*,const char*);
int(luaL_loadfile)(struct lua_State*,const char*);
int(luaL_loadfilex)(struct lua_State*,const char*,const char*);
int(luaL_loadstring)(struct lua_State*,const char*);
int(luaL_newmetatable)(struct lua_State*,const char*);
int(luaL_ref)(struct lua_State*,int);
int(luaL_typerror)(struct lua_State*,int,const char*);
int(lua_checkstack)(struct lua_State*,int);
int(lua_cpcall)(struct lua_State*,int(*func)(struct lua_State*),void*);
int(lua_dump)(struct lua_State*,int(*writer)(struct lua_State*,const void*,unsigned long,void*),void*);
int(lua_equal)(struct lua_State*,int,int);
int(lua_error)(struct lua_State*);
int(lua_gc)(struct lua_State*,int,int);
int(lua_gethookcount)(struct lua_State*);
int(lua_gethookmask)(struct lua_State*);
int(lua_getinfo)(struct lua_State*,const char*,struct lua_Debug*);
int(lua_getmetatable)(struct lua_State*,int);
int(lua_getstack)(struct lua_State*,int,struct lua_Debug*);
int(lua_gettop)(struct lua_State*);
int(lua_iscfunction)(struct lua_State*,int);
int(lua_isnumber)(struct lua_State*,int);
int(lua_isstring)(struct lua_State*,int);
int(lua_isuserdata)(struct lua_State*,int);
int(lua_isyieldable)(struct lua_State*);
int(lua_lessthan)(struct lua_State*,int,int);
int(lua_load)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*);
int(lua_loadx)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*,const char*);
int(lua_next)(struct lua_State*,int);
int(lua_pcall)(struct lua_State*,int,int,int);
int(lua_pushthread)(struct lua_State*);
int(lua_rawequal)(struct lua_State*,int,int);
int(lua_resume)(struct lua_State*,int);
int(lua_setfenv)(struct lua_State*,int);
int(lua_sethook)(struct lua_State*,void(*func)(struct lua_State*,struct lua_Debug*),int,int);
int(lua_setmetatable)(struct lua_State*,int);
int(lua_status)(struct lua_State*);
int(lua_toboolean)(struct lua_State*,int);
int(lua_type)(struct lua_State*,int);
int(lua_yield)(struct lua_State*,int);
int(luaopen_base)(struct lua_State*);
int(luaopen_bit)(struct lua_State*);
int(luaopen_debug)(struct lua_State*);
int(luaopen_ffi)(struct lua_State*);
int(luaopen_io)(struct lua_State*);
int(luaopen_jit)(struct lua_State*);
int(luaopen_math)(struct lua_State*);
int(luaopen_os)(struct lua_State*);
int(luaopen_package)(struct lua_State*);
int(luaopen_string)(struct lua_State*);
int(luaopen_string_buffer)(struct lua_State*);
int(luaopen_table)(struct lua_State*);
int(*lua_atpanic(struct lua_State*,int(*panicf)(struct lua_State*)))(struct lua_State*);
int(*lua_tocfunction(struct lua_State*,int))(struct lua_State*);
long(luaL_checkinteger)(struct lua_State*,int);
long(luaL_optinteger)(struct lua_State*,int,long);
long(lua_tointeger)(struct lua_State*,int);
long(lua_tointegerx)(struct lua_State*,int,int*);
struct lua_State*(luaL_newstate)();
struct lua_State*(lua_newstate)(void*(*f)(void*,void*,unsigned long,unsigned long),void*);
struct lua_State*(lua_newthread)(struct lua_State*);
struct lua_State*(lua_tothread)(struct lua_State*,int);
unsigned long(lua_objlen)(struct lua_State*,int);
void*(luaL_checkudata)(struct lua_State*,int,const char*);
void*(luaL_testudata)(struct lua_State*,int,const char*);
void*(lua_newuserdata)(struct lua_State*,unsigned long);
void*(lua_touserdata)(struct lua_State*,int);
void*(lua_upvalueid)(struct lua_State*,int,int);
void*(*lua_getallocf(struct lua_State*,void**))(void*,void*,unsigned long,unsigned long);
void(luaL_addlstring)(struct luaL_Buffer*,const char*,unsigned long);
void(luaL_addstring)(struct luaL_Buffer*,const char*);
void(luaL_addvalue)(struct luaL_Buffer*);
void(luaL_buffinit)(struct lua_State*,struct luaL_Buffer*);
void(luaL_checkany)(struct lua_State*,int);
void(luaL_checkstack)(struct lua_State*,int,const char*);
void(luaL_checktype)(struct lua_State*,int,int);
void(luaL_openlib)(struct lua_State*,const char*,const struct luaL_Reg*,int);
void(luaL_openlibs)(struct lua_State*);
void(luaL_pushmodule)(struct lua_State*,const char*,int);
void(luaL_pushresult)(struct luaL_Buffer*);
void(luaL_register)(struct lua_State*,const char*,const struct luaL_Reg*);
void(luaL_setfuncs)(struct lua_State*,const struct luaL_Reg*,int);
void(luaL_setmetatable)(struct lua_State*,const char*);
void(luaL_traceback)(struct lua_State*,struct lua_State*,const char*,int);
void(luaL_unref)(struct lua_State*,int,int);
void(luaL_where)(struct lua_State*,int);
void(lua_call)(struct lua_State*,int,int);
void(lua_close)(struct lua_State*);
void(lua_concat)(struct lua_State*,int);
void(lua_copy)(struct lua_State*,int,int);
void(lua_createtable)(struct lua_State*,int,int);
void(lua_getfenv)(struct lua_State*,int);
void(lua_getfield)(struct lua_State*,int,const char*);
void(lua_gettable)(struct lua_State*,int);
void(lua_insert)(struct lua_State*,int);
void(lua_pushboolean)(struct lua_State*,int);
void(lua_pushcclosure)(struct lua_State*,int(*fn)(struct lua_State*),int);
void(lua_pushinteger)(struct lua_State*,long);
void(lua_pushlightuserdata)(struct lua_State*,void*);
void(lua_pushlstring)(struct lua_State*,const char*,unsigned long);
void(lua_pushnil)(struct lua_State*);
void(lua_pushnumber)(struct lua_State*,double);
void(lua_pushstring)(struct lua_State*,const char*);
void(lua_pushvalue)(struct lua_State*,int);
void(lua_rawget)(struct lua_State*,int);
void(lua_rawgeti)(struct lua_State*,int,int);
void(lua_rawset)(struct lua_State*,int);
void(lua_rawseti)(struct lua_State*,int,int);
void(lua_remove)(struct lua_State*,int);
void(lua_replace)(struct lua_State*,int);
void(lua_setallocf)(struct lua_State*,void*(*f)(void*,void*,unsigned long,unsigned long),void*);
void(lua_setfield)(struct lua_State*,int,const char*);
void(lua_setlevel)(struct lua_State*,struct lua_State*);
void(lua_settable)(struct lua_State*,int);
void(lua_settop)(struct lua_State*,int);
void(lua_upvaluejoin)(struct lua_State*,int,int,int,int);
void(lua_xmove)(struct lua_State*,struct lua_State*,int);
void(*lua_gethook(struct lua_State*))(struct lua_State*,struct lua_Debug*);
]])
			local CLIB = setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return lib[k] end)
				if ok then
					return val
				end
			end})
		library = {
	atpanic = CLIB.lua_atpanic,
	call = CLIB.lua_call,
	checkstack = CLIB.lua_checkstack,
	close = CLIB.lua_close,
	concat = CLIB.lua_concat,
	copy = CLIB.lua_copy,
	cpcall = CLIB.lua_cpcall,
	createtable = CLIB.lua_createtable,
	dump = CLIB.lua_dump,
	equal = CLIB.lua_equal,
	error = CLIB.lua_error,
	gc = CLIB.lua_gc,
	getallocf = CLIB.lua_getallocf,
	getfenv = CLIB.lua_getfenv,
	getfield = CLIB.lua_getfield,
	gethook = CLIB.lua_gethook,
	gethookcount = CLIB.lua_gethookcount,
	gethookmask = CLIB.lua_gethookmask,
	getinfo = CLIB.lua_getinfo,
	getlocal = CLIB.lua_getlocal,
	getmetatable = CLIB.lua_getmetatable,
	getstack = CLIB.lua_getstack,
	gettable = CLIB.lua_gettable,
	gettop = CLIB.lua_gettop,
	getupvalue = CLIB.lua_getupvalue,
	insert = CLIB.lua_insert,
	iscfunction = CLIB.lua_iscfunction,
	isnumber = CLIB.lua_isnumber,
	isstring = CLIB.lua_isstring,
	isuserdata = CLIB.lua_isuserdata,
	isyieldable = CLIB.lua_isyieldable,
	lessthan = CLIB.lua_lessthan,
	load = CLIB.lua_load,
	loadx = CLIB.lua_loadx,
	newstate = CLIB.lua_newstate,
	newthread = CLIB.lua_newthread,
	newuserdata = CLIB.lua_newuserdata,
	next = CLIB.lua_next,
	objlen = CLIB.lua_objlen,
	pcall = CLIB.lua_pcall,
	pushboolean = CLIB.lua_pushboolean,
	pushcclosure = CLIB.lua_pushcclosure,
	pushfstring = CLIB.lua_pushfstring,
	pushinteger = CLIB.lua_pushinteger,
	pushlightuserdata = CLIB.lua_pushlightuserdata,
	pushlstring = CLIB.lua_pushlstring,
	pushnil = CLIB.lua_pushnil,
	pushnumber = CLIB.lua_pushnumber,
	pushstring = CLIB.lua_pushstring,
	pushthread = CLIB.lua_pushthread,
	pushvalue = CLIB.lua_pushvalue,
	pushvfstring = CLIB.lua_pushvfstring,
	rawequal = CLIB.lua_rawequal,
	rawget = CLIB.lua_rawget,
	rawgeti = CLIB.lua_rawgeti,
	rawset = CLIB.lua_rawset,
	rawseti = CLIB.lua_rawseti,
	remove = CLIB.lua_remove,
	replace = CLIB.lua_replace,
	resume = CLIB.lua_resume,
	setallocf = CLIB.lua_setallocf,
	setfenv = CLIB.lua_setfenv,
	setfield = CLIB.lua_setfield,
	sethook = CLIB.lua_sethook,
	setlevel = CLIB.lua_setlevel,
	setlocal = CLIB.lua_setlocal,
	setmetatable = CLIB.lua_setmetatable,
	settable = CLIB.lua_settable,
	settop = CLIB.lua_settop,
	setupvalue = CLIB.lua_setupvalue,
	status = CLIB.lua_status,
	toboolean = CLIB.lua_toboolean,
	tocfunction = CLIB.lua_tocfunction,
	tointeger = CLIB.lua_tointeger,
	tointegerx = CLIB.lua_tointegerx,
	tolstring = CLIB.lua_tolstring,
	tonumber = CLIB.lua_tonumber,
	tonumberx = CLIB.lua_tonumberx,
	topointer = CLIB.lua_topointer,
	tothread = CLIB.lua_tothread,
	touserdata = CLIB.lua_touserdata,
	type = CLIB.lua_type,
	typename = CLIB.lua_typename,
	upvalueid = CLIB.lua_upvalueid,
	upvaluejoin = CLIB.lua_upvaluejoin,
	version = CLIB.lua_version,
	xmove = CLIB.lua_xmove,
	yield = CLIB.lua_yield,
}
library.L = {
	addlstring = CLIB.luaL_addlstring,
	addstring = CLIB.luaL_addstring,
	addvalue = CLIB.luaL_addvalue,
	argerror = CLIB.luaL_argerror,
	buffinit = CLIB.luaL_buffinit,
	callmeta = CLIB.luaL_callmeta,
	checkany = CLIB.luaL_checkany,
	checkinteger = CLIB.luaL_checkinteger,
	checklstring = CLIB.luaL_checklstring,
	checknumber = CLIB.luaL_checknumber,
	checkoption = CLIB.luaL_checkoption,
	checkstack = CLIB.luaL_checkstack,
	checktype = CLIB.luaL_checktype,
	checkudata = CLIB.luaL_checkudata,
	error = CLIB.luaL_error,
	execresult = CLIB.luaL_execresult,
	fileresult = CLIB.luaL_fileresult,
	findtable = CLIB.luaL_findtable,
	getmetafield = CLIB.luaL_getmetafield,
	gsub = CLIB.luaL_gsub,
	loadbuffer = CLIB.luaL_loadbuffer,
	loadbufferx = CLIB.luaL_loadbufferx,
	loadfile = CLIB.luaL_loadfile,
	loadfilex = CLIB.luaL_loadfilex,
	loadstring = CLIB.luaL_loadstring,
	newmetatable = CLIB.luaL_newmetatable,
	newstate = CLIB.luaL_newstate,
	openlib = CLIB.luaL_openlib,
	openlibs = CLIB.luaL_openlibs,
	optinteger = CLIB.luaL_optinteger,
	optlstring = CLIB.luaL_optlstring,
	optnumber = CLIB.luaL_optnumber,
	prepbuffer = CLIB.luaL_prepbuffer,
	pushmodule = CLIB.luaL_pushmodule,
	pushresult = CLIB.luaL_pushresult,
	ref = CLIB.luaL_ref,
	register = CLIB.luaL_register,
	setfuncs = CLIB.luaL_setfuncs,
	setmetatable = CLIB.luaL_setmetatable,
	testudata = CLIB.luaL_testudata,
	traceback = CLIB.luaL_traceback,
	typerror = CLIB.luaL_typerror,
	unref = CLIB.luaL_unref,
	where = CLIB.luaL_where,
}
library.e = {
	VERSION = "Lua 5.1",
	RELEASE = "Lua 5.1.4",
	VERSION_NUM = 501,
	COPYRIGHT = "Copyright C 1994-2008 Lua.org , PUC-Rio",
	AUTHORS = "R. Ierusalimschy , L. H. de Figueiredo & W. Celes",
	SIGNATURE = "\033Lua",
	MULTRET = -1,
	REGISTRYINDEX = -10000,
	ENVIRONINDEX = -10001,
	GLOBALSINDEX = -10002,
	OK = 0,
	YIELD = 1,
	ERRRUN = 2,
	ERRSYNTAX = 3,
	ERRMEM = 4,
	ERRERR = 5,
	TNONE = -1,
	TNIL = 0,
	TBOOLEAN = 1,
	TLIGHTUSERDATA = 2,
	TNUMBER = 3,
	TSTRING = 4,
	TTABLE = 5,
	TFUNCTION = 6,
	TUSERDATA = 7,
	TTHREAD = 8,
	MINSTACK = 20,
	GCSTOP = 0,
	GCRESTART = 1,
	GCCOLLECT = 2,
	GCCOUNT = 3,
	GCCOUNTB = 4,
	GCSTEP = 5,
	GCSETPAUSE = 6,
	GCSETSTEPMUL = 7,
	GCISRUNNING = 9,
	HOOKCALL = 0,
	HOOKRET = 1,
	HOOKLINE = 2,
	HOOKCOUNT = 3,
	HOOKTAILRET = 4,
	MASKCALL = 1,
	MASKRET = 2,
	MASKLINE = 4,
	MASKCOUNT = 8,
}
return library
