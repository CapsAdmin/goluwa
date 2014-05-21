local event = _G.event or {}

e.EVENT_DESTROY = "??|___EVENT_DESTROY___|??" -- unique what

event.active = event.active or {}
event.errors = event.errors or {}
event.profil = event.profil or {}
event.destroy_tag = e.EVENT_DESTROY

function event.AddListener(a, b, c, d, e)
	local type_, unique, func, on_error, priority, self_arg, remove_after_one_call, self_arg_with_callback

	if type(b) == "table" and type(a) == "string" then
		type_ = a
		if type(c) == "function" then
			self_arg_with_callback = true
			func = c
		else
			func = b[a]
		end
		self_arg = b
	elseif type(a) == "string" then
		type_ = a
		func = c
	end	
	
	if type_ and not func and type(b) == "function" then
		func = b
		unique = tostring(func)
		remove_after_one_call = true
	else
		unique = b
	end
	
	if not unique then
		local info = debug.getinfo(3)
		if info.source:sub(1, 1) == "@" then
			unique = info.source
		else
			unique = "temp"
		end
	end
	
	
	if type(d) == "number" then
		priority = d
	elseif type(d) == "function" then
		on_error = d
	end
	
	if type(e) == "number" then
		priority = e
	else
		priority = 0
	end
		
	check(type_, "string")
	--check(func, "function")
		
	event.RemoveListener(type_, unique)
	
	if not func then return end
	
	event.active[type_] = event.active[type_] or {}
	table.insert(
		event.active[type_],
		{
			func = func,
			on_error = on_error,
			priority = priority or 0,
			unique = unique,
			self_arg = self_arg,
			remove_after_one_call = remove_after_one_call,
			self_arg_with_callback = self_arg_with_callback,
		}
	)
		
	event.SortByPriority()
end

function event.RemoveListener(a, b)
	local type_, unique

	if type(b) == "table" and type(a) == "string" then
		type_ = a
		unique = tostring(b)
	elseif type(a) == "string" then
		type_ = a
		unique = b
	end

	if unique ~= nil and event.active[type_] then
		for key, val in pairs(event.active[type_]) do
			if unique == val.unique then
				event.active[type_][key] = nil
			end
		end
	else
		--logn(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end
	
	event.SortByPriority()
end

function event.SortByPriority()
	for key, tbl in pairs(event.active) do
		local new = {}
		for k,v in pairs(tbl) do table.insert(new, v) end
		table.sort(new, function(a, b) return a.priority > b.priority end)
		event.active[key] = new
	end
end

function event.GetTable()
	return event.active
end

local status, a,b,c,d,e,f,g,h
local time = 0

function event.UserDataCall(udata, type_, ...)	
	if udata:IsValid() then
		local func = udata[type_]
		
		
		if type(func) == "function" then
			local args = {xpcall(func, system.OnError, udata, ...)}
			if args[1] then
				table.remove(args, 1)
				return unpack(args)
			else
				if hasindex(udata) and udata.Type and udata.ClassName then
					logf("scripted class %s %q errored: %s\n", udata.Type, udata.ClassName, args[2])
				else
					logf(args[2])
				end
			end
		end
	end
end

local _event
local _unique
local unique

function event.Call(type, ...)
	if event.debug then
		event.call_count = event.call_count or 0
		print(event.call_count, type, ...)
		event.call_count = event.call_count + 1
	end
	if event.active[type] then
		for key, data in ipairs(event.active[type]) do
			
			if data.self_arg then
				if data.self_arg:IsValid() then
					if data.self_arg_with_callback then
						status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or system.OnError, ...)
					else
						status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or system.OnError, data.self_arg, ...)
					end
				else
					event.RemoveListener(type, data.unique)
					event.active[type][key] = nil
					event.SortByPriority()
					logf("event [%q][%q] removed because self is invalid\n", type, data.unique)
					return
				end
			else
				status, a,b,c,d,e,f,g,h = xpcall(data.func, data.on_error or system.OnError, ...)
			end
			
			if a == event.destroy_tag or data.remove_after_one_call then
				event.RemoveListener(type, data.unique)
			else
				if status == false then		
					if _G.type(data.on_error) == "function" then
						data.on_error(a, type, data.unique)
					else
						event.RemoveListener(type, data.unique)
						logf("event [%q][%q] removed\n", type, data.unique)
					end

					event.errors[type] = event.errors[type] or {}
					table.insert(event.errors[type], {unique = data.unique, error = a, time = os.date("*t")})
				end

				if a ~= nil then
					return a,b,c,d,e,f,g,h
				end
			end
		end
	end
end

function event.GetErrorHistory()
	return event.errors
end

function event.DisableAll()
	if event.enabled == false then
		logn("events are already disabled.")
	else
		event.enabled = true
		event.__backup_events = table.copy(event.GetTable())
		table.empty(event.GetTable())
	end
end

function event.EnableAll()
	if event.enabled == true then
		logn("events are already enabled.")
	else
		event.enabled = false
		table.merge(event.GetTable(), event.__backup_events)
		event.__backup_events = nil
	end
end

function event.Dump()
	local h=0
	for k,v in pairs(event.GetTable()) do
		logn("> "..k.." ("..table.Count(v).." events):")
		for name,data in pairs(v) do
			h=h+1
			logn("   \""..name.."\" \t "..tostring(debug.getinfo(data.func).source)..":")
			logn(" Line:"..tostring(debug.getinfo(data.func).linedefined))
		end
		logn("")
	end
	logn("")
	logn(">>> Total events: "..h..".")
end

do -- timers
	event.timers = event.timers or {}

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
			return xpcall(self.callback, system.OnError, ...)
		end
		function META:SetNextThink(num)
			self.realtime = timer.GetElapsedTime() + num
		end
		function META:Remove()
			self.__remove_me = true
		end
		
		event.TimerMeta = META
	end

	function event.CreateThinker(callback, speed, in_seconds, run_now)	
		if run_now and callback() ~= nil then
			return
		end
		
		event.timers[callback] = {
			type = "thinker", 
			realtime = timer.GetElapsedTime(), 
			callback = callback, 
			speed = speed, 
			in_seconds = in_seconds
		}
	end

	function event.Delay(time, callback, obj)
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

		event.timers[callback] = {
			type = "delay", 
			callback = callback, 
			realtime = timer.GetElapsedTime() + time
		}
	end

	function event.CreateTimer(id, time, repeats, callback, run_now)
		check(time, "number")
		check(repeats, "number")
		check(callback, "function")

		id = tostring(id)
		time = math.abs(time)
		repeats = math.max(repeats, 0)

		local data = event.timers[id] or {}
		
		data.type = "timer"
		data.realtime = timer.GetElapsedTime() + time
		data.id = id
		data.time = time
		data.repeats = repeats
		data.callback = callback
		data.times_ran = 1
		data.paused = false
		
		event.timers[id] = data
		
		setmetatable(data, event.TimerMeta)	
		
		if run_now then
			callback(repeats-1)
			data.repeats = data.repeats - 1
		end
		
		return data
	end

	function event.RemoveTimer(id)
		event.timers[id] = nil
	end

	function event.UpdateTimers(...)
		local cur = timer.GetElapsedTime()
				
		for key, data in pairs(event.timers) do
			if data.type == "thinker" then
				if data.in_seconds and data.speed then
					if data.realtime < cur then
						local ok, res = xpcall(data.callback, system.OnError)
						if not ok or res ~= nil then
							event.timers[key] = nil
						end
						data.realtime = cur + data.speed
					end
				elseif data.speed then
					for i=0, data.speed do
						local ok, res = xpcall(data.callback, system.OnError)
						if not ok or res ~= nil then
							event.timers[key] = nil
							break
						end	
					end
				else
					local ok, res = xpcall(data.callback, system.OnError)
					if not ok or res ~= nil then
						event.timers[key] = nil
					end
				end
			elseif data.type == "delay" then
				if data.realtime < cur then
					xpcall(data.callback, system.OnError)
					event.timers[key] = nil
					break
				end
			elseif data.type == "timer" then
				if not data.paused and data.realtime < cur then
					local ran, msg = data:Call(data.times_ran - 1, ...)
					
					if ran then
						if msg == "stop" then
							event.timers[key] = nil
							break
						end
						if msg == "restart" then
							data.times_ran = 1
						end
						if type(msg) == "number" then
							data.realtime = cur + msg
						end
					else
						logn(data.id, msg)
						event.timers[key] = nil
					end

					if data.times_ran == data.repeats then
						event.timers[key] = nil
					else
						data.times_ran = data.times_ran + 1
						data.realtime = cur + data.time
					end
				end
			end
		end
	end
end

event.events = setmetatable({}, {
	__index = function(_, unique)
		return setmetatable({}, {
			__newindex = function(_, event_name, func)
				event.AddListener(event_name, unique, func)
			end,
		})
	end,
	__newindex = function(_, event_name, func)
		event.AddListener(event_name, nil, func)
	end,
})

return event