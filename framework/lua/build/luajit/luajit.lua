local ffi = require("ffi")
ffi.cdef([[struct lua_State {};
struct lua_Debug {int event;const char*name;const char*namewhat;const char*what;const char*source;int currentline;int nups;int linedefined;int lastlinedefined;char short_src[60];int i_ci;};
struct luaL_Reg {const char*name;int(*func)(struct lua_State*);};
struct luaL_Buffer {char*p;int lvl;struct lua_State*L;};
void(luaL_buffinit)(struct lua_State*,struct luaL_Buffer*);
void(lua_setfield)(struct lua_State*,int,const char*);
double(luaL_optnumber)(struct lua_State*,int,double);
void(lua_xmove)(struct lua_State*,struct lua_State*,int);
void(luaL_pushresult)(struct luaL_Buffer*);
struct lua_State*(lua_newstate)(void*(*f)(void*,void*,unsigned long,unsigned long),void*);
void(luaL_addstring)(struct luaL_Buffer*,const char*);
int(lua_cpcall)(struct lua_State*,int(*func)(struct lua_State*),void*);
int(lua_status)(struct lua_State*);
void(lua_pushboolean)(struct lua_State*,int);
int(luaL_loadbuffer)(struct lua_State*,const char*,unsigned long,const char*);
void(lua_replace)(struct lua_State*,int);
const char*(lua_pushfstring)(struct lua_State*,const char*,...);
char*(luaL_prepbuffer)(struct luaL_Buffer*);
void(luaL_setmetatable)(struct lua_State*,const char*);
const char*(lua_getlocal)(struct lua_State*,const struct lua_Debug*,int);
void(luaL_checktype)(struct lua_State*,int,int);
void(luaL_pushmodule)(struct lua_State*,const char*,int);
int(lua_gettop)(struct lua_State*);
void(lua_remove)(struct lua_State*,int);
void(luaL_unref)(struct lua_State*,int,int);
int(lua_sethook)(struct lua_State*,void(*func)(struct lua_State*,struct lua_Debug*),int,int);
void(luaL_traceback)(struct lua_State*,struct lua_State*,const char*,int);
struct lua_State*(lua_tothread)(struct lua_State*,int);
int(luaL_loadfilex)(struct lua_State*,const char*,const char*);
int(luaL_ref)(struct lua_State*,int);
void(lua_setallocf)(struct lua_State*,void*(*f)(void*,void*,unsigned long,unsigned long),void*);
int(luaL_callmeta)(struct lua_State*,int,const char*);
int(luaL_execresult)(struct lua_State*,int);
int(lua_gethookmask)(struct lua_State*);
int(luaL_loadstring)(struct lua_State*,const char*);
void(lua_pushnumber)(struct lua_State*,double);
double(luaL_checknumber)(struct lua_State*,int);
void(lua_pushvalue)(struct lua_State*,int);
int(lua_resume)(struct lua_State*,int);
void(lua_pushlstring)(struct lua_State*,const char*,unsigned long);
const char*(luaL_gsub)(struct lua_State*,const char*,const char*,const char*);
void(lua_close)(struct lua_State*);
int(lua_checkstack)(struct lua_State*,int);
int(luaopen_table)(struct lua_State*);
int(luaL_error)(struct lua_State*,const char*,...);
void(luaL_where)(struct lua_State*,int);
long(luaL_optinteger)(struct lua_State*,int,long);
int(luaopen_debug)(struct lua_State*);
int(lua_dump)(struct lua_State*,int(*writer)(struct lua_State*,const void*,unsigned long,void*),void*);
void(*lua_gethook(struct lua_State*))(struct lua_State*,struct lua_Debug*);
void(luaL_checkany)(struct lua_State*,int);
void*(luaL_testudata)(struct lua_State*,int,const char*);
long(lua_tointegerx)(struct lua_State*,int,int*);
int(lua_type)(struct lua_State*,int);
int(lua_setmetatable)(struct lua_State*,int);
void(luaL_checkstack)(struct lua_State*,int,const char*);
void(lua_rawseti)(struct lua_State*,int,int);
const char*(lua_setlocal)(struct lua_State*,const struct lua_Debug*,int);
long(luaL_checkinteger)(struct lua_State*,int);
const char*(luaL_optlstring)(struct lua_State*,int,const char*,unsigned long*);
int(lua_isstring)(struct lua_State*,int);
double(lua_tonumberx)(struct lua_State*,int,int*);
void(lua_setlevel)(struct lua_State*,struct lua_State*);
int(luaL_typerror)(struct lua_State*,int,const char*);
const char*(luaL_findtable)(struct lua_State*,int,const char*,int);
int(luaL_getmetafield)(struct lua_State*,int,const char*);
void(luaL_register)(struct lua_State*,const char*,const struct luaL_Reg*);
void(lua_pushstring)(struct lua_State*,const char*);
struct lua_State*(luaL_newstate)();
void(lua_rawset)(struct lua_State*,int);
void(lua_pushcclosure)(struct lua_State*,int(*fn)(struct lua_State*),int);
int(lua_loadx)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*,const char*);
void(luaL_addlstring)(struct luaL_Buffer*,const char*,unsigned long);
int(luaL_loadbufferx)(struct lua_State*,const char*,unsigned long,const char*,const char*);
unsigned long(lua_objlen)(struct lua_State*,int);
int(lua_gc)(struct lua_State*,int,int);
int(*lua_atpanic(struct lua_State*,int(*panicf)(struct lua_State*)))(struct lua_State*);
int(luaL_argerror)(struct lua_State*,int,const char*);
const char*(lua_typename)(struct lua_State*,int);
int(luaL_loadfile)(struct lua_State*,const char*);
int(luaopen_io)(struct lua_State*);
void(lua_createtable)(struct lua_State*,int,int);
void*(lua_newuserdata)(struct lua_State*,unsigned long);
int(lua_pcall)(struct lua_State*,int,int,int);
int(lua_lessthan)(struct lua_State*,int,int);
int(lua_pushthread)(struct lua_State*);
const void*(lua_topointer)(struct lua_State*,int);
int(lua_error)(struct lua_State*);
int(lua_isyieldable)(struct lua_State*);
int(luaopen_package)(struct lua_State*);
int(lua_rawequal)(struct lua_State*,int,int);
const double*(lua_version)(struct lua_State*);
const char*(lua_getupvalue)(struct lua_State*,int,int);
void*(luaL_checkudata)(struct lua_State*,int,const char*);
void(lua_rawget)(struct lua_State*,int);
void(lua_pushnil)(struct lua_State*);
void(luaL_openlibs)(struct lua_State*);
const char*(lua_pushvfstring)(struct lua_State*,const char*,__builtin_va_list);
void(lua_rawgeti)(struct lua_State*,int,int);
int(lua_toboolean)(struct lua_State*,int);
void(lua_concat)(struct lua_State*,int);
int(lua_getmetatable)(struct lua_State*,int);
struct lua_State*(lua_newthread)(struct lua_State*);
void(luaL_setfuncs)(struct lua_State*,const struct luaL_Reg*,int);
int(lua_yield)(struct lua_State*,int);
void*(lua_upvalueid)(struct lua_State*,int,int);
void*(lua_touserdata)(struct lua_State*,int);
void(luaL_addvalue)(struct luaL_Buffer*);
void(lua_settop)(struct lua_State*,int);
int(luaopen_jit)(struct lua_State*);
void(lua_getfenv)(struct lua_State*,int);
long(lua_tointeger)(struct lua_State*,int);
const char*(lua_tolstring)(struct lua_State*,int,unsigned long*);
void(lua_insert)(struct lua_State*,int);
void(lua_call)(struct lua_State*,int,int);
int(lua_iscfunction)(struct lua_State*,int);
void(luaL_openlib)(struct lua_State*,const char*,const struct luaL_Reg*,int);
int(luaopen_ffi)(struct lua_State*);
const char*(luaL_checklstring)(struct lua_State*,int,unsigned long*);
int(luaopen_bit)(struct lua_State*);
int(lua_isnumber)(struct lua_State*,int);
void(lua_upvaluejoin)(struct lua_State*,int,int,int,int);
void(lua_pushinteger)(struct lua_State*,long);
void(lua_pushlightuserdata)(struct lua_State*,void*);
int(lua_gethookcount)(struct lua_State*);
void(lua_getfield)(struct lua_State*,int,const char*);
void*(*lua_getallocf(struct lua_State*,void**))(void*,void*,unsigned long,unsigned long);
int(lua_next)(struct lua_State*,int);
const char*(lua_setupvalue)(struct lua_State*,int,int);
int(luaL_newmetatable)(struct lua_State*,const char*);
int(luaL_fileresult)(struct lua_State*,int,const char*);
void(lua_copy)(struct lua_State*,int,int);
int(lua_load)(struct lua_State*,const char*(*reader)(struct lua_State*,void*,unsigned long*),void*,const char*);
int(lua_isuserdata)(struct lua_State*,int);
int(*lua_tocfunction(struct lua_State*,int))(struct lua_State*);
int(luaL_checkoption)(struct lua_State*,int,const char*,const char*const lst);
int(luaopen_math)(struct lua_State*);
int(luaopen_base)(struct lua_State*);
int(luaopen_string)(struct lua_State*);
int(luaopen_os)(struct lua_State*);
void(lua_settable)(struct lua_State*,int);
int(lua_setfenv)(struct lua_State*,int);
int(lua_getstack)(struct lua_State*,int,struct lua_Debug*);
void(lua_gettable)(struct lua_State*,int);
int(lua_getinfo)(struct lua_State*,const char*,struct lua_Debug*);
double(lua_tonumber)(struct lua_State*,int);
int(lua_equal)(struct lua_State*,int,int);
]])
local CLIB = ffi.C
local library = {}
library = {
	setfield = CLIB.lua_setfield,
	xmove = CLIB.lua_xmove,
	newstate = CLIB.lua_newstate,
	cpcall = CLIB.lua_cpcall,
	status = CLIB.lua_status,
	pushboolean = CLIB.lua_pushboolean,
	replace = CLIB.lua_replace,
	pushfstring = CLIB.lua_pushfstring,
	getlocal = CLIB.lua_getlocal,
	gettop = CLIB.lua_gettop,
	remove = CLIB.lua_remove,
	sethook = CLIB.lua_sethook,
	tothread = CLIB.lua_tothread,
	setallocf = CLIB.lua_setallocf,
	gethookmask = CLIB.lua_gethookmask,
	pushnumber = CLIB.lua_pushnumber,
	pushvalue = CLIB.lua_pushvalue,
	resume = CLIB.lua_resume,
	pushlstring = CLIB.lua_pushlstring,
	close = CLIB.lua_close,
	checkstack = CLIB.lua_checkstack,
	dump = CLIB.lua_dump,
	gethook = CLIB.lua_gethook,
	tointegerx = CLIB.lua_tointegerx,
	type = CLIB.lua_type,
	setmetatable = CLIB.lua_setmetatable,
	rawseti = CLIB.lua_rawseti,
	setlocal = CLIB.lua_setlocal,
	isstring = CLIB.lua_isstring,
	tonumberx = CLIB.lua_tonumberx,
	--setlevel = CLIB.lua_setlevel,
	pushstring = CLIB.lua_pushstring,
	rawset = CLIB.lua_rawset,
	pushcclosure = CLIB.lua_pushcclosure,
	loadx = CLIB.lua_loadx,
	objlen = CLIB.lua_objlen,
	gc = CLIB.lua_gc,
	atpanic = CLIB.lua_atpanic,
	typename = CLIB.lua_typename,
	createtable = CLIB.lua_createtable,
	newuserdata = CLIB.lua_newuserdata,
	pcall = CLIB.lua_pcall,
	lessthan = CLIB.lua_lessthan,
	pushthread = CLIB.lua_pushthread,
	topointer = CLIB.lua_topointer,
	error = CLIB.lua_error,
	isyieldable = CLIB.lua_isyieldable,
	rawequal = CLIB.lua_rawequal,
	version = CLIB.lua_version,
	getupvalue = CLIB.lua_getupvalue,
	rawget = CLIB.lua_rawget,
	pushnil = CLIB.lua_pushnil,
	pushvfstring = CLIB.lua_pushvfstring,
	rawgeti = CLIB.lua_rawgeti,
	toboolean = CLIB.lua_toboolean,
	concat = CLIB.lua_concat,
	getmetatable = CLIB.lua_getmetatable,
	newthread = CLIB.lua_newthread,
	yield = CLIB.lua_yield,
	upvalueid = CLIB.lua_upvalueid,
	touserdata = CLIB.lua_touserdata,
	settop = CLIB.lua_settop,
	getfenv = CLIB.lua_getfenv,
	tointeger = CLIB.lua_tointeger,
	tolstring = CLIB.lua_tolstring,
	insert = CLIB.lua_insert,
	call = CLIB.lua_call,
	iscfunction = CLIB.lua_iscfunction,
	isnumber = CLIB.lua_isnumber,
	upvaluejoin = CLIB.lua_upvaluejoin,
	pushinteger = CLIB.lua_pushinteger,
	pushlightuserdata = CLIB.lua_pushlightuserdata,
	gethookcount = CLIB.lua_gethookcount,
	getfield = CLIB.lua_getfield,
	getallocf = CLIB.lua_getallocf,
	next = CLIB.lua_next,
	setupvalue = CLIB.lua_setupvalue,
	copy = CLIB.lua_copy,
	load = CLIB.lua_load,
	isuserdata = CLIB.lua_isuserdata,
	tocfunction = CLIB.lua_tocfunction,
	settable = CLIB.lua_settable,
	setfenv = CLIB.lua_setfenv,
	getstack = CLIB.lua_getstack,
	gettable = CLIB.lua_gettable,
	getinfo = CLIB.lua_getinfo,
	tonumber = CLIB.lua_tonumber,
	equal = CLIB.lua_equal,
}
library.L = {
	buffinit = CLIB.luaL_buffinit,
	optnumber = CLIB.luaL_optnumber,
	pushresult = CLIB.luaL_pushresult,
	addstring = CLIB.luaL_addstring,
	loadbuffer = CLIB.luaL_loadbuffer,
	prepbuffer = CLIB.luaL_prepbuffer,
	setmetatable = CLIB.luaL_setmetatable,
	checktype = CLIB.luaL_checktype,
	pushmodule = CLIB.luaL_pushmodule,
	unref = CLIB.luaL_unref,
	traceback = CLIB.luaL_traceback,
	loadfilex = CLIB.luaL_loadfilex,
	ref = CLIB.luaL_ref,
	callmeta = CLIB.luaL_callmeta,
	execresult = CLIB.luaL_execresult,
	loadstring = CLIB.luaL_loadstring,
	checknumber = CLIB.luaL_checknumber,
	gsub = CLIB.luaL_gsub,
	error = CLIB.luaL_error,
	where = CLIB.luaL_where,
	optinteger = CLIB.luaL_optinteger,
	checkany = CLIB.luaL_checkany,
	testudata = CLIB.luaL_testudata,
	checkstack = CLIB.luaL_checkstack,
	checkinteger = CLIB.luaL_checkinteger,
	optlstring = CLIB.luaL_optlstring,
	typerror = CLIB.luaL_typerror,
	findtable = CLIB.luaL_findtable,
	getmetafield = CLIB.luaL_getmetafield,
	register = CLIB.luaL_register,
	newstate = CLIB.luaL_newstate,
	addlstring = CLIB.luaL_addlstring,
	loadbufferx = CLIB.luaL_loadbufferx,
	argerror = CLIB.luaL_argerror,
	loadfile = CLIB.luaL_loadfile,
	checkudata = CLIB.luaL_checkudata,
	openlibs = CLIB.luaL_openlibs,
	setfuncs = CLIB.luaL_setfuncs,
	addvalue = CLIB.luaL_addvalue,
	openlib = CLIB.luaL_openlib,
	checklstring = CLIB.luaL_checklstring,
	newmetatable = CLIB.luaL_newmetatable,
	fileresult = CLIB.luaL_fileresult,
	checkoption = CLIB.luaL_checkoption,
}
library.e = {
}
library.clib = CLIB
return library
