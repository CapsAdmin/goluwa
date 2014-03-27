local timer = _G.timer or {} 

timer.Timers = timer.Timers or {}

timer.clock = timer.clock or os.clock
timer.GetTime = timer.clock
timer.total_time = 0

do -- profiling
	local time

	function timer.Measure(str)
		if time then
			local delta = timer.GetTime() - time
			
			time = nil
			
			if str then	
				logf("%s: %s", str, math.round(delta, 3))
			end
			
			return delta
		else
			time = timer.GetTime()
		end
	end
end

function timer.GetFrameTime()
	return timer.frame_time or 0.1
end

function timer.GetTotalTime()
	return timer.total_time
end

do -- timer meta
	local META = {}
	META.__index = META
	
	function META:Pause()
		self.paused = true
	end
	function META:Start()
		self.paused = false
	end
	function META:IsPaused()
		return self.paused
	end
	function META:SetRepeats(num)
		self.times_ran = num
	end
	function META:GetRepeats()
		return self.times_ran
	end
	function META:SetInterval(num)
		self.time = num
	end
	function META:GetInterval()
		return self.time
	end
	function META:SetCallback(func)
		self.callback = func
	end
	function META:GetCallback()
		return self.callback
	end
	function META:Call(...)
		return xpcall(self.callback, mmyy.OnError, ...)
	end
	function META:SetNextThink(num)
		self.realtime = timer.clock() + num
	end
	function META:Remove()
		self.__remove_me = true
	end
	
	timer.TimerMeta = META
end

function timer.Thinker(callback, speed, in_seconds, run_now)	
	if run_now and callback() ~= nil then
		return
	end
	
	timer.Timers[callback] = {
		type = "thinker", 
		realtime = timer.clock(), 
		callback = callback, 
		speed = speed, 
		in_seconds = in_seconds
	}
end

function timer.Delay(time, callback, obj)
	check(time, "number", "function")
	check(callback, "function", "nil")

	if not callback then
		callback = time
		time = 0
	end
	
	if hasindex(obj) and obj.IsValid then
		local old = callback
		callback = function(...)
			if obj:IsValid() then
				return old(...)
			end
		end
	end

	timer.Timers[callback] = {
		type = "delay", 
		callback = callback, 
		realtime = timer.clock() + time
	}
end

function timer.Create(id, time, repeats, callback, run_now)
	check(time, "number")
	check(repeats, "number")
	check(callback, "function")

	id = tostring(id)
	time = math.abs(time)
	repeats = math.max(repeats, 0)

	local data = timer.Timers[id] or {}
	
	data.type = "timer"
	data.realtime = timer.clock() + time
	data.id = id
	data.time = time
	data.repeats = repeats
	data.callback = callback
	data.times_ran = 1
	data.paused = false
	
	timer.Timers[id] = data
	
	setmetatable(data, timer.TimerMeta)	
	
	if run_now then
		callback(repeats-1)
		data.repeats = data.repeats - 1
	end
	
	return data
end

function timer.Update(...)
	local cur = timer.clock()
			
	for key, data in pairs(timer.Timers) do
		if data.type == "thinker" then
			if data.in_seconds and data.speed then
				if data.realtime < cur then
					local ok, res = xpcall(data.callback, mmyy.OnError)
					if not ok or res ~= nil then
						timer.Timers[key] = nil
					end
					data.realtime = cur + data.speed
				end
			elseif data.speed then
				for i=0, data.speed do
					local ok, res = xpcall(data.callback, mmyy.OnError)
					if not ok or res ~= nil then
						timer.Timers[key] = nil
					end	
				end
			else
				local ok, res = xpcall(data.callback, mmyy.OnError)
				if not ok or res ~= nil then
					timer.Timers[key] = nil
				end
			end
		elseif data.type == "delay" then
			if data.realtime < cur then
				xpcall(data.callback, mmyy.OnError)
				timer.Timers[key] = nil
				break
			end
		elseif data.type == "timer" then
			if not data.paused and data.realtime < cur then
				local ran, msg = data:Call(data.times_ran - 1, ...)
				
				if ran then
					if msg == "stop" then
						data.__remove_me = true
					end
					if msg == "restart" then
						data.times_ran = 1
					end
					if type(msg) == "number" then
						data.realtime = cur + msg
					end
				else
					logn(data.id, msg)
					timer.Timers[key] = nil
				end

				if data.times_ran == data.repeats then
					timer.Timers[key] = nil
				else
					data.times_ran = data.times_ran + 1
					data.realtime = cur + data.time
				end
			end
		end
	end
end

_G.Thinker = timer.Thinker

return timer