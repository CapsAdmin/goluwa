--pthread.h from GCC 4.8

local ffi = require'ffi'
assert(ffi.os == 'Linux', 'Platform not Linux')

ffi.cdef[[
typedef long int time_t;

enum {
	PTHREAD_CREATE_DETACHED = 1,
	PTHREAD_CANCEL_ENABLE = 0,
	PTHREAD_CANCEL_DISABLE = 1,
	PTHREAD_CANCEL_DEFERRED = 0,
	PTHREAD_CANCEL_ASYNCHRONOUS = 1,
	PTHREAD_CANCELED = -1,
	PTHREAD_EXPLICIT_SCHED = 1,
	PTHREAD_PROCESS_PRIVATE = 0,
	PTHREAD_MUTEX_NORMAL = 0,
	PTHREAD_MUTEX_ERRORCHECK = 2,
	PTHREAD_MUTEX_RECURSIVE = 1,
	SCHED_OTHER = 0,
	PTHREAD_STACK_MIN = 16384,
};

typedef unsigned long int real_pthread_t;
typedef struct { real_pthread_t _; } pthread_t;
]]

if ffi.abi'32bit' then
ffi.cdef[[
typedef struct pthread_attr_t {
	union {
		char __size[36];
		long int __align;
	};
} pthread_attr_t;

typedef struct pthread_mutex_t {
	union {
		char __size[24];
		long int __align;
	};
} pthread_mutex_t;

typedef struct pthread_cond_t {
	union {
		char __size[48];
		long long int __align;
	};
} pthread_cond_t;

typedef struct pthread_rwlock_t {
	union {
		char __size[32];
		long int __align;
	};
} pthread_rwlock_t;
]]
else --x64
ffi.cdef[[
typedef struct pthread_attr_t {
	union {
		char __size[56];
		long int __align;
	};
} pthread_attr_t;

typedef struct pthread_mutex_t {
	union {
		char __size[40];
		long int __align;
	};
} pthread_mutex_t;

typedef struct pthread_cond_t {
	union {
		char __size[48];
		long long int __align;
	};
} pthread_cond_t;

typedef struct pthread_rwlock_t {
	union {
		char __size[56];
		long int __align;
	};
} pthread_rwlock_t;
]]
end

ffi.cdef[[
typedef struct pthread_mutexattr_t {
	union {
		char __size[4];
		int __align;
	};
} pthread_mutexattr_t;

typedef struct pthread_condattr_t {
	union {
		char __size[4];
		int __align;
	};
} pthread_condattr_t;

typedef struct pthread_rwlockattr_t {
	union {
		char __size[8];
		long int __align;
	};
} pthread_rwlockattr_t;

typedef struct pthread_key_t { unsigned int _; } pthread_key_t;

struct sched_param {
	int sched_priority;
};

unsigned int usleep(unsigned int seconds);
]]

local H = {}

H.EINTR     = 4
H.EBUSY     = 16
H.ETIMEDOUT = 110

local function zeroinit() return end
H.PTHREAD_MUTEX_INITIALIZER  = zeroinit
H.PTHREAD_RWLOCK_INITIALIZER = zeroinit
H.PTHREAD_COND_INITIALIZER   = zeroinit

function H.sleep(s)
	ffi.C.usleep(s * 10^6)
end

return H
