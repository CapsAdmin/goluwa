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
	function timer.GetSystemTime()
		return os.clock()
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

return timer