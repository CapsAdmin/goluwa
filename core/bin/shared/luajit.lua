local ffi = require("ffi");local CLIB = ffi.C;ffi.cdef([[struct lua_State {};
struct lua_Debug {int event;const char*name;const char*namewhat;const char*what;const char*source;int currentline;int nups;int linedefined;int lastlinedefined;char short_src[60];int i_ci;};
struct luaL_Reg {const char*name;int(*func)(struct lua_State*);};
struct luaL_Buffer {char*p;int lvl;struct lua_State*L;};
int(lua_toboolean)(struct lua_State*,int);
void(lua_pushcclosure)(struct lua_State*,int(*fn)(struct lua_State*),int);
struct lua_State*(lua_newthread)(struct lua_State*);
int(lua_yield)(struct lua_State*,int);
unsigned long(lua_objlen)(struct lua_State*,int);
int(lua_gc)(struct lua_State*,int,int);
void(lua_insert)(struct lua_State*,int);
void(lua_settop)(struct lua_State*,int);
const char*(lua_typename)(struct lua_State*,int);
struct lua_State*(lua_newstate)(void*(*f)(void*,void*,unsigned long,unsigned long),void*);
int(lua_gettop)(struct lua_State*);
int(lua_iscfunction)(struct lua_State*,int);
const char*(lua_tolstring)(struct lua_State*,int,unsigned long*);
void(lua_getfield)(struct lua_State*,int,const char*);
int(lua_lessthan)(struct lua_State*,int,int);
int(lua_isuserdata)(struct lua_State*,int);
int(lua_equal)(struct lua_State*,int,int);
void(lua_pushinteger)(struct lua_State*,long);
void(lua_pushstring)(struct lua_State*,const char*);
void(lua_pushlightuserdata)(struct lua_State*,void*);
int(lua_gethookcount)(struct lua_State*);
struct lua_State*(lua_tothread)(struct lua_State*,int);
const char*(lua_setupvalue)(struct lua_State*,int,int);
int(lua_isstring)(struct lua_State*,int);
int(lua_pushthread)(struct lua_State*);
void(lua_setlevel)(struct lua_State*,struct lua_State*);
int(lua_pcall)(struct lua_State*,int,int,int);
void(lua_setallocf)(struct lua_State*,void*(*f)(void*,void*,unsigned long,unsigned long),void*);
void(lua_settable)(struct lua_State*,int);
int(lua_setfenv)(struct lua_State*,int);
void(lua_gettable)(struct lua_State*,int);
double(lua_tonumber)(struct lua_State*,int);
const char*(lua_getupvalue)(struct lua_State*,int,int);
void(luaL_buffinit)(struct lua_State*,struct luaL_Buffer*);
double(luaL_optnumber)(struct lua_State*,int,double);
int(luaL_loadbuffer)(struct lua_State*,const char*,unsigned long,const char*);
void(luaL_unref)(struct lua_State*,int,int);
int(luaL_execresult)(struct lua_State*,int);
void(luaL_pushresult)(struct luaL_Buffer*);
double(luaL_checknumber)(struct lua_State*,int);
void(luaL_addstring)(struct luaL_Buffer*,const char*);
const char*(luaL_gsub)(struct lua_State*,const char*,const char*,const char*);
void(luaL_checktype)(struct lua_State*,int,int);
char*(luaL_prepbuffer)(struct luaL_Buffer*);
void(luaL_setmetatable)(struct lua_State*,const char*);
void(luaL_traceback)(struct lua_State*,struct lua_State*,const char*,int);
long(luaL_optinteger)(struct lua_State*,int,long);
void(luaL_pushmodule)(struct lua_State*,const char*,int);
void*(luaL_testudata)(struct lua_State*,int,const char*);
long(luaL_checkinteger)(struct lua_State*,int);
int(luaL_loadfilex)(struct lua_State*,const char*,const char*);
int(luaL_loadstring)(struct lua_State*,const char*);
int(luaL_ref)(struct lua_State*,int);
int(luaL_error)(struct lua_State*,const char*,...);
void(luaL_where)(struct lua_State*,int);
struct lua_State*(luaL_newstate)();
const char*(luaL_findtable)(struct lua_State*,int,const char*,int);
void(luaL_checkany)(struct lua_State*,int);
void(luaL_addlstring)(struct luaL_Buffer*,const char*,unsigned long);
void(luaL_checkstack)(struct lua_State*,int,const char*);
int(lua_isnumber)(struct lua_State*,int);
int(luaL_loadbufferx)(struct lua_State*,const char*,unsigned long,const char*,const char*);
void(luaL_register)(struct lua_State*,const char*,const struct luaL_Reg*);
const char*(luaL_optlstring)(struct lua_State*,int,const char*,unsigned long*);
int(luaL_checkoption)(struct lua_State*,int,const char*,const char*const lst);
int(luaL_typerror)(struct lua_State*,int,const char*);
int(luaL_argerror)(struct lua_State*,int,const char*);
int(luaL_callmeta)(struct lua_State*,int,const char*);
const char*(luaL_checklstring)(struct lua_State*,int,unsigned long*);
int(luaL_getmetafield)(struct lua_State*,int,const char*);
int(luaL_loadfile)(struct lua_State*,const char*);
void(lua_call)(struct lua_State*,int,int);
void*(luaL_checkudata)(struct lua_State*,int,const char*);
void(luaL_openlibs)(struct lua_State*);
void(lua_pushnil)(struct lua_State*);
void(luaL_setfuncs)(struct lua_State*,const struct luaL_Reg*,int);
void(luaL_addvalue)(struct luaL_Buffer*);
void(luaL_openlib)(struct lua_State*,const char*,const struct luaL_Reg*,int);
void(lua_createtable)(struct lua_State*,int,int);
int(luaL_newmetatable)(struct lua_State*,const char*);
int(luaL_fileresult)(struct lua_State*,int,const char*);
void*(lua_newuserdata)(struct lua_State*,unsigned long);
int(luaopen_math)(struct lua_State*);
const double*(lua_version)(struct lua_State*);
int(lua_getinfo)(struct lua_State*,const char*,struct lua_Debug*);
int(luaopen_debug)(struct lua_State*);
int(luaopen_table)(struct lua_State*);
int(luaopen_jit)(struct lua_State*);
int(luaopen_package)(struct lua_State*);
int(luaopen_string_buffer)(struct lua_State*);
long(lua_tointeger)(struct lua_State*,int);
int(luaopen_bit)(struct lua_State*);
void(lua_rawget)(struct lua_State*,int);
int(luaopen_io)(struct lua_State*);
int(luaopen_string)(struct lua_State*);
int(luaopen_os)(struct lua_State*);
void(lua_rawseti)(struct lua_State*,int,int);
int(luaopen_base)(struct lua_State*);
int(lua_getmetatable)(struct lua_State*,int);
int(lua_type)(struct lua_State*,int);
int(lua_rawequal)(struct lua_State*,int,int);
int(lua_loadx)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*,const char*);
void(lua_setfield)(struct lua_State*,int,const char*);
void(lua_xmove)(struct lua_State*,struct lua_State*,int);
int(*lua_tocfunction(struct lua_State*,int))(struct lua_State*);
void*(*lua_getallocf(struct lua_State*,void**))(void*,void*,unsigned long,unsigned long);
void*(lua_touserdata)(struct lua_State*,int);
int(lua_cpcall)(struct lua_State*,int(*func)(struct lua_State*),void*);
int(lua_status)(struct lua_State*);
int(lua_dump)(struct lua_State*,int(*writer)(struct lua_State*,const void*,unsigned long,void*),void*);
void(lua_pushboolean)(struct lua_State*,int);
void(lua_replace)(struct lua_State*,int);
const void*(lua_topointer)(struct lua_State*,int);
const char*(lua_pushfstring)(struct lua_State*,const char*,...);
const char*(lua_getlocal)(struct lua_State*,const struct lua_Debug*,int);
void(*lua_gethook(struct lua_State*))(struct lua_State*,struct lua_Debug*);
void(lua_remove)(struct lua_State*,int);
int(lua_sethook)(struct lua_State*,void(*func)(struct lua_State*,struct lua_Debug*),int,int);
int(lua_gethookmask)(struct lua_State*);
void(lua_concat)(struct lua_State*,int);
int(lua_getstack)(struct lua_State*,int,struct lua_Debug*);
void(lua_pushnumber)(struct lua_State*,double);
void(lua_pushvalue)(struct lua_State*,int);
int(lua_resume)(struct lua_State*,int);
void(lua_pushlstring)(struct lua_State*,const char*,unsigned long);
void(lua_close)(struct lua_State*);
int(lua_checkstack)(struct lua_State*,int);
int(lua_error)(struct lua_State*);
void(lua_getfenv)(struct lua_State*,int);
int(lua_isyieldable)(struct lua_State*);
int(lua_load)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*);
void(lua_rawgeti)(struct lua_State*,int,int);
long(lua_tointegerx)(struct lua_State*,int,int*);
void*(lua_upvalueid)(struct lua_State*,int,int);
int(luaopen_ffi)(struct lua_State*);
int(*lua_atpanic(struct lua_State*,int(*panicf)(struct lua_State*)))(struct lua_State*);
const char*(lua_setlocal)(struct lua_State*,const struct lua_Debug*,int);
int(lua_next)(struct lua_State*,int);
int(lua_setmetatable)(struct lua_State*,int);
void(lua_upvaluejoin)(struct lua_State*,int,int,int,int);
double(lua_tonumberx)(struct lua_State*,int,int*);
void(lua_copy)(struct lua_State*,int,int);
const char*(lua_pushvfstring)(struct lua_State*,const char*,__builtin_va_list);
void(lua_rawset)(struct lua_State*,int);
]])
local library = {}


--====helper safe_clib_index====
		function SAFE_INDEX(clib)
			return setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return clib[k] end)
				if ok then
					return val
				elseif clib_index then
					return clib_index(k)
				end
			end})
		end
	
--====helper safe_clib_index====

CLIB = SAFE_INDEX(CLIB)library = {
	toboolean = CLIB.lua_toboolean,
	pushcclosure = CLIB.lua_pushcclosure,
	newthread = CLIB.lua_newthread,
	yield = CLIB.lua_yield,
	objlen = CLIB.lua_objlen,
	gc = CLIB.lua_gc,
	insert = CLIB.lua_insert,
	settop = CLIB.lua_settop,
	typename = CLIB.lua_typename,
	newstate = CLIB.lua_newstate,
	gettop = CLIB.lua_gettop,
	iscfunction = CLIB.lua_iscfunction,
	tolstring = CLIB.lua_tolstring,
	getfield = CLIB.lua_getfield,
	lessthan = CLIB.lua_lessthan,
	isuserdata = CLIB.lua_isuserdata,
	equal = CLIB.lua_equal,
	pushinteger = CLIB.lua_pushinteger,
	pushstring = CLIB.lua_pushstring,
	pushlightuserdata = CLIB.lua_pushlightuserdata,
	gethookcount = CLIB.lua_gethookcount,
	tothread = CLIB.lua_tothread,
	setupvalue = CLIB.lua_setupvalue,
	isstring = CLIB.lua_isstring,
	pushthread = CLIB.lua_pushthread,
	setlevel = CLIB.lua_setlevel,
	pcall = CLIB.lua_pcall,
	setallocf = CLIB.lua_setallocf,
	settable = CLIB.lua_settable,
	setfenv = CLIB.lua_setfenv,
	gettable = CLIB.lua_gettable,
	tonumber = CLIB.lua_tonumber,
	getupvalue = CLIB.lua_getupvalue,
	isnumber = CLIB.lua_isnumber,
	call = CLIB.lua_call,
	pushnil = CLIB.lua_pushnil,
	createtable = CLIB.lua_createtable,
	newuserdata = CLIB.lua_newuserdata,
	version = CLIB.lua_version,
	getinfo = CLIB.lua_getinfo,
	tointeger = CLIB.lua_tointeger,
	rawget = CLIB.lua_rawget,
	rawseti = CLIB.lua_rawseti,
	getmetatable = CLIB.lua_getmetatable,
	type = CLIB.lua_type,
	rawequal = CLIB.lua_rawequal,
	loadx = CLIB.lua_loadx,
	setfield = CLIB.lua_setfield,
	xmove = CLIB.lua_xmove,
	tocfunction = CLIB.lua_tocfunction,
	getallocf = CLIB.lua_getallocf,
	touserdata = CLIB.lua_touserdata,
	cpcall = CLIB.lua_cpcall,
	status = CLIB.lua_status,
	dump = CLIB.lua_dump,
	pushboolean = CLIB.lua_pushboolean,
	replace = CLIB.lua_replace,
	topointer = CLIB.lua_topointer,
	pushfstring = CLIB.lua_pushfstring,
	getlocal = CLIB.lua_getlocal,
	gethook = CLIB.lua_gethook,
	remove = CLIB.lua_remove,
	sethook = CLIB.lua_sethook,
	gethookmask = CLIB.lua_gethookmask,
	concat = CLIB.lua_concat,
	getstack = CLIB.lua_getstack,
	pushnumber = CLIB.lua_pushnumber,
	pushvalue = CLIB.lua_pushvalue,
	resume = CLIB.lua_resume,
	pushlstring = CLIB.lua_pushlstring,
	close = CLIB.lua_close,
	checkstack = CLIB.lua_checkstack,
	error = CLIB.lua_error,
	getfenv = CLIB.lua_getfenv,
	isyieldable = CLIB.lua_isyieldable,
	load = CLIB.lua_load,
	rawgeti = CLIB.lua_rawgeti,
	tointegerx = CLIB.lua_tointegerx,
	upvalueid = CLIB.lua_upvalueid,
	atpanic = CLIB.lua_atpanic,
	setlocal = CLIB.lua_setlocal,
	next = CLIB.lua_next,
	setmetatable = CLIB.lua_setmetatable,
	upvaluejoin = CLIB.lua_upvaluejoin,
	tonumberx = CLIB.lua_tonumberx,
	copy = CLIB.lua_copy,
	pushvfstring = CLIB.lua_pushvfstring,
	rawset = CLIB.lua_rawset,
}
library.L = {
	buffinit = CLIB.luaL_buffinit,
	optnumber = CLIB.luaL_optnumber,
	loadbuffer = CLIB.luaL_loadbuffer,
	unref = CLIB.luaL_unref,
	execresult = CLIB.luaL_execresult,
	pushresult = CLIB.luaL_pushresult,
	checknumber = CLIB.luaL_checknumber,
	addstring = CLIB.luaL_addstring,
	gsub = CLIB.luaL_gsub,
	checktype = CLIB.luaL_checktype,
	prepbuffer = CLIB.luaL_prepbuffer,
	setmetatable = CLIB.luaL_setmetatable,
	traceback = CLIB.luaL_traceback,
	optinteger = CLIB.luaL_optinteger,
	pushmodule = CLIB.luaL_pushmodule,
	testudata = CLIB.luaL_testudata,
	checkinteger = CLIB.luaL_checkinteger,
	loadfilex = CLIB.luaL_loadfilex,
	loadstring = CLIB.luaL_loadstring,
	ref = CLIB.luaL_ref,
	error = CLIB.luaL_error,
	where = CLIB.luaL_where,
	newstate = CLIB.luaL_newstate,
	findtable = CLIB.luaL_findtable,
	checkany = CLIB.luaL_checkany,
	addlstring = CLIB.luaL_addlstring,
	checkstack = CLIB.luaL_checkstack,
	loadbufferx = CLIB.luaL_loadbufferx,
	register = CLIB.luaL_register,
	optlstring = CLIB.luaL_optlstring,
	checkoption = CLIB.luaL_checkoption,
	typerror = CLIB.luaL_typerror,
	argerror = CLIB.luaL_argerror,
	callmeta = CLIB.luaL_callmeta,
	checklstring = CLIB.luaL_checklstring,
	getmetafield = CLIB.luaL_getmetafield,
	loadfile = CLIB.luaL_loadfile,
	checkudata = CLIB.luaL_checkudata,
	openlibs = CLIB.luaL_openlibs,
	setfuncs = CLIB.luaL_setfuncs,
	addvalue = CLIB.luaL_addvalue,
	openlib = CLIB.luaL_openlib,
	newmetatable = CLIB.luaL_newmetatable,
	fileresult = CLIB.luaL_fileresult,
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
library.clib = CLIB
return library
