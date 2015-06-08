--pthread.h from winpthreads 0.5.0 from mingw-w64 4.9.2

local ffi = require'ffi'
assert(ffi.os == 'Windows', 'Platform not Windows')

if ffi.abi'32bit' then
	ffi.cdef'typedef int32_t time_t;'
else
	ffi.cdef'typedef int64_t time_t;'
end

ffi.cdef[[
enum {
	PTHREAD_CREATE_DETACHED = 0x04,
	PTHREAD_CANCEL_ENABLE = 0x01,
	PTHREAD_CANCEL_DISABLE = 0,
	PTHREAD_CANCEL_DEFERRED = 0,
	PTHREAD_CANCEL_ASYNCHRONOUS = 0x02,
	PTHREAD_CANCELED = 0xDEADBEEF,
	PTHREAD_EXPLICIT_SCHED = 0,
	PTHREAD_PROCESS_PRIVATE = 0,
	PTHREAD_MUTEX_NORMAL = 0,
	PTHREAD_MUTEX_ERRORCHECK = 1,
	PTHREAD_MUTEX_RECURSIVE = 2,
	SCHED_OTHER = 0,
	PTHREAD_STACK_MIN = 8192,
};

typedef uintptr_t real_pthread_t;
typedef struct { real_pthread_t _; } pthread_t;

struct sched_param {
  int sched_priority;
};
typedef struct pthread_attr_t {
    unsigned p_state;
    void *stack;
    size_t s_size;
    struct sched_param param;
} pthread_attr_t;
typedef struct pthread_mutex_t { void *_; } pthread_mutex_t;
typedef struct pthread_cond_t { void *_; } pthread_cond_t;
typedef struct pthread_rwlock_t { void *_; } pthread_rwlock_t;
typedef struct pthread_mutexattr_t { unsigned _; } pthread_mutexattr_t;
typedef struct { int _; } pthread_condattr_t;
typedef struct { int _; } pthread_rwlockattr_t;

typedef struct pthread_key_t { unsigned _; } pthread_key_t;

void Sleep(uint32_t ms);
]]

local H = {}

H.EINTR     = 4
H.EBUSY     = 16
H.ETIMEDOUT = 138

local GENERIC_INITIALIZER = ffi.cast('void*', -1)
function H.PTHREAD_MUTEX_INITIALIZER()  return GENERIC_INITIALIZER end
function H.PTHREAD_COND_INITIALIZER()   return GENERIC_INITIALIZER end
function H.PTHREAD_RWLOCK_INITIALIZER() return GENERIC_INITIALIZER end

function H.sleep(s)
	ffi.C.Sleep(s * 1000)
end

return H
