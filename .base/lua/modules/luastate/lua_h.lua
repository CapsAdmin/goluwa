--lua.h lauxlib.h lualib.h from Lua 5.1.5 (defines made enums, macros removed)
require'ffi'.cdef[[

enum {
/* option for multiple returns in `lua_pcall' and `lua_call' */
	LUA_MULTRET = (-1),
/* pseudo-indices */
	LUA_REGISTRYINDEX = (-10000),
	LUA_ENVIRONINDEX = (-10001),
	LUA_GLOBALSINDEX = (-10002),
/* thread status; 0 is OK */
	LUA_YIELD = 1,
	LUA_ERRRUN = 2,
	LUA_ERRSYNTAX = 3,
	LUA_ERRMEM = 4,
	LUA_ERRERR = 5,
/* basic types */
	LUA_TNONE = (-1),
	LUA_TNIL = 0,
	LUA_TBOOLEAN = 1,
	LUA_TLIGHTUSERDATA = 2,
	LUA_TNUMBER = 3,
	LUA_TSTRING = 4,
	LUA_TTABLE = 5,
	LUA_TFUNCTION = 6,
	LUA_TUSERDATA = 7,
	LUA_TTHREAD = 8,
/* minimum Lua stack available to a C function */
	LUA_MINSTACK = 20,
/* garbage collection options */
	LUA_GCSTOP = 0,
	LUA_GCRESTART = 1,
	LUA_GCCOLLECT = 2,
	LUA_GCCOUNT = 3,
	LUA_GCCOUNTB = 4,
	LUA_GCSTEP = 5,
	LUA_GCSETPAUSE = 6,
	LUA_GCSETSTEPMUL = 7,
/* Event codes */
	LUA_HOOKCALL = 0,
	LUA_HOOKRET = 1,
	LUA_HOOKLINE = 2,
	LUA_HOOKCOUNT = 3,
	LUA_HOOKTAILRET = 4,
/* Event masks */
	LUA_MASKCALL = (1 << LUA_HOOKCALL),
	LUA_MASKRET = (1 << LUA_HOOKRET),
	LUA_MASKLINE = (1 << LUA_HOOKLINE),
	LUA_MASKCOUNT = (1 << LUA_HOOKCOUNT),
};

typedef struct lua_State lua_State;
typedef int (*lua_CFunction) (lua_State *L);

/* functions that read/write blocks when loading/dumping Lua chunks */
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);
typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);

/* prototype for memory-allocation functions */
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);

/* type of numbers in Lua */
typedef double lua_Number;

/* type for integer functions */
typedef ptrdiff_t lua_Integer;

/* state manipulation */

lua_State *(lua_newstate) (lua_Alloc f, void *ud);
void       (lua_close) (lua_State *L);
lua_State *(lua_newthread) (lua_State *L);
lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);

/* basic stack manipulation */

int   (lua_gettop) (lua_State *L);
void  (lua_settop) (lua_State *L, int idx);
void  (lua_pushvalue) (lua_State *L, int idx);
void  (lua_remove) (lua_State *L, int idx);
void  (lua_insert) (lua_State *L, int idx);
void  (lua_replace) (lua_State *L, int idx);
int   (lua_checkstack) (lua_State *L, int sz);
void  (lua_xmove) (lua_State *from, lua_State *to, int n);

/* access functions (stack -> C) */

int             (lua_isnumber) (lua_State *L, int idx);
int             (lua_isstring) (lua_State *L, int idx);
int             (lua_iscfunction) (lua_State *L, int idx);
int             (lua_isuserdata) (lua_State *L, int idx);
int             (lua_type) (lua_State *L, int idx);
const char     *(lua_typename) (lua_State *L, int tp);

int            (lua_equal) (lua_State *L, int idx1, int idx2);
int            (lua_rawequal) (lua_State *L, int idx1, int idx2);
int            (lua_lessthan) (lua_State *L, int idx1, int idx2);

lua_Number      (lua_tonumber) (lua_State *L, int idx);
lua_Integer     (lua_tointeger) (lua_State *L, int idx);
int             (lua_toboolean) (lua_State *L, int idx);
const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
size_t          (lua_objlen) (lua_State *L, int idx);
lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
void	       *(lua_touserdata) (lua_State *L, int idx);
lua_State      *(lua_tothread) (lua_State *L, int idx);
const void     *(lua_topointer) (lua_State *L, int idx);

/* push functions (C -> stack) */

void  (lua_pushnil) (lua_State *L);
void  (lua_pushnumber) (lua_State *L, lua_Number n);
void  (lua_pushinteger) (lua_State *L, lua_Integer n);
void  (lua_pushlstring) (lua_State *L, const char *s, size_t l);
void  (lua_pushstring) (lua_State *L, const char *s);
const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
void  (lua_pushboolean) (lua_State *L, int b);
void  (lua_pushlightuserdata) (lua_State *L, void *p);
int   (lua_pushthread) (lua_State *L);

/* get functions (Lua -> stack) */

void  (lua_gettable) (lua_State *L, int idx);
void  (lua_getfield) (lua_State *L, int idx, const char *k);
void  (lua_rawget) (lua_State *L, int idx);
void  (lua_rawgeti) (lua_State *L, int idx, int n);
void  (lua_createtable) (lua_State *L, int narr, int nrec);
void *(lua_newuserdata) (lua_State *L, size_t sz);
int   (lua_getmetatable) (lua_State *L, int objindex);
void  (lua_getfenv) (lua_State *L, int idx);

/* set functions (stack -> Lua) */

void  (lua_settable) (lua_State *L, int idx);
void  (lua_setfield) (lua_State *L, int idx, const char *k);
void  (lua_rawset) (lua_State *L, int idx);
void  (lua_rawseti) (lua_State *L, int idx, int n);
int   (lua_setmetatable) (lua_State *L, int objindex);
int   (lua_setfenv) (lua_State *L, int idx);


/* `load' and `call' functions (load and run Lua code) */

void  (lua_call) (lua_State *L, int nargs, int nresults);
int   (lua_pcall) (lua_State *L, int nargs, int nresults, int errfunc);
int   (lua_cpcall) (lua_State *L, lua_CFunction func, void *ud);
int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname);

int (lua_dump) (lua_State *L, lua_Writer writer, void *data);


/*  coroutine functions */

int  (lua_yield) (lua_State *L, int nresults);
int  (lua_resume) (lua_State *L, int narg);
int  (lua_status) (lua_State *L);

/* garbage-collection function */

int (lua_gc) (lua_State *L, int what, int data);

/* miscellaneous functions */

int   (lua_error) (lua_State *L);
int   (lua_next) (lua_State *L, int idx);
void  (lua_concat) (lua_State *L, int n);

lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);

/* hack */
void lua_setlevel	(lua_State *from, lua_State *to);

/* Debug API */

typedef struct lua_Debug lua_Debug;  /* activation record */

/* Functions to be called by the debuger in specific events */
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);

int lua_getstack (lua_State *L, int level, lua_Debug *ar);
int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_getupvalue (lua_State *L, int funcindex, int n);
const char *lua_setupvalue (lua_State *L, int funcindex, int n);

int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
lua_Hook lua_gethook (lua_State *L);
int lua_gethookmask (lua_State *L);
int lua_gethookcount (lua_State *L);

struct lua_Debug {
  int event;
  const char *name;	/* (n) */
  const char *namewhat;	/* (n) `global', `local', `field', `method' */
  const char *what;	/* (S) `Lua', `C', `main', `tail' */
  const char *source;	/* (S) */
  int currentline;	/* (l) */
  int nups;		/* (u) number of upvalues */
  int linedefined;	/* (S) */
  int lastlinedefined;	/* (S) */
  char short_src[60]; /* (S) */
  /* private part */
  int i_ci;  /* active function */
};

/* lauxlib.h ------------------------------------------------------ */


enum {
/* extra error code for `luaL_load' */
	LUA_ERRFILE = (LUA_ERRERR+1),
/* pre-defined references */
	LUA_NOREF = (-2),
	LUA_REFNIL = (-1),
};

typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;

void (luaI_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);
void (luaL_register) (lua_State *L, const char *libname,
                                const luaL_Reg *l);
int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
int (luaL_callmeta) (lua_State *L, int obj, const char *e);
int (luaL_typerror) (lua_State *L, int narg, const char *tname);
int (luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
const char *(luaL_checklstring) (lua_State *L, int numArg,
                                                          size_t *l);
const char *(luaL_optlstring) (lua_State *L, int numArg,
                                          const char *def, size_t *l);
lua_Number (luaL_checknumber) (lua_State *L, int numArg);
lua_Number (luaL_optnumber) (lua_State *L, int nArg, lua_Number def);

lua_Integer (luaL_checkinteger) (lua_State *L, int numArg);
lua_Integer (luaL_optinteger) (lua_State *L, int nArg,
                                          lua_Integer def);

void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
void (luaL_checktype) (lua_State *L, int narg, int t);
void (luaL_checkany) (lua_State *L, int narg);

int   (luaL_newmetatable) (lua_State *L, const char *tname);
void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);

void (luaL_where) (lua_State *L, int lvl);
int (luaL_error) (lua_State *L, const char *fmt, ...);

int (luaL_checkoption) (lua_State *L, int narg, const char *def,
                                   const char *const lst[]);

int (luaL_ref) (lua_State *L, int t);
void (luaL_unref) (lua_State *L, int t, int ref);

int (luaL_loadfile) (lua_State *L, const char *filename);
int (luaL_loadbuffer) (lua_State *L, const char *buff, size_t sz,
                                  const char *name);
int (luaL_loadstring) (lua_State *L, const char *s);

lua_State *(luaL_newstate) (void);

const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

const char *(luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);


/* Generic Buffer manipulation */

typedef struct luaL_Buffer {
  char *p;	/* current position in buffer */
  int lvl;  /* number of strings in the stack (level) */
  lua_State *L;
  char buffer[?];
} luaL_Buffer;

void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
char *(luaL_prepbuffer) (luaL_Buffer *B);
void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
void (luaL_addstring) (luaL_Buffer *B, const char *s);
void (luaL_addvalue) (luaL_Buffer *B);
void (luaL_pushresult) (luaL_Buffer *B);

/* lualib.h -------------------------------------------------------- */

int (luaopen_base) (lua_State *L);
int (luaopen_table) (lua_State *L);
int (luaopen_io) (lua_State *L);
int (luaopen_os) (lua_State *L);
int (luaopen_string) (lua_State *L);
int (luaopen_math) (lua_State *L);
int (luaopen_debug) (lua_State *L);
int (luaopen_package) (lua_State *L);

/* open all previous libraries */
void (luaL_openlibs) (lua_State *L);

]]
