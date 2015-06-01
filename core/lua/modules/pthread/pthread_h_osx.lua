--pthread.h from OSX 10.10 SDK

local ffi = require'ffi'
assert(ffi.os == 'OSX', 'Platform not OSX')

ffi.cdef[[
typedef long time_t;

enum {
	PTHREAD_CREATE_DETACHED = 2,
	PTHREAD_CANCEL_ENABLE = 0x01,
	PTHREAD_CANCEL_DISABLE = 0x00,
	PTHREAD_CANCEL_DEFERRED = 0x02,
	PTHREAD_CANCEL_ASYNCHRONOUS = 0x00,
	PTHREAD_CANCELED = 1,
	PTHREAD_EXPLICIT_SCHED = 2,
	PTHREAD_PROCESS_PRIVATE = 2,
	PTHREAD_MUTEX_NORMAL = 0,
	PTHREAD_MUTEX_ERRORCHECK = 1,
	PTHREAD_MUTEX_RECURSIVE = 2,
	SCHED_OTHER = 1,
	PTHREAD_STACK_MIN = 8192,
};

typedef void *real_pthread_t;
typedef struct { real_pthread_t _; } pthread_t;
]]

if ffi.abi'32bit' then
ffi.cdef[[
typedef struct pthread_attr_t {
	long __sig;
	char __opaque[36];
} pthread_attr_t;

typedef struct pthread_mutex_t {
	long __sig;
	char __opaque[40];
} pthread_mutex_t;

typedef struct pthread_cond_t {
	long __sig;
	char __opaque[24];
} pthread_cond_t;

typedef struct pthread_rwlock_t {
	long __sig;
	char __opaque[124];
} pthread_rwlock_t;

typedef struct pthread_mutexattr_t {
	long __sig;
	char __opaque[8];
} pthread_mutexattr_t;

typedef struct pthread_condattr_t {
	long __sig;
	char __opaque[4];
} pthread_condattr_t;

typedef struct pthread_rwlockattr_t {
	long __sig;
	char __opaque[12];
} pthread_rwlockattr_t;

// for pthread_cleanup_push()/_pop()
struct __darwin_pthread_handler_rec {
	void (*__routine)(void *);
	void *__arg;
	struct __darwin_pthread_handler_rec *__next;
};
]]
else --x64
ffi.cdef[[
typedef struct pthread_attr_t {
	long __sig;
	char __opaque[56];
} pthread_attr_t;

typedef struct pthread_mutex_t {
	long __sig;
	char __opaque[56];
} pthread_mutex_t;

typedef struct pthread_cond_t {
	long __sig;
	char __opaque[40];
} pthread_cond_t;

typedef struct pthread_rwlock_t {
	long __sig;
	char __opaque[192];
} pthread_rwlock_t;

typedef struct pthread_mutexattr_t {
	long __sig;
	char __opaque[8];
} pthread_mutexattr_t;

typedef struct pthread_condattr_t {
	long __sig;
	char __opaque[8];
} pthread_condattr_t;

typedef struct pthread_rwlockattr_t {
	long __sig;
	char __opaque[16];
} pthread_rwlockattr_t;
]]
end

ffi.cdef[[
typedef struct pthread_key_t { unsigned long _; } pthread_key_t;

struct sched_param {
	int sched_priority;
	char __opaque[4];
};

unsigned int usleep(uint32_t seconds);
]]

local _PTHREAD_MUTEX_SIG_init  = 0x32AAABA7
local _PTHREAD_COND_SIG_init   = 0x3CB0B1BB
local _PTHREAD_RWLOCK_SIG_init = 0x2DA8B3B4

local H = {}

H.EINTR     = 4
H.EBUSY     = 16
H.ETIMEDOUT = 60

function H.PTHREAD_RWLOCK_INITIALIZER() return _PTHREAD_RWLOCK_SIG_init end
function H.PTHREAD_MUTEX_INITIALIZER()  return _PTHREAD_MUTEX_SIG_init end
function H.PTHREAD_COND_INITIALIZER()   return _PTHREAD_COND_SIG_init end

function H.sleep(s)
	ffi.C.usleep(s * 10^6)
end

return H
