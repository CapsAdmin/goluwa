local pthread = require'pthread'
local lua = require'luastate'
local ffi = require'ffi'
local glue = require'glue'
local pp = require'pp'
io.stdout:setvbuf'no'

--helpers

local function addr(cdata)
	return tonumber(ffi.cast('intptr_t', ffi.cast('void*', cdata)))
end

local function ptr(ctype, p)
	return ffi.cast(ctype, ffi.cast('void*', p))
end

--globals

local function test_priority_range()
	local pr0 = pthread.min_priority()
	local pr1 = pthread.max_priority()
	print('priority range: ', pr0, pr1)
	assert(pr1 >= pr0)
end

--threads

--test pthread_create(), pthread_join()
--create a new Lua state and a new thread, and run a worker function
--in that state and thread.
local function create_thread(worker, args, attrs)
	local state = lua.open()
	state:openlibs()
	state:push(function(worker, args)
		local ffi = require'ffi'
		local function pass(...)
			_G.retvals = {n = select('#', ...), ...}
		end
		local function wrapper()
			pass(worker(args))
		end
		local wrapper_cb = ffi.cast('void *(*)(void *)', wrapper)
		return tonumber(ffi.cast('intptr_t', wrapper_cb))
	end)
	local wrapper_cb_ptr = ffi.cast('void *', state:call(worker, args))
	local thread = pthread.new(wrapper_cb_ptr, attrs)
	local function join()
		local status = thread:join()
		state:getglobal'retvals'
		local t = state:get(-1) or {n = 0}
		state:close()
		return status, unpack(t, 1, t.n)
	end
	return join, thread
end

--test pthread_self(), pthread_equal()
local function test_thread_self_equal()
	local join, th1 = create_thread(function()
		local pthread = require'pthread'
		local ffi = require'ffi'
		local th = pthread.self()
		pthread.sleep(0.1)
		return ffi.string(th, ffi.sizeof(th))
	end)
	--pthread.sleep(0.1)
	local _, ths = join()
	local th2 = ffi.new'pthread_t'
	ffi.copy(th2, ths, #ths)
	assert(th1:equal(th2))
end

local function test_priorities()
	create_thread(function() end, nil,
		{priority = pthread.max_priority()})()
	create_thread(function() end, nil,
		{priority = pthread.min_priority()})()
end

--speed/leak long test
local function stress_test(times)
	io.stdout:write'creating many threads '
	for i=1,times do
		local joins = {}
		local n=10
		for i=1,n do
			local join, th = create_thread(function(i)
				io.stdout:write(i..' ')
			end, i)
			table.insert(joins, join)
		end
		for i=n,1,-1 do
			joins[i]()
		end
		collectgarbage()
	end
	print()
end

--mutexes

local function test_mutex(times, threads)
	local m = pthread.mutex{type = 'recursive'}

	local joins = {}
	local n = ffi.new'int[1]'

	for i=1,threads do
		local join = create_thread(function(args)
			local m, times, n = unpack(args)
			local ffi = require'ffi'
			local pthread = require'pthread'
			local function ptr(ctype, p)
				return ffi.cast(ctype, ffi.cast('void*', p))
			end
			local m = ptr('pthread_mutex_t*', m)
			n = ptr('int*', n)
			local p=0
			for i=1,times do
				while not m:trylock() do
					p=p+1
				end
				n[0]=n[0]+1
				m:unlock()
			end
			return p

		end, {addr(m), times, addr(n)})

		table.insert(joins, join)
	end

	print'mutex trylocks:'
	local np = 0
	for i=1,threads do
		local _, p = joins[i]()
		print('', 'thread ', i, p)
		np = np + p
	end
	assert(n[0] == threads * times)
	print(string.format('failed trylocks: %d%%', np / n[0] * 100))
	m:free()
end

--test cond. vars

local function test_cond_var(times, timeout)
	local mutex = pthread.mutex()
	local cond = pthread.cond()

	local n = ffi.new('double[1]', -times/2)

	local join1 = create_thread(function(args)
		local mutex, cond, times, timeout, n = unpack(args)
		local ffi = require'ffi'
		local pthread = require'pthread'
		local function ptr(ctype, p)
			return ffi.cast(ctype, ffi.cast('void*', p))
		end
		local mutex = ptr('pthread_mutex_t*', mutex)
		local cond = ptr('pthread_cond_t*', cond)
		n = ptr('double*', n)

		local p, t = 0, 0
		for i=1,times do
			mutex:lock()
			if n[0] == 100 then
				mutex:unlock()
				break
			end
			while n[0] < 0 do
				if not cond:timedwait(mutex, os.time() + timeout) then
					t = t + 1
				else
					--p = p + 1
				end
			end
			if n[0] >= 0 then
				p = p + 1
			end
			mutex:unlock()
		end

		return p, t
	end, {addr(mutex), addr(cond), times, timeout, addr(n)})

	local join2 = create_thread(function(args)
		local mutex, cond, times, n = unpack(args)
		local ffi = require'ffi'
		local pthread = require'pthread'
		local function ptr(ctype, p)
			return ffi.cast(ctype, ffi.cast('void*', p))
		end
		local mutex = ptr('pthread_mutex_t*', mutex)
		local cond = ptr('pthread_cond_t*', cond)
		n = ptr('double*', n)

		local function sign(x) return x >= 0 end
		for i=1,times do
			mutex:lock()
			n[0] = math.sin(i/10)
			if n[0] >= 0 then
				cond:broadcast()
			end
			mutex:unlock()
		end

		--signal exit to other thread
		mutex:lock()
		n[0] = 100
		cond:broadcast()
		mutex:unlock()

	end, {addr(mutex), addr(cond), times, addr(n)})

	local _, p, t = join1()
	join2()

	print(string.format('cond. var: caught: %d%%, timeouts: %d%%',
		p/times * 100, t/times * 100))

	cond:free()
	mutex:free()
end

--test r/w locks

local function test_rwlock(readtimes, readthreads, writetimes, writethreads)
	local rwlock = pthread.rwlock()

	local joins = {}
	local n = ffi.new'int[1]'

	for i = 1, readthreads + writethreads do
		local reader = i > writethreads
		local join = create_thread(function(args)
			local rwlock, times, n, reader = unpack(args)
			local ffi = require'ffi'
			local pthread = require'pthread'
			local function ptr(ctype, p)
				return ffi.cast(ctype, ffi.cast('void*', p))
			end
			local rwlock = ptr('pthread_rwlock_t*', rwlock)
			n = ptr('int*', n)
			local p=0
			for i = 1, times do
				if reader then
					while not rwlock:tryreadlock() do
						p=p+1
					end
					rwlock:unlock()
				else
					while not rwlock:trywritelock() do
						p=p+1
					end
					n[0]=n[0]+1
					rwlock:unlock()
				end
			end
			return p

		end, {
			addr(rwlock),
			reader and readtimes or writetimes,
			addr(n),
			reader,
		})

		table.insert(joins, join)
	end

	print'rwlock trylocks:'
	local np = 0
	for i = 1, readthreads + writethreads do
		local _, p = joins[i]()
		print('', (i > writethreads and 'read' or 'write')..' thread ', i, p)
		np = np + p
	end
	assert(n[0] == writethreads * writetimes)
	print(string.format('failed trywritelocks: %d%%', np / n[0] * 100))

	rwlock:free()
end

--test sleep or nanosleep

local function test_sleep(s, ss, func)
	func = func or pthread.sleep
	io.stdout:write(string.format(
		'sleeping %gs in %gs increments...', s, ss))
	for i=1,s*1/ss do
		func(ss)
	end
	print'done'
end

local function test_all()
	test_priority_range()
	test_thread_self_equal()
	test_priorities()
	stress_test(10)
	test_mutex(50000, 10)
	test_cond_var(100000, 1)
	test_rwlock(50000, 10, 50000, 1)
	test_sleep(0.25, 0.05, pthread.sleep)
	test_sleep(0.25, 0.05, pthread.nanosleep)
end

test_all()
