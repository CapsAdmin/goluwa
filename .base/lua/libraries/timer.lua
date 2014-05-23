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
	local high_precision_clock = os.clock
	
	function timer.SetSystemTimeClock(func)
		high_precision_clock = func
	end
		
	function timer.GetSystemTime()
		return high_precision_clock()
	end
end

do -- server time (synchronized across client and server)
	local server_time = 0
	
	function timer.SetServerTime(time)
		server_time = time
	end
		
	function timer.GetSystemTime()
		return server_time
	end
end

return timer