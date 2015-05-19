
--POSIX threads binding.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'
local lib = ffi.os == 'Windows' and 'libwinpthread-1' or 'pthread'
local C = ffi.load(lib)
local M = {C = C}
local H = require'pthread.pthread_h'

--helpers

local function check(ok, ret)
	if ok then return end
	error(string.format('pthread error: %d\n%s', ret, debug.traceback()), 3)
end

--return-value checker for '0 means OK' functions
local function checkz(ret)
	check(ret == 0, ret)
end

--return-value checker for 'try' functions
local function checkbusy(ret)
	check(ret == 0 or ret == H.EBUSY, ret)
	return ret == 0
end

--return-value checker for 'timedwait' functions
local function checktimeout(ret)
	check(ret == 0 or ret == H.ETIMEDOUT, ret)
	return ret == 0
end

--os.time() time to timespec conversion
local function timespec(time)
	local int, frac = math.modf(time)
	return ffi.new('struct timespec', int, frac * 10^9)
end

--threads

--create a new thread with a C callback. to use with a Lua callback,
--create a Lua state and a ffi callback pointing to a function inside
--the state, and use that as func_cb.
function M.new(func_cb, attrs)
	local thread = ffi.new'pthread_t'
	local attr
	if attrs then
		attr = ffi.new'pthread_attr_t'
		C.pthread_attr_init(attr)
		if attrs.detached then --not very useful, see M.detach()
			checkz(C.pthread_attr_setdetachstate(attr, C.PTHREAD_CREATE_DETACHED))
		end
		if attrs.priority then --useless on Linux for non-root users
			checkz(C.pthread_attr_setinheritsched(attr, C.PTHREAD_EXPLICIT_SCHED))
			local param = ffi.new'struct sched_param'
			param.sched_priority = attrs.priority
			checkz(C.pthread_attr_setschedparam(attr, param))
		end
		if attrs.stackaddr then
			checkz(C.pthread_attr_setstackaddr(attr, attrs.stackaddr))
		end
		if attrs.stacksize then
			checkz(C.pthread_attr_setstacksize(attr, attrs.stacksize))
		end
	end
	local ret = C.pthread_create(thread, attr, func_cb, nil)
	if attr then
		C.pthread_attr_destroy(attr)
	end
	checkz(ret)
	return thread
end

--current thread
function M.self()
	return ffi.new('pthread_t', C.pthread_self())
end

--test two thread objects for equality.
function M.equal(t1, t2)
	return C.pthread_equal(t1, t2) ~= 0
end

--wait for a thread to finish.
function M.join(thread)
	local status = ffi.new'void*[1]'
	checkz(C.pthread_join(thread, status))
	return status[0]
end

--set a thread loose (not very useful because it's hard to know when
--a detached thread has died so that another thread can clean up after it,
--and a Lua state can't free itself up from within either).
function M.detach(thread)
	checkz(C.pthread_detach(thread))
end

--set thread priority: level is between min_priority() and max_priority().
--NOTE: on Linux, min_priority() == max_priority() == 0 for SCHED_OTHER
--(which is the only cross-platform SCHED_* value), and SCHED_RR needs root
--which is a major usability hit, so it's not included.
function M.priority(thread, sched, level)
	assert(not sched or sched == 'other')
	local param = ffi.new'sched_param'
	if level then
		param.sched_priority = level
		checkz(C.pthread_setschedparam(thread, C.SCHED_OTHER, param))
	else
		checkz(C.pthread_getschedparam(thread, C.SCHED_OTHER, param))
		return param.sched_priority
	end
end
function M.min_priority(sched)
	assert(not sched or sched == 'other')
	return C.sched_get_priority_min(C.SCHED_OTHER)
end
function M.max_priority(sched)
	assert(not sched or sched == 'other')
	return C.sched_get_priority_max(C.SCHED_OTHER)
end

ffi.metatype('pthread_t', {
		__index = {
			equal = M.equal,
			join = M.join,
			detach = M.detach,
			priority = M.priority,
		},
	})

--mutexes

local mutex = {}

local mtypes = {
	normal     = C.PTHREAD_MUTEX_NORMAL,
	errorcheck = C.PTHREAD_MUTEX_ERRORCHECK,
	recursive  = C.PTHREAD_MUTEX_RECURSIVE,
}

function M.mutex(mattrs)
	local mutex = ffi.new('pthread_mutex_t', H.PTHREAD_MUTEX_INITIALIZER())
	local mattr
	if mattrs then
		mattr = ffi.new'pthread_mutexattr_t'
		checkz(C.pthread_mutexattr_init(mattr))
		if mattrs.type then
			local mtype = assert(mtypes[mattrs.type], 'invalid mutex type')
			checkz(C.pthread_mutexattr_settype(mattr, mtype))
		end
	end
	local ret = C.pthread_mutex_init(mutex, mattr)
	if mattr then
		C.pthread_mutexattr_destroy(mattr)
	end
	checkz(ret)
	ffi.gc(mutex, mutex.free)
	return mutex
end

function mutex.free(mutex)
	checkz(C.pthread_mutex_destroy(mutex))
	ffi.gc(mutex, nil)
end

function mutex.lock(mutex)
	checkz(C.pthread_mutex_lock(mutex))
end

function mutex.unlock(mutex)
	checkz(C.pthread_mutex_unlock(mutex))
end


function mutex.trylock(mutex)
	return checkbusy(C.pthread_mutex_trylock(mutex))
end

ffi.metatype('pthread_mutex_t', {__index = mutex})

--conditions

local cond = {}

function M.cond()
	local cond = ffi.new('pthread_cond_t', H.PTHREAD_COND_INITIALIZER())
	checkz(C.pthread_cond_init(cond, nil))
	return ffi.gc(cond, cond.free)
end

function cond.free(cond)
	checkz(C.pthread_cond_destroy(cond))
	ffi.gc(cond, nil)
end

function cond.broadcast(cond)
	checkz(C.pthread_cond_broadcast(cond))
end

function cond.signal(cond)
	checkz(C.pthread_cond_signal(cond))
end

function cond.wait(cond, mutex)
	checkz(C.pthread_cond_wait(cond, mutex))
end

--NOTE: `time` is time per os.time(), not a time period.
function cond.timedwait(cond, mutex, time)
	return checktimeout(C.pthread_cond_timedwait(cond, mutex, timespec(time)))
end

ffi.metatype('pthread_cond_t', {__index = cond})

--read/write locks

local rwlock = {}

function M.rwlock()
	local rwlock = ffi.new('pthread_rwlock_t', H.PTHREAD_RWLOCK_INITIALIZER())
	checkz(C.pthread_rwlock_init(rwlock, nil))
	return ffi.gc(rwlock, rwlock.free)
end

function rwlock.free(rwlock)
	checkz(C.pthread_rwlock_destroy(rwlock))
	ffi.gc(rwlock, nil)
end

function rwlock.writelock(rwlock)
	checkz(C.pthread_rwlock_wrlock(rwlock))
end

function rwlock.readlock(rwlock)
	checkz(C.pthread_rwlock_rdlock(rwlock))
end

function rwlock.trywritelock(rwlock)
	return checkbusy(C.pthread_rwlock_trywrlock(rwlock))
end

function rwlock.tryreadlock(rwlock)
	return checkbusy(C.pthread_rwlock_tryrdlock(rwlock))
end

function rwlock.unlock(rwlock)
	checkz(C.pthread_rwlock_unlock(rwlock))
end

ffi.metatype('pthread_rwlock_t', {__index = rwlock})

local SC = ffi.os == 'Windows' and C or ffi.C
function M.yield()
	checkz(SC.sched_yield())
end

--sleep

M.sleep = H.sleep

function M.nanosleep(s, remain)
	remain = remain or ffi.new'struct timespec'
	local ret = C.nanosleep(timespec(s), remain)
	while ret == H.EINTR do
		ret = C.nanosleep(remain, remain)
	end
	checkz(ret)
	return remain
end

return M
