---
tagline: POSIX threads
platforms: mingw, linux, osx
---

## `local pthread = require'pthread'`

A lightweight ffi binding of POSIX threads. Includes [winpthreads] from
MinGW-w64 for Windows support (uses the pthread library found on the
system otherwise).

[winpthreads]: http://sourceforge.net/p/mingw-w64/mingw-w64/ci/master/tree/mingw-w64-libraries/winpthreads/

## API

----------------------------------------------- ----------------------------------
__threads__
pthread.new(func_ptr[, attrs]) -> th            create and start a new thread
th:equal(other_th) -> true | false              check if two threads are equal
th:join() -> status                             wait for a thread to finish
th:detach()                                     detach a thread
th:priority(new_priority)                       set thread priority
th:priority() -> priority                       get thread priority
pthread.min_priority() -> priority              get min. priority
pthread.max_priority() -> priority              get max. priority
__mutexes__
pthread.mutex([mattrs]) -> mutex                create a mutex
mutex:free()                                    free a mutex
mutex:lock()                                    lock a mutex
mutex:unlock()                                  unlock a mutex
mutex:trylock() -> true | false                 lock a mutex or return false
__condition variables__
pthread.cond() -> cond                          create a condition variable
cond:free()                                     free the condition variable
cond:broadcast()                                broadcast
cond:signal()                                   signal
cond:wait(mutex)                                wait
cond:timedwait(mutex, time) -> true | false     wait with os.time() timeout
__read/write locks__
pthread.rwlock() -> rwlock                      create a r/w lock
rwlock:free()                                   free a r/w lock
rwlock:writelock()                              lock for writing
rwlock:readlock()                               lock for reading
rwlock:trywritelock() -> true | false           try to lock for writing
rwlock:tryreadlock() -> true | false            try to lock for reading
rwlock:unlock()                                 unlock the r/w lock
__scheduler__
pthread.yield()                                 relinquish control to the scheduler
pthread.sleep(seconds)                          suspend the current thread
pthread.nanosleep(seconds[, remain]) -> remain  same, but return remaining time
----------------------------------------------- ----------------------------------

> `func_ptr` is a C callback declared as: `void *(*func_ptr)(void *arg)`.
Its return value is returned by `th:join()`.

> All functions raise errors but error messages are not included
and error codes are platform specific (use google).

## Howto

Use it with [luastate]:

~~~{.lua}
local ffi = require'ffi'
local pthread = require'pthread'
local luastate = require'luastate'

--make a new Lua state
local state = luastate.open()

--load the standard libraries into the Lua state
state:openlibs()

--create a callback into the Lua state to be called from a different thread
state:push(function()

	--up-values are not pushed, so we have to require ffi again
	local ffi = require'ffi'

	--this is our worker function that will run in a different thread
	local function worker()
		--print() is thread-safe so no need to guard it
		print'Hello from thread!'
	end

	--make a ffi callback frame to call into our worker function
	local worker_cb = ffi.cast('void *(*)(void *)', worker)

	--get the callback pointer out of the Lua state as a number,
	--because we can't pass cdata between Lua states.
	return tonumber(ffi.cast('intptr_t', worker_cb))
end)

--call the function that we just pushed into the Lua state
--to get the callback pointer
local worker_cb_ptr = ffi.cast('void *', state:call())

--create a thread which will start running automatically
local thread = pthread.new(worker_cb_ptr)

--wait for the thread to finish
thread:join()

--close the Lua state
state:close()
~~~

## Portability notes

POSIX is a standard hostile to binary compatibility, resulting in each
implementation having a different ABI. Moreso, different implementations
cover different parts of the API.

The list of currently supported pthreads implementations are:

  * winpthreads 0.5.0 from Mingw-w64 4.9.2 (tested on WinXP 32bit and 64bit)
  * libpthread from gnu libc (tested on Ubuntu 10.04, x86 and x64)
  * libpthread from OSX (tested on OSX 10.9 with 32bit and 64bit binaries)

Only functionality that is common _to all_ of the above is available.
Winpthreads dumbs down the API the most (no process-shared objects,
no real-time extensions, etc.), but OSX too (no timed waits, no semaphores, no barriers, etc.) and even Linux (setting priority levels needs root access).
Functions that don't make sense with Lua (pthread_once) or are stubs
in one or more implementations (pthread_setconcurrency) or are unsafe
to use with Lua states (killing, cancelation) were also dropped. All in all
you get a pretty thin library with just the basics covered.
The good news is that this is really all you need for most apps.
A more comprehensive but still portable threading library would have to
be implemented on top of native synchronization primitives. In any case,
I cannot personally support extra functionality, but patches welcome.

Next are a few tips to get a rough idea of the portability situation.

To find out (part of) the truth about API coverage, you can start by
checking the exported symbols on the pthreads library on each platform
and compare them:

	On Linux:

		mgit syms /lib/libpthread.so.0 | \
			grep '^pthread' > pthread_syms_linux.txt

	On OSX:

		(mgit syms /usr/lib/libpthread.dylib
		mgit syms /usr/lib/system/libsystem_pthread.dylib) | \
			grep '^pthread' > pthread_syms_osx.txt

	On Windows:

		mgit syms bin\mingw64\libwinpthread-1.dll | \
			grep ^^pthread > pthread_syms_mingw.txt

	Compare the results (the first column tells the number of platforms
	that a symbol was found on):

		sort pthread_syms_* | uniq -c | sort -nr

To find out the differences in ABI and supported flags, you can preprocess
the headers on different platforms and compare them:

	mgit preprocess pthread.h sched.h semaphore.h > pthread_h_<platform>.lua

The above will use gcc to preprocess the headers and generate a
(very crude, mind you) Lua cdef template file that you can use
as a starting point for a binding and/or to check ABI differences.

Next step is to look at the source code for winpthreads and find out what
is really implemented (and how).
