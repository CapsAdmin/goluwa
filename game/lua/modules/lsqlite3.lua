
local ffi = require "ffi"
local bit = require "bit"

ffi.cdef[[
	typedef struct sqlite3 sqlite3;
	typedef long long int sqlite_int64;
	typedef unsigned long long int sqlite_uint64;
	typedef sqlite_int64 sqlite3_int64;
	typedef sqlite_uint64 sqlite3_uint64;
	typedef int (*sqlite3_callback)(void*,int,char**, char**);
	typedef struct sqlite3_file sqlite3_file;
	typedef struct sqlite3_io_methods sqlite3_io_methods;
	typedef struct sqlite3_mutex sqlite3_mutex;
	typedef struct sqlite3_vfs sqlite3_vfs;
	typedef void (*sqlite3_syscall_ptr)(void);
	typedef struct sqlite3_mem_methods sqlite3_mem_methods;
	typedef struct sqlite3_stmt sqlite3_stmt;
	typedef struct Mem sqlite3_value;
	typedef struct sqlite3_context sqlite3_context;
	typedef void (*sqlite3_destructor_type)(void*);
	typedef struct sqlite3_vtab sqlite3_vtab;
	typedef struct sqlite3_index_info sqlite3_index_info;
	typedef struct sqlite3_vtab_cursor sqlite3_vtab_cursor;
	typedef struct sqlite3_module sqlite3_module;
	typedef struct sqlite3_blob sqlite3_blob;
	typedef struct sqlite3_mutex_methods sqlite3_mutex_methods;
	typedef struct sqlite3_pcache sqlite3_pcache;
	typedef struct sqlite3_pcache_methods sqlite3_pcache_methods;
	typedef struct sqlite3_backup sqlite3_backup;
	typedef struct sqlite3_rtree_geometry sqlite3_rtree_geometry;

	enum {
	SQLITE_VERSION_NUMBER = 3007009,
	SQLITE_OK = 0   /* Successful result */,
	SQLITE_ERROR = 1   /* SQL error or missing database */,
	SQLITE_INTERNAL = 2   /* Internal logic error in SQLite */,
	SQLITE_PERM = 3   /* Access permission denied */,
	SQLITE_ABORT = 4   /* Callback routine requested an abort */,
	SQLITE_BUSY = 5   /* The database file is locked */,
	SQLITE_LOCKED = 6   /* A table in the database is locked */,
	SQLITE_NOMEM = 7   /* A malloc() failed */,
	SQLITE_READONLY = 8   /* Attempt to write a readonly database */,
	SQLITE_INTERRUPT = 9   /* Operation terminated by sqlite3_interrupt()*/,
	SQLITE_IOERR = 10   /* Some kind of disk I/O error occurred */,
	SQLITE_CORRUPT = 11   /* The database disk image is malformed */,
	SQLITE_NOTFOUND = 12   /* Unknown opcode in sqlite3_file_control() */,
	SQLITE_FULL = 13   /* Insertion failed because database is full */,
	SQLITE_CANTOPEN = 14   /* Unable to open the database file */,
	SQLITE_PROTOCOL = 15   /* Database lock protocol error */,
	SQLITE_EMPTY = 16   /* Database is empty */,
	SQLITE_SCHEMA = 17   /* The database schema changed */,
	SQLITE_TOOBIG = 18   /* String or BLOB exceeds size limit */,
	SQLITE_CONSTRAINT = 19   /* Abort due to constraint violation */,
	SQLITE_MISMATCH = 20   /* Data type mismatch */,
	SQLITE_MISUSE = 21   /* Library used incorrectly */,
	SQLITE_NOLFS = 22   /* Uses OS features not supported on host */,
	SQLITE_AUTH = 23   /* Authorization denied */,
	SQLITE_FORMAT = 24   /* Auxiliary database format error */,
	SQLITE_RANGE = 25   /* 2nd parameter to sqlite3_bind out of range */,
	SQLITE_NOTADB = 26   /* File opened that is not a database file */,
	SQLITE_ROW = 100  /* sqlite3_step() has another row ready */,
	SQLITE_DONE = 101  /* sqlite3_step() has finished executing */,
	SQLITE_IOERR_READ = (SQLITE_IOERR | (1<<8)),
	SQLITE_IOERR_SHORT_READ = (SQLITE_IOERR | (2<<8)),
	SQLITE_IOERR_WRITE = (SQLITE_IOERR | (3<<8)),
	SQLITE_IOERR_FSYNC = (SQLITE_IOERR | (4<<8)),
	SQLITE_IOERR_DIR_FSYNC = (SQLITE_IOERR | (5<<8)),
	SQLITE_IOERR_TRUNCATE = (SQLITE_IOERR | (6<<8)),
	SQLITE_IOERR_FSTAT = (SQLITE_IOERR | (7<<8)),
	SQLITE_IOERR_UNLOCK = (SQLITE_IOERR | (8<<8)),
	SQLITE_IOERR_RDLOCK = (SQLITE_IOERR | (9<<8)),
	SQLITE_IOERR_DELETE = (SQLITE_IOERR | (10<<8)),
	SQLITE_IOERR_BLOCKED = (SQLITE_IOERR | (11<<8)),
	SQLITE_IOERR_NOMEM = (SQLITE_IOERR | (12<<8)),
	SQLITE_IOERR_ACCESS = (SQLITE_IOERR | (13<<8)),
	SQLITE_IOERR_CHECKRESERVEDLOCK = (SQLITE_IOERR | (14<<8)),
	SQLITE_IOERR_LOCK = (SQLITE_IOERR | (15<<8)),
	SQLITE_IOERR_CLOSE = (SQLITE_IOERR | (16<<8)),
	SQLITE_IOERR_DIR_CLOSE = (SQLITE_IOERR | (17<<8)),
	SQLITE_IOERR_SHMOPEN = (SQLITE_IOERR | (18<<8)),
	SQLITE_IOERR_SHMSIZE = (SQLITE_IOERR | (19<<8)),
	SQLITE_IOERR_SHMLOCK = (SQLITE_IOERR | (20<<8)),
	SQLITE_IOERR_SHMMAP = (SQLITE_IOERR | (21<<8)),
	SQLITE_IOERR_SEEK = (SQLITE_IOERR | (22<<8)),
	SQLITE_LOCKED_SHAREDCACHE = (SQLITE_LOCKED |  (1<<8)),
	SQLITE_BUSY_RECOVERY = (SQLITE_BUSY   |  (1<<8)),
	SQLITE_CANTOPEN_NOTEMPDIR = (SQLITE_CANTOPEN | (1<<8)),
	SQLITE_CORRUPT_VTAB = (SQLITE_CORRUPT | (1<<8)),
	SQLITE_READONLY_RECOVERY = (SQLITE_READONLY | (1<<8)),
	SQLITE_READONLY_CANTLOCK = (SQLITE_READONLY | (2<<8)),
	SQLITE_OPEN_READONLY = 0x00000001  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_READWRITE = 0x00000002  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_CREATE = 0x00000004  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_DELETEONCLOSE = 0x00000008  /* VFS only */,
	SQLITE_OPEN_EXCLUSIVE = 0x00000010  /* VFS only */,
	SQLITE_OPEN_AUTOPROXY = 0x00000020  /* VFS only */,
	SQLITE_OPEN_URI = 0x00000040  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_MAIN_DB = 0x00000100  /* VFS only */,
	SQLITE_OPEN_TEMP_DB = 0x00000200  /* VFS only */,
	SQLITE_OPEN_TRANSIENT_DB = 0x00000400  /* VFS only */,
	SQLITE_OPEN_MAIN_JOURNAL = 0x00000800  /* VFS only */,
	SQLITE_OPEN_TEMP_JOURNAL = 0x00001000  /* VFS only */,
	SQLITE_OPEN_SUBJOURNAL = 0x00002000  /* VFS only */,
	SQLITE_OPEN_MASTER_JOURNAL = 0x00004000  /* VFS only */,
	SQLITE_OPEN_NOMUTEX = 0x00008000  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_FULLMUTEX = 0x00010000  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_SHAREDCACHE = 0x00020000  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_PRIVATECACHE = 0x00040000  /* Ok for sqlite3_open_v2() */,
	SQLITE_OPEN_WAL = 0x00080000  /* VFS only */,
	SQLITE_IOCAP_ATOMIC = 0x00000001,
	SQLITE_IOCAP_ATOMIC512 = 0x00000002,
	SQLITE_IOCAP_ATOMIC1K = 0x00000004,
	SQLITE_IOCAP_ATOMIC2K = 0x00000008,
	SQLITE_IOCAP_ATOMIC4K = 0x00000010,
	SQLITE_IOCAP_ATOMIC8K = 0x00000020,
	SQLITE_IOCAP_ATOMIC16K = 0x00000040,
	SQLITE_IOCAP_ATOMIC32K = 0x00000080,
	SQLITE_IOCAP_ATOMIC64K = 0x00000100,
	SQLITE_IOCAP_SAFE_APPEND = 0x00000200,
	SQLITE_IOCAP_SEQUENTIAL = 0x00000400,
	SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN = 0x00000800,
	SQLITE_LOCK_NONE = 0,
	SQLITE_LOCK_SHARED = 1,
	SQLITE_LOCK_RESERVED = 2,
	SQLITE_LOCK_PENDING = 3,
	SQLITE_LOCK_EXCLUSIVE = 4,
	SQLITE_SYNC_NORMAL = 0x00002,
	SQLITE_SYNC_FULL = 0x00003,
	SQLITE_SYNC_DATAONLY = 0x00010,
	SQLITE_FCNTL_LOCKSTATE = 1,
	SQLITE_GET_LOCKPROXYFILE = 2,
	SQLITE_SET_LOCKPROXYFILE = 3,
	SQLITE_LAST_ERRNO = 4,
	SQLITE_FCNTL_SIZE_HINT = 5,
	SQLITE_FCNTL_CHUNK_SIZE = 6,
	SQLITE_FCNTL_FILE_POINTER = 7,
	SQLITE_FCNTL_SYNC_OMITTED = 8,
	SQLITE_FCNTL_WIN32_AV_RETRY = 9,
	SQLITE_FCNTL_PERSIST_WAL = 10,
	SQLITE_FCNTL_OVERWRITE = 11,
	SQLITE_ACCESS_EXISTS = 0,
	SQLITE_ACCESS_READWRITE = 1   /* Used by PRAGMA temp_store_directory */,
	SQLITE_ACCESS_READ = 2   /* Unused */,
	SQLITE_SHM_UNLOCK = 1,
	SQLITE_SHM_LOCK = 2,
	SQLITE_SHM_SHARED = 4,
	SQLITE_SHM_EXCLUSIVE = 8,
	SQLITE_SHM_NLOCK = 8,
	SQLITE_CONFIG_SINGLETHREAD = 1  /* nil */,
	SQLITE_CONFIG_MULTITHREAD = 2  /* nil */,
	SQLITE_CONFIG_SERIALIZED = 3  /* nil */,
	SQLITE_CONFIG_MALLOC = 4  /* sqlite3_mem_methods* */,
	SQLITE_CONFIG_GETMALLOC = 5  /* sqlite3_mem_methods* */,
	SQLITE_CONFIG_SCRATCH = 6  /* void*, int sz, int N */,
	SQLITE_CONFIG_PAGECACHE = 7  /* void*, int sz, int N */,
	SQLITE_CONFIG_HEAP = 8  /* void*, int nByte, int min */,
	SQLITE_CONFIG_MEMSTATUS = 9  /* boolean */,
	SQLITE_CONFIG_MUTEX = 10  /* sqlite3_mutex_methods* */,
	SQLITE_CONFIG_GETMUTEX = 11  /* sqlite3_mutex_methods* */,
	SQLITE_CONFIG_LOOKASIDE = 13  /* int int */,
	SQLITE_CONFIG_PCACHE = 14  /* sqlite3_pcache_methods* */,
	SQLITE_CONFIG_GETPCACHE = 15  /* sqlite3_pcache_methods* */,
	SQLITE_CONFIG_LOG = 16  /* xFunc, void* */,
	SQLITE_CONFIG_URI = 17  /* int */,
	SQLITE_DBCONFIG_LOOKASIDE = 1001  /* void* int int */,
	SQLITE_DBCONFIG_ENABLE_FKEY = 1002  /* int int* */,
	SQLITE_DBCONFIG_ENABLE_TRIGGER = 1003  /* int int* */,
	SQLITE_DENY = 1   /* Abort the SQL statement with an error */,
	SQLITE_IGNORE = 2   /* Don't allow access, but don't generate an error */,
	SQLITE_CREATE_INDEX = 1   /* Index Name      Table Name      */,
	SQLITE_CREATE_TABLE = 2   /* Table Name      NULL            */,
	SQLITE_CREATE_TEMP_INDEX = 3   /* Index Name      Table Name      */,
	SQLITE_CREATE_TEMP_TABLE = 4   /* Table Name      NULL            */,
	SQLITE_CREATE_TEMP_TRIGGER = 5   /* Trigger Name    Table Name      */,
	SQLITE_CREATE_TEMP_VIEW = 6   /* View Name       NULL            */,
	SQLITE_CREATE_TRIGGER = 7   /* Trigger Name    Table Name      */,
	SQLITE_CREATE_VIEW = 8   /* View Name       NULL            */,
	SQLITE_DELETE = 9   /* Table Name      NULL            */,
	SQLITE_DROP_INDEX = 10   /* Index Name      Table Name      */,
	SQLITE_DROP_TABLE = 11   /* Table Name      NULL            */,
	SQLITE_DROP_TEMP_INDEX = 12   /* Index Name      Table Name      */,
	SQLITE_DROP_TEMP_TABLE = 13   /* Table Name      NULL            */,
	SQLITE_DROP_TEMP_TRIGGER = 14   /* Trigger Name    Table Name      */,
	SQLITE_DROP_TEMP_VIEW = 15   /* View Name       NULL            */,
	SQLITE_DROP_TRIGGER = 16   /* Trigger Name    Table Name      */,
	SQLITE_DROP_VIEW = 17   /* View Name       NULL            */,
	SQLITE_INSERT = 18   /* Table Name      NULL            */,
	SQLITE_PRAGMA = 19   /* Pragma Name     1st arg or NULL */,
	SQLITE_READ = 20   /* Table Name      Column Name     */,
	SQLITE_SELECT = 21   /* NULL            NULL            */,
	SQLITE_TRANSACTION = 22   /* Operation       NULL            */,
	SQLITE_UPDATE = 23   /* Table Name      Column Name     */,
	SQLITE_ATTACH = 24   /* Filename        NULL            */,
	SQLITE_DETACH = 25   /* Database Name   NULL            */,
	SQLITE_ALTER_TABLE = 26   /* Database Name   Table Name      */,
	SQLITE_REINDEX = 27   /* Index Name      NULL            */,
	SQLITE_ANALYZE = 28   /* Table Name      NULL            */,
	SQLITE_CREATE_VTABLE = 29   /* Table Name      Module Name     */,
	SQLITE_DROP_VTABLE = 30   /* Table Name      Module Name     */,
	SQLITE_FUNCTION = 31   /* NULL            Function Name   */,
	SQLITE_SAVEPOINT = 32   /* Operation       Savepoint Name  */,
	SQLITE_COPY = 0   /* No longer used */,
	SQLITE_LIMIT_LENGTH = 0,
	SQLITE_LIMIT_SQL_LENGTH = 1,
	SQLITE_LIMIT_COLUMN = 2,
	SQLITE_LIMIT_EXPR_DEPTH = 3,
	SQLITE_LIMIT_COMPOUND_SELECT = 4,
	SQLITE_LIMIT_VDBE_OP = 5,
	SQLITE_LIMIT_FUNCTION_ARG = 6,
	SQLITE_LIMIT_ATTACHED = 7,
	SQLITE_LIMIT_LIKE_PATTERN_LENGTH = 8,
	SQLITE_LIMIT_VARIABLE_NUMBER = 9,
	SQLITE_LIMIT_TRIGGER_DEPTH = 10,
	SQLITE_INTEGER = 1,
	SQLITE_FLOAT = 2,
	SQLITE_BLOB = 4,
	SQLITE_NULL = 5,
	SQLITE_TEXT = 3,
	SQLITE_UTF8 = 1,
	SQLITE_UTF16LE = 2,
	SQLITE_UTF16BE = 3,
	SQLITE_UTF16 = 4    /* Use native byte order */,
	SQLITE_ANY = 5    /* sqlite3_create_function only */,
	SQLITE_UTF16_ALIGNED = 8    /* sqlite3_create_collation only */,
	SQLITE_INDEX_CONSTRAINT_EQ = 2,
	SQLITE_INDEX_CONSTRAINT_GT = 4,
	SQLITE_INDEX_CONSTRAINT_LE = 8,
	SQLITE_INDEX_CONSTRAINT_LT = 16,
	SQLITE_INDEX_CONSTRAINT_GE = 32,
	SQLITE_INDEX_CONSTRAINT_MATCH = 64,
	SQLITE_MUTEX_FAST = 0,
	SQLITE_MUTEX_RECURSIVE = 1,
	SQLITE_MUTEX_STATIC_MASTER = 2,
	SQLITE_MUTEX_STATIC_MEM = 3  /* sqlite3_malloc() */,
	SQLITE_MUTEX_STATIC_MEM2 = 4  /* NOT USED */,
	SQLITE_MUTEX_STATIC_OPEN = 4  /* sqlite3BtreeOpen() */,
	SQLITE_MUTEX_STATIC_PRNG = 5  /* sqlite3_random() */,
	SQLITE_MUTEX_STATIC_LRU = 6  /* lru page list */,
	SQLITE_MUTEX_STATIC_LRU2 = 7  /* NOT USED */,
	SQLITE_MUTEX_STATIC_PMEM = 7  /* sqlite3PageMalloc() */,
	SQLITE_TESTCTRL_FIRST = 5,
	SQLITE_TESTCTRL_PRNG_SAVE = 5,
	SQLITE_TESTCTRL_PRNG_RESTORE = 6,
	SQLITE_TESTCTRL_PRNG_RESET = 7,
	SQLITE_TESTCTRL_BITVEC_TEST = 8,
	SQLITE_TESTCTRL_FAULT_INSTALL = 9,
	SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS = 10,
	SQLITE_TESTCTRL_PENDING_BYTE = 11,
	SQLITE_TESTCTRL_ASSERT = 12,
	SQLITE_TESTCTRL_ALWAYS = 13,
	SQLITE_TESTCTRL_RESERVE = 14,
	SQLITE_TESTCTRL_OPTIMIZATIONS = 15,
	SQLITE_TESTCTRL_ISKEYWORD = 16,
	SQLITE_TESTCTRL_PGHDRSZ = 17,
	SQLITE_TESTCTRL_SCRATCHMALLOC = 18,
	SQLITE_TESTCTRL_LOCALTIME_FAULT = 19,
	SQLITE_TESTCTRL_LAST = 19,
	SQLITE_STATUS_MEMORY_USED = 0,
	SQLITE_STATUS_PAGECACHE_USED = 1,
	SQLITE_STATUS_PAGECACHE_OVERFLOW = 2,
	SQLITE_STATUS_SCRATCH_USED = 3,
	SQLITE_STATUS_SCRATCH_OVERFLOW = 4,
	SQLITE_STATUS_MALLOC_SIZE = 5,
	SQLITE_STATUS_PARSER_STACK = 6,
	SQLITE_STATUS_PAGECACHE_SIZE = 7,
	SQLITE_STATUS_SCRATCH_SIZE = 8,
	SQLITE_STATUS_MALLOC_COUNT = 9,
	SQLITE_DBSTATUS_LOOKASIDE_USED = 0,
	SQLITE_DBSTATUS_CACHE_USED = 1,
	SQLITE_DBSTATUS_SCHEMA_USED = 2,
	SQLITE_DBSTATUS_STMT_USED = 3,
	SQLITE_DBSTATUS_LOOKASIDE_HIT = 4,
	SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE = 5,
	SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL = 6,
	SQLITE_DBSTATUS_CACHE_HIT = 7,
	SQLITE_DBSTATUS_CACHE_MISS = 8,
	SQLITE_DBSTATUS_MAX = 8   /* Largest defined DBSTATUS */,
	SQLITE_STMTSTATUS_FULLSCAN_STEP = 1,
	SQLITE_STMTSTATUS_SORT = 2,
	SQLITE_STMTSTATUS_AUTOINDEX = 3,
	SQLITE_CHECKPOINT_PASSIVE = 0,
	SQLITE_CHECKPOINT_FULL = 1,
	SQLITE_CHECKPOINT_RESTART = 2,
	SQLITE_VTAB_CONSTRAINT_SUPPORT = 1,
	SQLITE_ROLLBACK = 1,
	SQLITE_FAIL = 3,
	SQLITE_REPLACE = 5
	};
	extern const char sqlite3_version[];
	const char *sqlite3_libversion(void);
	const char *sqlite3_sourceid(void);
	int sqlite3_libversion_number(void);

	int sqlite3_compileoption_used(const char *zOptName);
	const char *sqlite3_compileoption_get(int N);

	int sqlite3_threadsafe(void);

	int sqlite3_close(sqlite3 *);

	 int sqlite3_exec(
	  sqlite3*,
	  const char *sql,
	  int (*callback)(void*,int,char**,char**),
	  void *,
	  char **errmsg
	);

	struct sqlite3_file {
	  const struct sqlite3_io_methods *pMethods;
	};

	struct sqlite3_io_methods {
	  int iVersion;
	  int (*xClose)(sqlite3_file*);
	  int (*xRead)(sqlite3_file*, void*, int iAmt, sqlite3_int64 iOfst);
	  int (*xWrite)(sqlite3_file*, const void*, int iAmt, sqlite3_int64 iOfst);
	  int (*xTruncate)(sqlite3_file*, sqlite3_int64 size);
	  int (*xSync)(sqlite3_file*, int flags);
	  int (*xFileSize)(sqlite3_file*, sqlite3_int64 *pSize);
	  int (*xLock)(sqlite3_file*, int);
	  int (*xUnlock)(sqlite3_file*, int);
	  int (*xCheckReservedLock)(sqlite3_file*, int *pResOut);
	  int (*xFileControl)(sqlite3_file*, int op, void *pArg);
	  int (*xSectorSize)(sqlite3_file*);
	  int (*xDeviceCharacteristics)(sqlite3_file*);

	  int (*xShmMap)(sqlite3_file*, int iPg, int pgsz, int, void volatile**);
	  int (*xShmLock)(sqlite3_file*, int offset, int n, int flags);
	  void (*xShmBarrier)(sqlite3_file*);
	  int (*xShmUnmap)(sqlite3_file*, int deleteFlag);


	};

	struct sqlite3_vfs {
	  int iVersion;
	  int szOsFile;
	  int mxPathname;
	  sqlite3_vfs *pNext;
	  const char *zName;
	  void *pAppData;
	  int (*xOpen)(sqlite3_vfs*, const char *zName, sqlite3_file*,
	               int flags, int *pOutFlags);
	  int (*xDelete)(sqlite3_vfs*, const char *zName, int syncDir);
	  int (*xAccess)(sqlite3_vfs*, const char *zName, int flags, int *pResOut);
	  int (*xFullPathname)(sqlite3_vfs*, const char *zName, int nOut, char *zOut);
	  void *(*xDlOpen)(sqlite3_vfs*, const char *zFilename);
	  void (*xDlError)(sqlite3_vfs*, int nByte, char *zErrMsg);
	  void (*(*xDlSym)(sqlite3_vfs*,void*, const char *zSymbol))(void);
	  void (*xDlClose)(sqlite3_vfs*, void*);
	  int (*xRandomness)(sqlite3_vfs*, int nByte, char *zOut);
	  int (*xSleep)(sqlite3_vfs*, int microseconds);
	  int (*xCurrentTime)(sqlite3_vfs*, double*);
	  int (*xGetLastError)(sqlite3_vfs*, int, char *);




	  int (*xCurrentTimeInt64)(sqlite3_vfs*, sqlite3_int64*);




	  int (*xSetSystemCall)(sqlite3_vfs*, const char *zName, sqlite3_syscall_ptr);
	  sqlite3_syscall_ptr (*xGetSystemCall)(sqlite3_vfs*, const char *zName);
	  const char *(*xNextSystemCall)(sqlite3_vfs*, const char *zName);





	};

	 int sqlite3_initialize(void);
	 int sqlite3_shutdown(void);
	 int sqlite3_os_init(void);
	 int sqlite3_os_end(void);

	 int sqlite3_config(int, ...);

	 int sqlite3_db_config(sqlite3*, int op, ...);

	struct sqlite3_mem_methods {
	  void *(*xMalloc)(int);
	  void (*xFree)(void*);
	  void *(*xRealloc)(void*,int);
	  int (*xSize)(void*);
	  int (*xRoundup)(int);
	  int (*xInit)(void*);
	  void (*xShutdown)(void*);
	  void *pAppData;
	};

	 int sqlite3_extended_result_codes(sqlite3*, int onoff);

	 sqlite3_int64 sqlite3_last_insert_rowid(sqlite3*);

	 int sqlite3_changes(sqlite3*);

	 int sqlite3_total_changes(sqlite3*);

	 void sqlite3_interrupt(sqlite3*);

	 int sqlite3_complete(const char *sql);
	 int sqlite3_complete16(const void *sql);

	 int sqlite3_busy_handler(sqlite3*, int(*)(void*,int), void*);

	 int sqlite3_busy_timeout(sqlite3*, int ms);

	 int sqlite3_get_table(
	  sqlite3 *db,
	  const char *zSql,
	  char ***pazResult,
	  int *pnRow,
	  int *pnColumn,
	  char **pzErrmsg
	);
	 void sqlite3_free_table(char **result);

	 char *sqlite3_mprintf(const char*,...);
	 char *sqlite3_vmprintf(const char*, va_list);
	 char *sqlite3_snprintf(int,char*,const char*, ...);
	 char *sqlite3_vsnprintf(int,char*,const char*, va_list);

	 void *sqlite3_malloc(int);
	 void *sqlite3_realloc(void*, int);
	 void sqlite3_free(void*);

	 sqlite3_int64 sqlite3_memory_used(void);
	 sqlite3_int64 sqlite3_memory_highwater(int resetFlag);

	 void sqlite3_randomness(int N, void *P);

	 int sqlite3_set_authorizer(
	  sqlite3*,
	  int (*xAuth)(void*,int,const char*,const char*,const char*,const char*),
	  void *pUserData
	);

	 void *sqlite3_trace(sqlite3*, void(*xTrace)(void*,const char*), void*);
	 void *sqlite3_profile(sqlite3*,
	   void(*xProfile)(void*,const char*,sqlite3_uint64), void*);

	 void sqlite3_progress_handler(sqlite3*, int, int(*)(void*), void*);

	 int sqlite3_open(
	  const char *filename,
	  sqlite3 **ppDb
	);
	 int sqlite3_open16(
	  const void *filename,
	  sqlite3 **ppDb
	);
	 int sqlite3_open_v2(
	  const char *filename,
	  sqlite3 **ppDb,
	  int flags,
	  const char *zVfs
	);

	 const char *sqlite3_uri_parameter(const char *zFilename, const char *zParam);

	 int sqlite3_errcode(sqlite3 *db);
	 int sqlite3_extended_errcode(sqlite3 *db);
	 const char *sqlite3_errmsg(sqlite3*);
	 const void *sqlite3_errmsg16(sqlite3*);

	 int sqlite3_limit(sqlite3*, int id, int newVal);

	 int sqlite3_prepare(
	  sqlite3 *db,
	  const char *zSql,
	  int nByte,
	  sqlite3_stmt **ppStmt,
	  const char **pzTail
	);
	 int sqlite3_prepare_v2(
	  sqlite3 *db,
	  const char *zSql,
	  int nByte,
	  sqlite3_stmt **ppStmt,
	  const char **pzTail
	);
	 int sqlite3_prepare16(
	  sqlite3 *db,
	  const void *zSql,
	  int nByte,
	  sqlite3_stmt **ppStmt,
	  const void **pzTail
	);
	 int sqlite3_prepare16_v2(
	  sqlite3 *db,
	  const void *zSql,
	  int nByte,
	  sqlite3_stmt **ppStmt,
	  const void **pzTail
	);

	 const char *sqlite3_sql(sqlite3_stmt *pStmt);

	 int sqlite3_stmt_readonly(sqlite3_stmt *pStmt);



	 int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
	 int sqlite3_bind_double(sqlite3_stmt*, int, double);
	 int sqlite3_bind_int(sqlite3_stmt*, int, int);
	 int sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
	 int sqlite3_bind_null(sqlite3_stmt*, int);
	 int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));
	 int sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
	 int sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
	 int sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);

	 int sqlite3_bind_parameter_count(sqlite3_stmt*);

	 const char *sqlite3_bind_parameter_name(sqlite3_stmt*, int);

	 int sqlite3_bind_parameter_index(sqlite3_stmt*, const char *zName);

	 int sqlite3_clear_bindings(sqlite3_stmt*);

	 int sqlite3_column_count(sqlite3_stmt *pStmt);

	 const char *sqlite3_column_name(sqlite3_stmt*, int N);
	 const void *sqlite3_column_name16(sqlite3_stmt*, int N);

	 const char *sqlite3_column_database_name(sqlite3_stmt*,int);
	 const void *sqlite3_column_database_name16(sqlite3_stmt*,int);
	 const char *sqlite3_column_table_name(sqlite3_stmt*,int);
	 const void *sqlite3_column_table_name16(sqlite3_stmt*,int);
	 const char *sqlite3_column_origin_name(sqlite3_stmt*,int);
	 const void *sqlite3_column_origin_name16(sqlite3_stmt*,int);

	 const char *sqlite3_column_decltype(sqlite3_stmt*,int);
	 const void *sqlite3_column_decltype16(sqlite3_stmt*,int);

	 int sqlite3_step(sqlite3_stmt*);

	 int sqlite3_data_count(sqlite3_stmt *pStmt);

	 const void *sqlite3_column_blob(sqlite3_stmt*, int iCol);
	 int sqlite3_column_bytes(sqlite3_stmt*, int iCol);
	 int sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
	 double sqlite3_column_double(sqlite3_stmt*, int iCol);
	 int sqlite3_column_int(sqlite3_stmt*, int iCol);
	 sqlite3_int64 sqlite3_column_int64(sqlite3_stmt*, int iCol);
	 const unsigned char *sqlite3_column_text(sqlite3_stmt*, int iCol);
	 const void *sqlite3_column_text16(sqlite3_stmt*, int iCol);
	 int sqlite3_column_type(sqlite3_stmt*, int iCol);
	 sqlite3_value *sqlite3_column_value(sqlite3_stmt*, int iCol);

	 int sqlite3_finalize(sqlite3_stmt *pStmt);

	 int sqlite3_reset(sqlite3_stmt *pStmt);

	 int sqlite3_create_function(
	  sqlite3 *db,
	  const char *zFunctionName,
	  int nArg,
	  int eTextRep,
	  void *pApp,
	  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
	  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
	  void (*xFinal)(sqlite3_context*)
	);
	 int sqlite3_create_function16(
	  sqlite3 *db,
	  const void *zFunctionName,
	  int nArg,
	  int eTextRep,
	  void *pApp,
	  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
	  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
	  void (*xFinal)(sqlite3_context*)
	);
	 int sqlite3_create_function_v2(
	  sqlite3 *db,
	  const char *zFunctionName,
	  int nArg,
	  int eTextRep,
	  void *pApp,
	  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
	  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
	  void (*xFinal)(sqlite3_context*),
	  void(*xDestroy)(void*)
	);

	 int sqlite3_aggregate_count(sqlite3_context*);
	 int sqlite3_expired(sqlite3_stmt*);
	 int sqlite3_transfer_bindings(sqlite3_stmt*, sqlite3_stmt*);
	 int sqlite3_global_recover(void);
	 void sqlite3_thread_cleanup(void);
	 int sqlite3_memory_alarm(void(*)(void*,sqlite3_int64,int),void*,sqlite3_int64);

	 const void *sqlite3_value_blob(sqlite3_value*);
	 int sqlite3_value_bytes(sqlite3_value*);
	 int sqlite3_value_bytes16(sqlite3_value*);
	 double sqlite3_value_double(sqlite3_value*);
	 int sqlite3_value_int(sqlite3_value*);
	 sqlite3_int64 sqlite3_value_int64(sqlite3_value*);
	 const unsigned char *sqlite3_value_text(sqlite3_value*);
	 const void *sqlite3_value_text16(sqlite3_value*);
	 const void *sqlite3_value_text16le(sqlite3_value*);
	 const void *sqlite3_value_text16be(sqlite3_value*);
	 int sqlite3_value_type(sqlite3_value*);
	 int sqlite3_value_numeric_type(sqlite3_value*);

	 void *sqlite3_aggregate_context(sqlite3_context*, int nBytes);

	 void *sqlite3_user_data(sqlite3_context*);

	 sqlite3 *sqlite3_context_db_handle(sqlite3_context*);

	 void *sqlite3_get_auxdata(sqlite3_context*, int N);
	 void sqlite3_set_auxdata(sqlite3_context*, int N, void*, void (*)(void*));

	 void sqlite3_result_blob(sqlite3_context*, const void*, int, void(*)(void*));
	 void sqlite3_result_double(sqlite3_context*, double);
	 void sqlite3_result_error(sqlite3_context*, const char*, int);
	 void sqlite3_result_error16(sqlite3_context*, const void*, int);
	 void sqlite3_result_error_toobig(sqlite3_context*);
	 void sqlite3_result_error_nomem(sqlite3_context*);
	 void sqlite3_result_error_code(sqlite3_context*, int);
	 void sqlite3_result_int(sqlite3_context*, int);
	 void sqlite3_result_int64(sqlite3_context*, sqlite3_int64);
	 void sqlite3_result_null(sqlite3_context*);
	 void sqlite3_result_text(sqlite3_context*, const char*, int, void(*)(void*));
	 void sqlite3_result_text16(sqlite3_context*, const void*, int, void(*)(void*));
	 void sqlite3_result_text16le(sqlite3_context*, const void*, int,void(*)(void*));
	 void sqlite3_result_text16be(sqlite3_context*, const void*, int,void(*)(void*));
	 void sqlite3_result_value(sqlite3_context*, sqlite3_value*);
	 void sqlite3_result_zeroblob(sqlite3_context*, int n);

	 int sqlite3_create_collation(
	  sqlite3*,
	  const char *zName,
	  int eTextRep,
	  void *pArg,
	  int(*xCompare)(void*,int,const void*,int,const void*)
	);
	 int sqlite3_create_collation_v2(
	  sqlite3*,
	  const char *zName,
	  int eTextRep,
	  void *pArg,
	  int(*xCompare)(void*,int,const void*,int,const void*),
	  void(*xDestroy)(void*)
	);
	 int sqlite3_create_collation16(
	  sqlite3*,
	  const void *zName,
	  int eTextRep,
	  void *pArg,
	  int(*xCompare)(void*,int,const void*,int,const void*)
	);

	 int sqlite3_collation_needed(
	  sqlite3*,
	  void*,
	  void(*)(void*,sqlite3*,int eTextRep,const char*)
	);
	 int sqlite3_collation_needed16(
	  sqlite3*,
	  void*,
	  void(*)(void*,sqlite3*,int eTextRep,const void*)
	);

	 int sqlite3_sleep(int);

	 extern char *sqlite3_temp_directory;

	 int sqlite3_get_autocommit(sqlite3*);

	 sqlite3 *sqlite3_db_handle(sqlite3_stmt*);

	 sqlite3_stmt *sqlite3_next_stmt(sqlite3 *pDb, sqlite3_stmt *pStmt);

	 void *sqlite3_commit_hook(sqlite3*, int(*)(void*), void*);
	 void *sqlite3_rollback_hook(sqlite3*, void(*)(void *), void*);

	 void *sqlite3_update_hook(
	  sqlite3*,
	  void(*)(void *,int ,char const *,char const *,sqlite3_int64),
	  void*
	);

	 int sqlite3_enable_shared_cache(int);

	 int sqlite3_release_memory(int);

	 sqlite3_int64 sqlite3_soft_heap_limit64(sqlite3_int64 N);

	 void sqlite3_soft_heap_limit(int N);

	 int sqlite3_table_column_metadata(
	  sqlite3 *db,
	  const char *zDbName,
	  const char *zTableName,
	  const char *zColumnName,
	  char const **pzDataType,
	  char const **pzCollSeq,
	  int *pNotNull,
	  int *pPrimaryKey,
	  int *pAutoinc
	);

	 int sqlite3_load_extension(
	  sqlite3 *db,
	  const char *zFile,
	  const char *zProc,
	  char **pzErrMsg
	);

	 int sqlite3_enable_load_extension(sqlite3 *db, int onoff);

	 int sqlite3_auto_extension(void (*xEntryPoint)(void));







	 void sqlite3_reset_auto_extension(void);

	struct sqlite3_module {
	  int iVersion;
	  int (*xCreate)(sqlite3*, void *pAux,
	               int argc, const char *const*argv,
	               sqlite3_vtab **ppVTab, char**);
	  int (*xConnect)(sqlite3*, void *pAux,
	               int argc, const char *const*argv,
	               sqlite3_vtab **ppVTab, char**);
	  int (*xBestIndex)(sqlite3_vtab *pVTab, sqlite3_index_info*);
	  int (*xDisconnect)(sqlite3_vtab *pVTab);
	  int (*xDestroy)(sqlite3_vtab *pVTab);
	  int (*xOpen)(sqlite3_vtab *pVTab, sqlite3_vtab_cursor **ppCursor);
	  int (*xClose)(sqlite3_vtab_cursor*);
	  int (*xFilter)(sqlite3_vtab_cursor*, int idxNum, const char *idxStr,
	                int argc, sqlite3_value **argv);
	  int (*xNext)(sqlite3_vtab_cursor*);
	  int (*xEof)(sqlite3_vtab_cursor*);
	  int (*xColumn)(sqlite3_vtab_cursor*, sqlite3_context*, int);
	  int (*xRowid)(sqlite3_vtab_cursor*, sqlite3_int64 *pRowid);
	  int (*xUpdate)(sqlite3_vtab *, int, sqlite3_value **, sqlite3_int64 *);
	  int (*xBegin)(sqlite3_vtab *pVTab);
	  int (*xSync)(sqlite3_vtab *pVTab);
	  int (*xCommit)(sqlite3_vtab *pVTab);
	  int (*xRollback)(sqlite3_vtab *pVTab);
	  int (*xFindFunction)(sqlite3_vtab *pVtab, int nArg, const char *zName,
	                       void (**pxFunc)(sqlite3_context*,int,sqlite3_value**),
	                       void **ppArg);
	  int (*xRename)(sqlite3_vtab *pVtab, const char *zNew);


	  int (*xSavepoint)(sqlite3_vtab *pVTab, int);
	  int (*xRelease)(sqlite3_vtab *pVTab, int);
	  int (*xRollbackTo)(sqlite3_vtab *pVTab, int);
	};

	struct sqlite3_index_info {

	  int nConstraint;
	  struct sqlite3_index_constraint {
	     int iColumn;
	     unsigned char op;
	     unsigned char usable;
	     int iTermOffset;
	  } *aConstraint;
	  int nOrderBy;
	  struct sqlite3_index_orderby {
	     int iColumn;
	     unsigned char desc;
	  } *aOrderBy;

	  struct sqlite3_index_constraint_usage {
	    int argvIndex;
	    unsigned char omit;
	  } *aConstraintUsage;
	  int idxNum;
	  char *idxStr;
	  int needToFreeIdxStr;
	  int orderByConsumed;
	  double estimatedCost;
	};

	 int sqlite3_create_module(
	  sqlite3 *db,
	  const char *zName,
	  const sqlite3_module *p,
	  void *pClientData
	);
	 int sqlite3_create_module_v2(
	  sqlite3 *db,
	  const char *zName,
	  const sqlite3_module *p,
	  void *pClientData,
	  void(*xDestroy)(void*)
	);

	struct sqlite3_vtab {
	  const sqlite3_module *pModule;
	  int nRef;
	  char *zErrMsg;

	};

	struct sqlite3_vtab_cursor {
	  sqlite3_vtab *pVtab;

	};

	 int sqlite3_declare_vtab(sqlite3*, const char *zSQL);

	 int sqlite3_overload_function(sqlite3*, const char *zFuncName, int nArg);

	 int sqlite3_blob_open(
	  sqlite3*,
	  const char *zDb,
	  const char *zTable,
	  const char *zColumn,
	  sqlite3_int64 iRow,
	  int flags,
	  sqlite3_blob **ppBlob
	);

	 int sqlite3_blob_reopen(sqlite3_blob *, sqlite3_int64);

	 int sqlite3_blob_close(sqlite3_blob *);

	 int sqlite3_blob_bytes(sqlite3_blob *);

	 int sqlite3_blob_read(sqlite3_blob *, void *Z, int N, int iOffset);

	 int sqlite3_blob_write(sqlite3_blob *, const void *z, int n, int iOffset);

	 sqlite3_vfs *sqlite3_vfs_find(const char *zVfsName);
	 int sqlite3_vfs_register(sqlite3_vfs*, int makeDflt);
	 int sqlite3_vfs_unregister(sqlite3_vfs*);

	 sqlite3_mutex *sqlite3_mutex_alloc(int);
	 void sqlite3_mutex_free(sqlite3_mutex*);
	 void sqlite3_mutex_enter(sqlite3_mutex*);
	 int sqlite3_mutex_try(sqlite3_mutex*);
	 void sqlite3_mutex_leave(sqlite3_mutex*);


	struct sqlite3_mutex_methods {
	  int (*xMutexInit)(void);
	  int (*xMutexEnd)(void);
	  sqlite3_mutex *(*xMutexAlloc)(int);
	  void (*xMutexFree)(sqlite3_mutex *);
	  void (*xMutexEnter)(sqlite3_mutex *);
	  int (*xMutexTry)(sqlite3_mutex *);
	  void (*xMutexLeave)(sqlite3_mutex *);
	  int (*xMutexHeld)(sqlite3_mutex *);
	  int (*xMutexNotheld)(sqlite3_mutex *);
	};

	 int sqlite3_mutex_held(sqlite3_mutex*);
	 int sqlite3_mutex_notheld(sqlite3_mutex*);

	 sqlite3_mutex *sqlite3_db_mutex(sqlite3*);

	 int sqlite3_file_control(sqlite3*, const char *zDbName, int op, void*);

	 int sqlite3_test_control(int op, ...);

	 int sqlite3_status(int op, int *pCurrent, int *pHighwater, int resetFlag);

	 int sqlite3_db_status(sqlite3*, int op, int *pCur, int *pHiwtr, int resetFlg);

	 int sqlite3_stmt_status(sqlite3_stmt*, int op,int resetFlg);


	struct sqlite3_pcache_methods {
	  void *pArg;
	  int (*xInit)(void*);
	  void (*xShutdown)(void*);
	  sqlite3_pcache *(*xCreate)(int szPage, int bPurgeable);
	  void (*xCachesize)(sqlite3_pcache*, int nCachesize);
	  int (*xPagecount)(sqlite3_pcache*);
	  void *(*xFetch)(sqlite3_pcache*, unsigned key, int createFlag);
	  void (*xUnpin)(sqlite3_pcache*, void*, int discard);
	  void (*xRekey)(sqlite3_pcache*, void*, unsigned oldKey, unsigned newKey);
	  void (*xTruncate)(sqlite3_pcache*, unsigned iLimit);
	  void (*xDestroy)(sqlite3_pcache*);
	};

	 sqlite3_backup *sqlite3_backup_init(
	  sqlite3 *pDest,
	  const char *zDestName,
	  sqlite3 *pSource,
	  const char *zSourceName
	);
	 int sqlite3_backup_step(sqlite3_backup *p, int nPage);
	 int sqlite3_backup_finish(sqlite3_backup *p);
	 int sqlite3_backup_remaining(sqlite3_backup *p);
	 int sqlite3_backup_pagecount(sqlite3_backup *p);

	 int sqlite3_unlock_notify(
	  sqlite3 *pBlocked,
	  void (*xNotify)(void **apArg, int nArg),
	  void *pNotifyArg
	);

	 int sqlite3_strnicmp(const char *, const char *, int);

	 void sqlite3_log(int iErrCode, const char *zFormat, ...);

	 void *sqlite3_wal_hook(
	  sqlite3*,
	  int(*)(void *,sqlite3*,const char*,int),
	  void*
	);

	 int sqlite3_wal_autocheckpoint(sqlite3 *db, int N);

	 int sqlite3_wal_checkpoint(sqlite3 *db, const char *zDb);

	 int sqlite3_wal_checkpoint_v2(
	  sqlite3 *db,
	  const char *zDb,
	  int eMode,
	  int *pnLog,
	  int *pnCkpt
	);

	 int sqlite3_vtab_config(sqlite3*, int op, ...);

	 int sqlite3_vtab_on_conflict(sqlite3 *);

	 int sqlite3_rtree_geometry_callback(
	  sqlite3 *db,
	  const char *zGeom,
	  int (*xGeom)(sqlite3_rtree_geometry *, int nCoord, double *aCoord, int *pRes),
	  void *pContext
	);

	struct sqlite3_rtree_geometry {
	  void *pContext;
	  int nParam;
	  double *aParam;
	  void *pUser;
	  void (*xDelUser)(void *);
	};
]]

local sqlite3 = ffi.load("sqlite3.so.0")
local new_db_ptr = ffi.typeof("sqlite3*[1]")
local new_stmt_ptr = ffi.typeof("sqlite3_stmt*[1]")
local new_exec_ptr = ffi.typeof("int (*)(void*,int,char**,char**)")
local new_blob_ptr = ffi.typeof("sqlite3_blob*[1]")
local new_bytearr = ffi.typeof("uint8_t[?]")
local sqlite3_transient = ffi.cast("void*",-1)

local value_handlers = {
	[sqlite3.SQLITE_INTEGER] = function(stmt, n) return sqlite3.sqlite3_column_int(stmt, n) end,
	[sqlite3.SQLITE_FLOAT] = function(stmt, n) return sqlite3.sqlite3_column_double(stmt, n) end,
	[sqlite3.SQLITE_TEXT] = function(stmt, n) return ffi.string(sqlite3.sqlite3_column_text(stmt,n), sqlite3.sqlite3_column_bytes(stmt,n)-1) end,
	[sqlite3.SQLITE_BLOB] = function(stmt, n) return sqlite3.sqlite3_column_blob(stmt,n), sqlite3.sqlite3_column_bytes(stmt,n) end,
	[sqlite3.SQLITE_NULL] = function() return nil end
}

local lsqlite3 = {}

local sqlite_db = {}
sqlite_db.__index = sqlite_db
function sqlite_db:__call(...)
	return self:exec(...)
end

local sqlite_stmt = {}
function sqlite_stmt:__index(k)
	if type(k) == "number" then
		return sqlite_stmt.get_value(self, k)
	else
		return sqlite_stmt[k]
	end
end
function sqlite_stmt:__newindex(...)
	sqlite_stmt.bind(self,...)
end
function sqlite_stmt:__call()
	return self:step()
end

local sqlite_blob = {}
sqlite_blob.__index = sqlite_blob

-- Set to true to enable collecting of stack trace information when a statement or blob is created.
lsqlite3.DEBUG = false

-- -------------------------- Library Methods -------------------------- --

local modes = {
	read = sqlite3.SQLITE_OPEN_READONLY,
	write = sqlite3.SQLITE_OPEN_READWRITE,
	create = bit.bor(sqlite3.SQLITE_OPEN_READWRITE, sqlite3.SQLITE_OPEN_CREATE)
}

function lsqlite3.open(filename, mode)
	local sdb = new_db_ptr()
	local err = sqlite3.sqlite3_open_v2(filename, sdb, modes[mode or "create"] or error("unknown mode: "..tostring(mode),2), nil)
	local db = sdb[0]
	if err ~= sqlite3.SQLITE_OK then return nil, ffi.string(sqlite3.sqlite3_errmsg(db)), sqlite3.sqlite3_errcode(db) end
	return setmetatable({
		db = db,
		stmts = {},
		blobs = {},
	},sqlite_db)
end
function lsqlite3.open_memory()
	return lsqlite3.open(":memory:")
end

function lsqlite3.complete(str)
	local r = sqlite3.sqlite3_complete(str)
	if r == sqlite3.SQLITE_NOMEM then error("out of memory",2) end
	return r ~= 0 and true or false
end

function lsqlite3.version()
	return ffi.string(sqlite3.sqlite3_version)
end

-- TODO: lsqlite3.temp_directory

lsqlite3.OK = sqlite3.SQLITE_OK
lsqlite3.ERROR = sqlite3.SQLITE_ERROR
lsqlite3.INTERNAL = sqlite3.SQLITE_INTERNAL
lsqlite3.PERM = sqlite3.SQLITE_PERM
lsqlite3.ABORT = sqlite3.SQLITE_ABORT
lsqlite3.BUSY = sqlite3.SQLITE_BUSY
lsqlite3.LOCKED = sqlite3.SQLITE_LOCKED
lsqlite3.NOMEM = sqlite3.SQLITE_NOMEM
lsqlite3.READONLY = sqlite3.SQLITE_READONLY
lsqlite3.INTERRUPT = sqlite3.SQLITE_INTERRUPT
lsqlite3.IOERR = sqlite3.SQLITE_IOERR
lsqlite3.CORRUPT = sqlite3.SQLITE_CORRUPT
lsqlite3.NOTFOUND = sqlite3.SQLITE_NOTFOUND
lsqlite3.FULL = sqlite3.SQLITE_FULL
lsqlite3.CANTOPEN = sqlite3.SQLITE_CANTOPEN
lsqlite3.PROTOCOL = sqlite3.SQLITE_PROTOCOL
lsqlite3.EMPTY = sqlite3.SQLITE_EMPTY
lsqlite3.SCHEMA = sqlite3.SQLITE_SCHEMA
lsqlite3.TOOBIG = sqlite3.SQLITE_TOOBIG
lsqlite3.CONSTRAINT = sqlite3.SQLITE_CONSTRAINT
lsqlite3.MISMATCH = sqlite3.SQLITE_MISMATCH
lsqlite3.MISUSE = sqlite3.SQLITE_MISUSE
lsqlite3.NOLFS = sqlite3.SQLITE_NOLFS
lsqlite3.FORMAT = sqlite3.SQLITE_FORMAT
lsqlite3.NOTADB = sqlite3.SQLITE_NOTADB
lsqlite3.RANGE = sqlite3.SQLITE_RANGE
lsqlite3.ROW = sqlite3.SQLITE_ROW
lsqlite3.DONE = sqlite3.SQLITE_DONE
lsqlite3.INTEGER = sqlite3.SQLITE_INTEGER
lsqlite3.FLOAT = sqlite3.SQLITE_FLOAT
lsqlite3.TEXT = sqlite3.SQLITE_TEXT
lsqlite3.BLOB = sqlite3.SQLITE_BLOB
lsqlite3.NULL = sqlite3.SQLITE_NULL

-- -------------------------- Database Methods -------------------------- --

-- TODO: db:busy_handler
-- TODO: db:busy_timeout

function sqlite_db:changes()
	return sqlite3.sqlite3_changes(self.db)
end

function sqlite_db:close()
	local r = sqlite3.sqlite3_close(self.db)
	if r == sqlite3.SQLITE_OK then
		self.db = nil
	else
		self:check(r)
	end
end

-- TODO: db:close_vm
-- TODO: db:create_aggregate
-- TODO: db:create_collation
-- TODO: db:create_function

function sqlite_db:errcode()
	return sqlite3.sqlite3_extended_errcode(self.db)
end
sqlite_db.error_code = sqlite_db.errcode

function sqlite_db:errmsg()
	return ffi.string(sqlite3.sqlite3_errmsg(self.db))
end
sqlite_db.error_message = sqlite_db.errmsg

function sqlite_db:exec(sql, func)
	if func then
		local cb = ffi.cast("int (*)(void*,int,char**,char**)", function(ptr, num, values, keys)
			local tbl = {}
			for i = 1, num do
				local key = keys[i-1]
				local val = values[i-1]

				if key ~= nil and val ~= nil then
					tbl[i] = {key = ffi.string(key), value = ffi.string(val)}
				end
			end
			return func(tbl) or 0
		end)
		self:check(sqlite3.sqlite3_exec(self.db, sql, cb, nil, nil))
		cb:free()
	else
		self:check(sqlite3.sqlite3_exec(self.db, sql, nil, nil, nil))
	end
end

function sqlite_db:interrupt()
	sqlite3.sqlite3_interrupt(self.db)
end

function sqlite_db:isopen() return self.db and true or false end

function sqlite_db:last_insert_rowid()
	return tonumber(sqlite3.sqlite3_last_insert_rowid(self.db))
end

-- TODO: db:nrows

function sqlite_db:prepare(sql)
	local stmtptr = new_stmt_ptr()
	self:check(sqlite3.sqlite3_prepare_v2(self.db, sql, #sql+1, stmtptr, nil))
	local stmt = setmetatable(
	{
		stmt=stmtptr[0],
		db=self,
		trace=lsqlite3.DEBUG and debug.traceback() or nil
	},sqlite_stmt)
	self.stmts[stmt] = stmt
	return stmt
end

-- TODO: db:progress_handler
-- TODO: db:rows

function sqlite_db:total_changes()
	return sqlite3.sqlite3_total_changes(self.db)
end

-- TODO: db:trace
-- TODO: db:urows

function sqlite_db:check(ret)
	if ret ~= sqlite3.SQLITE_OK then
		error(self:errmsg(),0)
	end
	return ret
end

function sqlite_db:open_blob(db, tbl, column, row, write)
	local blobptr = new_blob_ptr()
	self:check(sqlite3.sqlite3_blob_open(self.db, db or "main", tbl, column, row, write, blobptr))
	local blob = setmetatable(
	{
		blob = blobptr[0],
		db = self,
		trace = lsqlite3.DEBUG and debug.traceback() or nil
	},sqlite_blob)
	self.blobs[blob] = blob
	return blob
end

function sqlite_db:get_autocommit()
	return sqlite3.sqlite3_get_autocommit(self.db) ~= 0
end

function sqlite_db:dump_unfinalized_statements()
	for _,stmt in pairs(self.stmts) do
		print(tostring(stmt))
		if stmt.trace then
			print("defined at: "..stmt.trace)
		end
	end
end

function sqlite_db:dump_unclosed_blobs()
	for _,blob in pairs(self.blobs) do
		print(tostring(blob))
		if blob.trace then
			print("defined at: "..blob.trace)
		end
	end
end

-- -------------------------- Statement Methods -------------------------- --

function sqlite_stmt:bind(n, value, bloblen)
	local t = type(value)
	if t == "string" then
		self.db:check(sqlite3.sqlite3_bind_text(self.stmt, n, value, #value+1, sqlite3_transient))
	elseif t == "number" then
		self.db:check(sqlite3.sqlite3_bind_double(self.stmt, n, value))
	elseif t == "boolean" then
		self.db:check(sqlite3.sqlite3_bind_int(self.stmt, n, value))
	elseif t == "nil" then
		self.db:check(sqlite3.sqlite3_bind_null(self.stmt, n))
	elseif t == "cdata" then
		if ffi.istype("int64_t", value) then
			self.db:check(sqlite3.sqlite3_bind_int64(self.stmt, n, value))
		else
			self.db:check(sqlite3.sqlite3_bind_blob(self.stmt, n, value, bloblen, sqlite3_transient))
		end
	else error("invalid bind type: "..t,2) end
end

function sqlite_stmt:bind_blob(n,value,len)
	if not value then
		self.db:check(sqlite3.sqlite3_bind_zeroblob(self.stmt, n, len or 0))
	elseif type(value) == "string" then
		self.db:check(sqlite3.sqlite3_bind_blob(self.stmt, n, value, len or #value, sqlite3_transient))
	elseif type(value) == "cdata" then
		self.db:check(sqlite3.sqlite3_bind_blob(self.stmt, n, value, len, sqlite3_transient))
	else
		error("invalid bind type: "..type(value),2)
	end
end

-- TODO: stmt:bind_names
-- TODO: stmt:bind_parameter_count
-- TODO: stmt:bind_parameter_name

function sqlite_stmt:bind_values(...)
	local l=select("#",...)
	for i=1,l do
		self:bind(i,select(i,...))
	end
end

function sqlite_stmt:columns()
	return sqlite3.sqlite3_column_count(self.stmt)
end

function sqlite_stmt:finalize()
	local r = sqlite3.sqlite3_finalize(self.stmt)
	if r == sqlite3.SQLITE_OK then
		self.stmt = nil
		self.db.stmts[self] = nil
	else
		self.db:check(r)
	end
end

function sqlite_stmt:get_name(n)
	return ffi.string(sqlite3.sqlite3_column_name(self.stmt, n))
end

function sqlite_stmt:get_named_types()
	local tbl = {}
	for i=0,sqlite3.sqlite3_column_count(self.stmt)-1 do
		tbl[ffi.string(sqlite3.sqlite3_column_name(self.stmt, n))] = ffi.string(sqlite3.sqlite3_column_decltype(self.stmt, n))
	end
	return tbl
end

-- TODO: stmt:get_named_values
-- TODO: stmt:get_names
-- TODO: stmt:get_unames
-- TODO: stmt:get_utypes
-- TODO: stmt:get_uvalues

function sqlite_stmt:get_value(n)
	return value_handlers[sqlite3.sqlite3_column_type(self.stmt,n)](self.stmt,n)
end

function sqlite_stmt:get_values()
	local tbl = {}
	for i=0,sqlite3.sqlite3_column_count(self.stmt)-1 do
		tbl[i+1] = self:get_value(i)
	end
	return tbl
end

function sqlite_stmt:get_values_unpacked(n)
	n = n or 0
	if n < sqlite3.sqlite3_column_count(self.stmt) then
		return self:get_value(n), self:get_values_unpacked(n+1)
	end
end

function sqlite_stmt:isopen() return self.stmt and true or false end

-- TODO: stmt:nrows

function sqlite_stmt:reset()
	self.db:check(sqlite3.sqlite3_reset(self.stmt))
end

function sqlite_stmt:rows()
	return function()
		if self:step() then
			return self:get_values()
		else
			return nil
		end
	end
end

function sqlite_stmt:rows_unpacked()
	return function()
		if self:step() then
			return self:get_values_unpacked()
		else
			return nil
		end
	end
end

function sqlite_stmt:step()
	local ret = sqlite3.sqlite3_step(self.stmt)
	if ret == sqlite3.SQLITE_ROW then
		return true
	elseif ret == sqlite3.SQLITE_DONE then
		return false
	else
		error(self.db:errmsg(),0)
	end
end

-- TODO: stmt:urows

function sqlite_stmt:clear_bindings()
	self.db:check(sqlite3.sqlite3_clear_bindings(self.stmt))
end

-- -------------------------- Blob Methods -------------------------- --

function sqlite_blob:read(numbytes, offset, buffer)
	numbytes = numbytes or #self
	buffer = buffer or new_bytearr(numbytes)
	self.db:check(sqlite3.sqlite3_blob_read(self.blob, buffer, numbytes, offset or 0))
	return buffer
end

function sqlite_blob:length()
	return sqlite3.sqlite3_blob_bytes(self.blob)
end
sqlite_blob.__len = sqlite_blob.length

function sqlite_blob:write(offset, data, datalen)
	if type(data) == "string" then
		datalen = #data
		data = new_bytearr(datalen, data)
	else assert(datalen and type(datalen) == "number") end
	self.db:check(sqlite3.sqlite3_blob_write(self.blob, data, datalen, offset))
end

function sqlite_blob:close()
	local r = sqlite3.sqlite3_blob_close(self.blob)
	if r == sqlite3.SQLITE_OK then
		self.blob = nil
		self.db.blobs[self] = nil
	else
		self.db:check(r)
	end
end

function sqlite_blob:reopen(row)
	self.db:check(sqlite3.sqlite3_blob_reopen(self.blob, row))
end

return lsqlite3
