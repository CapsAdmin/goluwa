local ffi = require("ffi");local CLIB = ffi.C;ffi.cdef([[struct lua_State {};
struct lua_Debug {int event;const char*name;const char*namewhat;const char*what;const char*source;int currentline;int nups;int linedefined;int lastlinedefined;char short_src[60];int i_ci;};
struct luaL_Reg {const char*name;int(*func)(struct lua_State*);};
struct luaL_Buffer {char*p;int lvl;struct lua_State*L;};
void(lua_setfield)(struct lua_State*,int,const char*);
double(luaL_optnumber)(struct lua_State*,int,double);
void(lua_xmove)(struct lua_State*,struct lua_State*,int);
void*(*lua_getallocf(struct lua_State*,void**))(void*,void*,unsigned long,unsigned long);
int(lua_cpcall)(struct lua_State*,int(*func)(struct lua_State*),void*);
int(lua_status)(struct lua_State*);
void(lua_pushboolean)(struct lua_State*,int);
int(luaL_loadbuffer)(struct lua_State*,const char*,unsigned long,const char*);
void(lua_replace)(struct lua_State*,int);
const char*(lua_pushfstring)(struct lua_State*,const char*,...);
const char*(lua_getlocal)(struct lua_State*,const struct lua_Debug*,int);
int(lua_gettop)(struct lua_State*);
void(lua_remove)(struct lua_State*,int);
void(luaL_unref)(struct lua_State*,int,int);
int(lua_sethook)(struct lua_State*,void(*func)(struct lua_State*,struct lua_Debug*),int,int);
int(luaL_execresult)(struct lua_State*,int);
int(lua_gethookmask)(struct lua_State*);
int(lua_getstack)(struct lua_State*,int,struct lua_Debug*);
void(lua_pushnumber)(struct lua_State*,double);
double(luaL_checknumber)(struct lua_State*,int);
void(lua_pushvalue)(struct lua_State*,int);
int(lua_resume)(struct lua_State*,int);
void(lua_pushlstring)(struct lua_State*,const char*,unsigned long);
const char*(luaL_gsub)(struct lua_State*,const char*,const char*,const char*);
void(lua_close)(struct lua_State*);
int(lua_checkstack)(struct lua_State*,int);
void(luaL_pushresult)(struct luaL_Buffer*);
void(luaL_addstring)(struct luaL_Buffer*,const char*);
void(luaL_where)(struct lua_State*,int);
long(luaL_optinteger)(struct lua_State*,int,long);
int(luaopen_debug)(struct lua_State*);
int(lua_dump)(struct lua_State*,int(*writer)(struct lua_State*,const void*,unsigned long,void*),void*);
int(luaopen_table)(struct lua_State*);
int(*lua_tocfunction(struct lua_State*,int))(struct lua_State*);
char*(luaL_prepbuffer)(struct luaL_Buffer*);
void(luaL_buffinit)(struct lua_State*,struct luaL_Buffer*);
void*(luaL_testudata)(struct lua_State*,int,const char*);
long(lua_tointegerx)(struct lua_State*,int,int*);
int(lua_type)(struct lua_State*,int);
void(lua_setallocf)(struct lua_State*,void*(*f)(void*,void*,unsigned long,unsigned long),void*);
void(luaL_setmetatable)(struct lua_State*,const char*);
void(lua_rawseti)(struct lua_State*,int,int);
const char*(lua_setlocal)(struct lua_State*,const struct lua_Debug*,int);
void(luaL_pushmodule)(struct lua_State*,const char*,int);
void(luaL_traceback)(struct lua_State*,struct lua_State*,const char*,int);
double(lua_tonumberx)(struct lua_State*,int,int*);
int(lua_next)(struct lua_State*,int);
int(luaL_loadfilex)(struct lua_State*,const char*,const char*);
const char*(luaL_findtable)(struct lua_State*,int,const char*,int);
const void*(lua_topointer)(struct lua_State*,int);
int(luaL_ref)(struct lua_State*,int);
int(luaL_loadstring)(struct lua_State*,const char*);
int(luaL_typerror)(struct lua_State*,int,const char*);
struct lua_State*(luaL_newstate)();
void(lua_call)(struct lua_State*,int,int);
void(lua_rawset)(struct lua_State*,int);
void(lua_pushcclosure)(struct lua_State*,int(*fn)(struct lua_State*),int);
int(lua_loadx)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*,const char*);
int(luaL_error)(struct lua_State*,const char*,...);
void(luaL_addlstring)(struct luaL_Buffer*,const char*,unsigned long);
int(luaopen_ffi)(struct lua_State*);
int(luaL_loadbufferx)(struct lua_State*,const char*,unsigned long,const char*,const char*);
unsigned long(lua_objlen)(struct lua_State*,int);
void(luaL_checkany)(struct lua_State*,int);
int(lua_gc)(struct lua_State*,int,int);
int(*lua_atpanic(struct lua_State*,int(*panicf)(struct lua_State*)))(struct lua_State*);
void(luaL_checktype)(struct lua_State*,int,int);
void(luaL_checkstack)(struct lua_State*,int,const char*);
int(luaL_argerror)(struct lua_State*,int,const char*);
const char*(lua_typename)(struct lua_State*,int);
long(luaL_checkinteger)(struct lua_State*,int);
const char*(luaL_optlstring)(struct lua_State*,int,const char*,unsigned long*);
const char*(luaL_checklstring)(struct lua_State*,int,unsigned long*);
int(luaL_loadfile)(struct lua_State*,const char*);
int(luaL_callmeta)(struct lua_State*,int,const char*);
int(luaL_getmetafield)(struct lua_State*,int,const char*);
void(luaL_register)(struct lua_State*,const char*,const struct luaL_Reg*);
void*(lua_newuserdata)(struct lua_State*,unsigned long);
const char*(lua_tolstring)(struct lua_State*,int,unsigned long*);
int(lua_lessthan)(struct lua_State*,int,int);
int(lua_equal)(struct lua_State*,int,int);
void(lua_insert)(struct lua_State*,int);
int(lua_error)(struct lua_State*);
void(lua_getfenv)(struct lua_State*,int);
int(lua_isyieldable)(struct lua_State*);
int(luaopen_package)(struct lua_State*);
int(lua_isuserdata)(struct lua_State*,int);
int(lua_rawequal)(struct lua_State*,int,int);
const char*(lua_getupvalue)(struct lua_State*,int,int);
void*(luaL_checkudata)(struct lua_State*,int,const char*);
void(lua_rawget)(struct lua_State*,int);
void(lua_pushnil)(struct lua_State*);
int(lua_isnumber)(struct lua_State*,int);
void(luaL_openlibs)(struct lua_State*);
const char*(lua_pushvfstring)(struct lua_State*,const char*,__builtin_va_list);
int(lua_toboolean)(struct lua_State*,int);
void(lua_concat)(struct lua_State*,int);
struct lua_State*(lua_newthread)(struct lua_State*);
void(luaL_setfuncs)(struct lua_State*,const struct luaL_Reg*,int);
int(lua_yield)(struct lua_State*,int);
int(luaopen_string)(struct lua_State*);
void*(lua_upvalueid)(struct lua_State*,int,int);
void*(lua_touserdata)(struct lua_State*,int);
void(luaL_addvalue)(struct luaL_Buffer*);
void(lua_settop)(struct lua_State*,int);
int(luaopen_jit)(struct lua_State*);
long(lua_tointeger)(struct lua_State*,int);
struct lua_State*(lua_newstate)(void*(*f)(void*,void*,unsigned long,unsigned long),void*);
int(lua_getinfo)(struct lua_State*,const char*,struct lua_Debug*);
int(lua_setmetatable)(struct lua_State*,int);
int(lua_iscfunction)(struct lua_State*,int);
void(luaL_openlib)(struct lua_State*,const char*,const struct luaL_Reg*,int);
int(lua_getmetatable)(struct lua_State*,int);
int(luaopen_math)(struct lua_State*);
int(luaopen_bit)(struct lua_State*);
void(lua_pushstring)(struct lua_State*,const char*);
void(lua_upvaluejoin)(struct lua_State*,int,int,int,int);
void(lua_pushinteger)(struct lua_State*,long);
struct lua_State*(lua_tothread)(struct lua_State*,int);
void(lua_pushlightuserdata)(struct lua_State*,void*);
int(lua_gethookcount)(struct lua_State*);
int(lua_pushthread)(struct lua_State*);
const char*(lua_setupvalue)(struct lua_State*,int,int);
void(lua_rawgeti)(struct lua_State*,int,int);
int(lua_isstring)(struct lua_State*,int);
void(lua_createtable)(struct lua_State*,int,int);
int(luaL_newmetatable)(struct lua_State*,const char*);
int(luaL_fileresult)(struct lua_State*,int,const char*);
void(lua_setlevel)(struct lua_State*,struct lua_State*);
int(lua_pcall)(struct lua_State*,int,int,int);
void(*lua_gethook(struct lua_State*))(struct lua_State*,struct lua_Debug*);
int(luaL_checkoption)(struct lua_State*,int,const char*,const char*const lst);
void(lua_copy)(struct lua_State*,int,int);
int(luaopen_io)(struct lua_State*);
int(luaopen_base)(struct lua_State*);
int(lua_load)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*);
int(luaopen_os)(struct lua_State*);
void(lua_settable)(struct lua_State*,int);
int(lua_setfenv)(struct lua_State*,int);
void(lua_getfield)(struct lua_State*,int,const char*);
void(lua_gettable)(struct lua_State*,int);
const double*(lua_version)(struct lua_State*);
double(lua_tonumber)(struct lua_State*,int);
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
	setfield = CLIB.lua_setfield,
	xmove = CLIB.lua_xmove,
	getallocf = CLIB.lua_getallocf,
	cpcall = CLIB.lua_cpcall,
	status = CLIB.lua_status,
	pushboolean = CLIB.lua_pushboolean,
	replace = CLIB.lua_replace,
	pushfstring = CLIB.lua_pushfstring,
	getlocal = CLIB.lua_getlocal,
	gettop = CLIB.lua_gettop,
	remove = CLIB.lua_remove,
	sethook = CLIB.lua_sethook,
	gethookmask = CLIB.lua_gethookmask,
	getstack = CLIB.lua_getstack,
	pushnumber = CLIB.lua_pushnumber,
	pushvalue = CLIB.lua_pushvalue,
	resume = CLIB.lua_resume,
	pushlstring = CLIB.lua_pushlstring,
	close = CLIB.lua_close,
	checkstack = CLIB.lua_checkstack,
	dump = CLIB.lua_dump,
	tocfunction = CLIB.lua_tocfunction,
	tointegerx = CLIB.lua_tointegerx,
	type = CLIB.lua_type,
	setallocf = CLIB.lua_setallocf,
	rawseti = CLIB.lua_rawseti,
	setlocal = CLIB.lua_setlocal,
	tonumberx = CLIB.lua_tonumberx,
	next = CLIB.lua_next,
	topointer = CLIB.lua_topointer,
	call = CLIB.lua_call,
	rawset = CLIB.lua_rawset,
	pushcclosure = CLIB.lua_pushcclosure,
	loadx = CLIB.lua_loadx,
	objlen = CLIB.lua_objlen,
	gc = CLIB.lua_gc,
	atpanic = CLIB.lua_atpanic,
	typename = CLIB.lua_typename,
	newuserdata = CLIB.lua_newuserdata,
	tolstring = CLIB.lua_tolstring,
	lessthan = CLIB.lua_lessthan,
	equal = CLIB.lua_equal,
	insert = CLIB.lua_insert,
	error = CLIB.lua_error,
	getfenv = CLIB.lua_getfenv,
	isyieldable = CLIB.lua_isyieldable,
	isuserdata = CLIB.lua_isuserdata,
	rawequal = CLIB.lua_rawequal,
	getupvalue = CLIB.lua_getupvalue,
	rawget = CLIB.lua_rawget,
	pushnil = CLIB.lua_pushnil,
	isnumber = CLIB.lua_isnumber,
	pushvfstring = CLIB.lua_pushvfstring,
	toboolean = CLIB.lua_toboolean,
	concat = CLIB.lua_concat,
	newthread = CLIB.lua_newthread,
	yield = CLIB.lua_yield,
	upvalueid = CLIB.lua_upvalueid,
	touserdata = CLIB.lua_touserdata,
	settop = CLIB.lua_settop,
	tointeger = CLIB.lua_tointeger,
	newstate = CLIB.lua_newstate,
	getinfo = CLIB.lua_getinfo,
	setmetatable = CLIB.lua_setmetatable,
	iscfunction = CLIB.lua_iscfunction,
	getmetatable = CLIB.lua_getmetatable,
	pushstring = CLIB.lua_pushstring,
	upvaluejoin = CLIB.lua_upvaluejoin,
	pushinteger = CLIB.lua_pushinteger,
	tothread = CLIB.lua_tothread,
	pushlightuserdata = CLIB.lua_pushlightuserdata,
	gethookcount = CLIB.lua_gethookcount,
	pushthread = CLIB.lua_pushthread,
	setupvalue = CLIB.lua_setupvalue,
	rawgeti = CLIB.lua_rawgeti,
	isstring = CLIB.lua_isstring,
	createtable = CLIB.lua_createtable,
	setlevel = CLIB.lua_setlevel,
	pcall = CLIB.lua_pcall,
	gethook = CLIB.lua_gethook,
	copy = CLIB.lua_copy,
	load = CLIB.lua_load,
	settable = CLIB.lua_settable,
	setfenv = CLIB.lua_setfenv,
	getfield = CLIB.lua_getfield,
	gettable = CLIB.lua_gettable,
	version = CLIB.lua_version,
	tonumber = CLIB.lua_tonumber,
}
library.L = {
	optnumber = CLIB.luaL_optnumber,
	loadbuffer = CLIB.luaL_loadbuffer,
	unref = CLIB.luaL_unref,
	execresult = CLIB.luaL_execresult,
	checknumber = CLIB.luaL_checknumber,
	gsub = CLIB.luaL_gsub,
	pushresult = CLIB.luaL_pushresult,
	addstring = CLIB.luaL_addstring,
	where = CLIB.luaL_where,
	optinteger = CLIB.luaL_optinteger,
	prepbuffer = CLIB.luaL_prepbuffer,
	buffinit = CLIB.luaL_buffinit,
	testudata = CLIB.luaL_testudata,
	setmetatable = CLIB.luaL_setmetatable,
	pushmodule = CLIB.luaL_pushmodule,
	traceback = CLIB.luaL_traceback,
	loadfilex = CLIB.luaL_loadfilex,
	findtable = CLIB.luaL_findtable,
	ref = CLIB.luaL_ref,
	loadstring = CLIB.luaL_loadstring,
	typerror = CLIB.luaL_typerror,
	newstate = CLIB.luaL_newstate,
	error = CLIB.luaL_error,
	addlstring = CLIB.luaL_addlstring,
	loadbufferx = CLIB.luaL_loadbufferx,
	checkany = CLIB.luaL_checkany,
	checktype = CLIB.luaL_checktype,
	checkstack = CLIB.luaL_checkstack,
	argerror = CLIB.luaL_argerror,
	checkinteger = CLIB.luaL_checkinteger,
	optlstring = CLIB.luaL_optlstring,
	checklstring = CLIB.luaL_checklstring,
	loadfile = CLIB.luaL_loadfile,
	callmeta = CLIB.luaL_callmeta,
	getmetafield = CLIB.luaL_getmetafield,
	register = CLIB.luaL_register,
	checkudata = CLIB.luaL_checkudata,
	openlibs = CLIB.luaL_openlibs,
	setfuncs = CLIB.luaL_setfuncs,
	addvalue = CLIB.luaL_addvalue,
	openlib = CLIB.luaL_openlib,
	newmetatable = CLIB.luaL_newmetatable,
	fileresult = CLIB.luaL_fileresult,
	checkoption = CLIB.luaL_checkoption,
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
