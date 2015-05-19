
--pthread cdefs for winpthreads, libpthread/Linux and OSX.
--Only stuff found in all supported implementations is defined.

local ffi = require'ffi'
local lib = 'pthread.pthread_h_'..ffi.os:lower()
local H = require(lib)

ffi.cdef[[
struct timespec {
	time_t tv_sec;
	long tv_nsec;
};

int pthread_create(pthread_t *th, const pthread_attr_t *attr, void *(*func)(void *), void *arg);
real_pthread_t pthread_self(void);
int pthread_equal(pthread_t th1, pthread_t th2);
void pthread_exit(void *retval);
int pthread_join(pthread_t, void **retval);
int pthread_detach(pthread_t);
int pthread_getschedparam(pthread_t th, int *pol, struct sched_param *param);
int pthread_setschedparam(pthread_t th, int pol, const struct sched_param *param);

int pthread_attr_init(pthread_attr_t *attr);
int pthread_attr_destroy(pthread_attr_t *attr);
int pthread_attr_setdetachstate(pthread_attr_t *a, int flag);
int pthread_attr_setinheritsched(pthread_attr_t *a, int flag);
int pthread_attr_setschedparam(pthread_attr_t *attr, const struct sched_param *param);
int pthread_attr_setstackaddr(pthread_attr_t *attr, void *stack);
int pthread_attr_setstacksize(pthread_attr_t *attr, size_t size);

int pthread_mutex_init(pthread_mutex_t *m, const pthread_mutexattr_t *a);
int pthread_mutex_destroy(pthread_mutex_t *m);
int pthread_mutex_lock(pthread_mutex_t *m);
int pthread_mutex_unlock(pthread_mutex_t *m);
int pthread_mutex_trylock(pthread_mutex_t *m);

int pthread_mutexattr_init(pthread_mutexattr_t *a);
int pthread_mutexattr_destroy(pthread_mutexattr_t *a);
int pthread_mutexattr_settype(pthread_mutexattr_t *a, int type);

int pthread_cond_init(pthread_cond_t *cv, const pthread_condattr_t *a);
int pthread_cond_destroy(pthread_cond_t *cv);
int pthread_cond_broadcast(pthread_cond_t *cv);
int pthread_cond_signal(pthread_cond_t *cv);
int pthread_cond_wait(pthread_cond_t *cv, pthread_mutex_t *external_mutex);
int pthread_cond_timedwait(pthread_cond_t *cv, pthread_mutex_t *external_mutex, const struct timespec *t);

int pthread_rwlock_init(pthread_rwlock_t *l, const pthread_rwlockattr_t *attr);
int pthread_rwlock_destroy(pthread_rwlock_t *l);
int pthread_rwlock_wrlock(pthread_rwlock_t *l);
int pthread_rwlock_rdlock(pthread_rwlock_t *l);
int pthread_rwlock_trywrlock(pthread_rwlock_t *l);
int pthread_rwlock_tryrdlock(pthread_rwlock_t *l);
int pthread_rwlock_unlock(pthread_rwlock_t *l);

int sched_yield(void);
int sched_get_priority_min(int pol);
int sched_get_priority_max(int pol);

int nanosleep(const struct timespec *request, struct timespec *remain);
]]

return H
