local timer = _G.timer or {} 

do -- frame time
	local frame_time = 0.1

	function timer.GetFrameTime()
		return frame_time
	end

	-- used internally in main_loop.lua
	function timer.SetFrameTime(dt)
		frame_time = dt
	end
end

do -- frame time
	local frame_number = 0

	function timer.GetFrameNumber()
		return frame_number
	end

	-- used internally in main_loop.lua
	function timer.SetFrameNumber(num)
		frame_number = num
	end
end

do -- elapsed time (avanved from frame time)
	local elapsed_time = 0

	function timer.GetElapsedTime()
		return elapsed_time
	end
	
	-- used internally in main_loop.lua
	function timer.SetElapsedTime(num)
		elapsed_time = num
	end
end

do -- system time (independent from elapsed_time)
	function timer.GetSystemTime()
		return os.clock()
	end
end

do -- server time (synchronized across client and server)
	local server_time = 0
	
	function timer.SetServerTime(time)
		server_time = time
	end
		
	function timer.GetServerTime()
		return server_time
	end
end

do -- profile
	local stack = {}

	function timer.Start(str)
		table.insert(stack, {str = str, time = timer.GetSystemTime()})
	end
	
	function timer.Stop(no_print)
		local time = timer.GetSystemTime()
		local data = table.remove(stack)
		local delta = time - data.time
		
		if not no_print then
			logf("%s: %s\n", data.str, math.round(delta, 3))
		end
		
		return delta
	end
end

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

do 
	local get = not_implemented
	
	if WINDOWS then
		ffi.cdef("int GetTickCount();")
		
		get = function() return ffi.C.GetTickCount() end
	end
	
	if LINUX then
		ffi.cdef[[	
			typedef long time_t;
			typedef long suseconds_t;

			struct timezone {
				int tz_minuteswest;     /* minutes west of Greenwich */
				int tz_dsttime;         /* type of DST correction */
			};
			
			struct timeval {
				time_t      tv_sec;     /* seconds */
				suseconds_t tv_usec;    /* microseconds */
			};
			
			int gettimeofday(struct timeval *tv, struct timezone *tz);
		]]
		
		local temp = ffi.new("struct timeval[1]")
		get = function() ffi.C.gettimeofday(temp, nil) return temp[0].tv_usec*100 end
	end
	
	timer.GetTickCount = get
end


do -- time in ms
	local get = not_implemented
	
	if WINDOWS then
		ffi.cdef("bool QueryPerformanceCounter(uint64_t *out);")
		ffi.cdef("bool QueryPerformanceFrequency(uint64_t *out);")
		
		local t1 = ffi.new("uint64_t[1]")
		local t2 = ffi.new("uint64_t[1]")
		local freq = ffi.new("uint64_t[1]")
		local time = 0
		
		local init
		
		get = function() 
			
			if not init then
				ffi.C.QueryPerformanceFrequency(freq)
				ffi.C.QueryPerformanceCounter(t1)
				init = true
			end
		
			ffi.C.QueryPerformanceCounter(t2) 
			
			time = (tonumber(t2[0] - t1[0]) * 1000 / tonumber(freq[0])) / 1000
		
			return time
		end
	end
	
	if LINUX then
		--ffi.cdef"struct timeval {uint32_t sec, uint32_t usec}; int gettimeofday(struct timeval *tv, void *);"
		
		local t1 = ffi.new("struct timeval[1]")
		local t2 = ffi.new("struct timeval[1]")
		local time = 0
		
		local init
		
		get = function() 
			
			if not init then
				ffi.C.gettimeofday(t1)
				init = true
			end
		
			ffi.C.gettimeofday(t2) 
			
			time = tonumber(t2[0].sec - t1[0].sec) * 1000
			time = time + tonumber(t2[0].usec - t1[0].usec) / 1000
		
			return time
		end
	end
	
	timer.GetTimeMS = get
end

do -- sleep
	local sleep = not_implemented
	
	if WINDOWS then
		ffi.cdef("void Sleep(int ms)")
		sleep = function(ms) ffi.C.Sleep(ms) end
	end

	if LINUX then
		ffi.cdef("void usleep(unsigned int ns)")
		sleep = function(ms) ffi.C.usleep(ms*1000) end
	end
	
	timer.Sleep = sleep
end
 
return timer
