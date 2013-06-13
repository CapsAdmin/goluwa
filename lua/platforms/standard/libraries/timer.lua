local timer = _G.timer or {} 

timer.CurrentTimers = {}
timer.SimpleTimers = {}
timer.Thinkers = {}

function timer.Simple(time, callback, obj)
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

	local realtime = os.clock() + time

	timer.SimpleTimers[tostring(callback) .. tostring(time)] = {
		callback = callback,
		realtime = realtime,
	}
end

function timer.Thinker(callback, speed)
	table.insert(timer.Thinkers, {callback = callback, speed = speed})
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
		return xpcall(self.callback, OnError, ...)
	end
	function META:SetNextThink(num)
		self.realtime = os.clock() + num
	end
	function META:Remove()
		timer.CurrentTimers[self.id] = nil
	end
	
	timer.TimerMeta = META
end

function timer.Create(id, time, repeats, callback, run_now)
	check(time, "number")
	check(repeats, "number")
	check(callback, "function")

	id = tostring(id)
	time = math.abs(time)
	repeats = math.max(repeats, 0)

	local realtime = os.clock() + time
	local obj = timer.CurrentTimers[id] or {}
		
		obj.realtime = realtime
		obj.id = id
		obj.time = time
		obj.repeats = repeats
		obj.callback = callback
		obj.times_ran = 1
		obj.paused = false
		
		setmetatable(obj, timer.TimerMeta)
	
	timer.CurrentTimers[id] = obj
	
	if run_now then
		callback(repeats-1)
		obj.repeats = obj.repeats - 1
	end
	
	return obj
end

function timer.Update()
	local cur = os.clock()

	for id, data in pairs(timer.SimpleTimers) do
		if data.realtime < cur then
			xpcall(data.callback, OnError)
			timer.SimpleTimers[id] = nil
		end
	end	
	
	for id, obj in pairs(timer.CurrentTimers) do
		if not obj:IsPaused() and obj.realtime < cur then
			local ran, msg = obj:Call(obj:GetRepeats() - 1)
			
			if ran then
				if msg == "stop" then
					obj:Remove()
				end
				if msg == "restart" then
					obj:SetRepeats(1)
				end
				if type(msg) == "number" then
					obj:SetNextThink(msg)
				end
			else
				logn(id, msg)
			end

			if obj.times_ran == obj.repeats then
				obj:Remove()
			else
				obj:SetRepeats(obj:GetRepeats() + 1)
				obj:SetNextThink(obj:GetInterval())
			end
		end
	end
	
	for key, data in ipairs(timer.Thinkers) do	
		if data.speed then
			for i=0, data.speed do
				if data.callback() ~= nil then
					table.remove(timer.Thinkers, key)
					break
				end	
			end
		else
			if data.callback() ~= nil then
				table.remove(timer.Thinkers, key)
			end
		end
	end
end

local temp = {}

function INTERVAL(seconds)
	if not temp[seconds] or (temp[seconds] + seconds) < os.clock() then
		temp[seconds] = os.clock()
		return true
	end
	return false
end

wait = INTERVAL

_G.Thinker = timer.Thinker

return timer