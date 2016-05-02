local event = _G.event or {}

event.active = event.active or {}
event.destroy_tag = {}

e.EVENT_DESTROY = event.destroy_tag

local function sort_events()
	for key, tbl in pairs(event.active) do
		local new = {}
		for _, v in pairs(tbl) do table.insert(new, v) end
		table.sort(new, function(a, b) return a.priority > b.priority end)
		event.active[key] = new
	end
end

function event.AddListener(event_type, id, callback, config)
	if type(event_type) == "table" then
		config = event_type
	end

	if not callback and type(id) == "function" then
		callback = id
		id = nil
	end

	config = config or {}

	config.event_type = config.event_type or event_type
	config.id = config.id or id
	config.callback = config.callback or callback
	config.priority = config.priority or 0

	-- useful for initialize events
	if config.id == nil then
		config.id = tostring(callback)
		config.remove_after_one_call = true
	end

	config.print_str = config.event_type .. "->" .. tostring(config.id)

	event.RemoveListener(config.event_type, config.id)

	event.active[config.event_type] = event.active[config.event_type] or {}

	table.insert(event.active[config.event_type], config)

	sort_events()
end

function event.RemoveListener(event_type, id)

	if type(event_type) == "table" then
		id = id or event_type.id
		event_type = event_type or event_type.event_type
	end

	if id ~= nil and event.active[event_type] then
		for index, val in pairs(event.active[event_type]) do
			if id == val.id then
				-- we can't use table.remove here because this might be called during
				-- an event which will mess up the ipairs loop and skip all the other events
				-- of the same type
				event.active[event_type][index] = nil

				profiler.RemoveSection(val.print_str)

				do -- repair the table
					local temp = {}

					for k, v in pairs(event.active[event_type]) do
						table.insert(temp, v)
						event.active[event_type][k] = nil
					end

					for _, v in pairs(temp) do
						table.insert(event.active[event_type], v)
					end
				end

				break
			end
		end
	else
		--logn(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end

	sort_events()
end

function event.Call(event_type, a_, b_, c_, d_, e_)
	local status, a,b,c,d,e

	if event.active[event_type] then
		for index, data in ipairs(event.active[event_type]) do
			if data.self_arg then
				if data.self_arg:IsValid() then
					if data.self_arg_with_callback then
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
					else
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, data.self_arg, a_, b_, c_, d_, e_)
					end
				else
					event.RemoveListener(event_type, data.id)

					event.active[event_type][index] = nil
					sort_events()
					llog("[%q][%q] removed because self is invalid", event_type, data.unique)
					return
				end
			else
				status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
			end

			if a == event.destroy_tag or data.remove_after_one_call then
				event.RemoveListener(event_type, data.id)
			else
				if status == false then
					if type(data.on_error) == "function" then
						data.on_error(a, event_type, data.id)
					else
						event.RemoveListener(event_type, data.id)
						llog("[%q][%q] removed", event_type, data.id)
					end
				end

				if a ~= nil then
					return a,b,c,d,e
				end
			end
		end
	end
end

do -- timers
	event.timers = event.timers or {}

	function event.Thinker(callback, run_now, frequency, iterations, id)
		if run_now and callback() ~= nil then
			return
		end

		local info = {
			key = id or callback,
			key = callback,
			type = "thinker",
			realtime = 0,
			callback = callback,
		}

		if iterations == true then
			info.fps = frequency or 120
			info.fps = 1/info.fps
		else
			info.frequency = frequency or 0
			info.iterations = iterations or 1
		end

		table.insert(event.timers, info)
	end

	function event.Delay(time, callback, id, obj, ...)
		if not callback then
			callback = time
			time = 0
		end

		if id then
			for _, v in ipairs(event.timers) do
				if v.key == id then
					v.realtime = system.GetElapsedTime() + (time or 0)
					return
				end
			end
		end

		if obj and hasindex(obj) and obj.IsValid then
			local old = callback
			callback = function(...)
				if obj:IsValid() then
					return old(...)
				end
			end
		end

		table.insert(event.timers, {
			key = callback,
			type = "delay",
			callback = callback,
			realtime = system.GetElapsedTime() + (time or 0),
			args = {...},
		})
	end

	function event.Timer(id, time, repeats, callback, run_now)
		if not callback then
			callback = repeats
			repeats = 0
		end

		id = tostring(id)
		time = math.abs(time)
		repeats = math.max(repeats, 0)

		local data

		for _, v in ipairs(event.timers) do
			if v.key == id then
				data = v
				break
			end
		end

		data = data or {}

		data.key = id
		data.type = "timer"
		data.realtime = 0
		data.id = id
		data.time = time
		data.repeats = repeats
		data.callback = callback
		data.times_ran = 1
		data.paused = false

		table.insert(event.timers, data)

		if run_now then
			callback(repeats-1)
			data.repeats = data.repeats - 1
		end
	end

	function event.RemoveTimer(id)
		for k, v in ipairs(event.timers) do
			if v.key == id then
				table.remove(event.timers, k)
				profiler.RemoveSection(v.id)
				break
			end
		end
	end

	local remove_these = {}

	function event.UpdateTimers(a_, b_, c_, d_, e_)
		local cur = system.GetElapsedTime()

		for i, data in ipairs(event.timers) do
			if data.type == "thinker" then
				if data.fps then
					local time = 0
					repeat
						local start = system.GetElapsedTime()
						local ok, res = system.pcall(data.callback)

						if system.GetFrameTime() >= data.fps then break end

						if not ok or res ~= nil then
							table.insert(remove_these, i)
							break
						end

						time = time + (system.GetElapsedTime() - start)
					until time >= data.fps
				else
					if data.realtime < cur then
						local fps = ((cur + data.frequency) - data.realtime)
						local extra_iterations = math.ceil(fps/data.frequency) - 2
						if extra_iterations == math.huge then extra_iterations = 1 end

						local errored = false

						for _ = 1, data.iterations + extra_iterations do
							local ok, res = system.pcall(data.callback)
							if not ok or res ~= nil then
								errored = true
								break
							end
						end

						if errored then
							table.insert(remove_these, i)
							break
						end

						data.realtime = cur + data.frequency
					end
				end
			elseif data.type == "delay" then
				if data.realtime < cur then
					system.pcall(data.callback, unpack(data.args))
					table.insert(remove_these, i)
					break
				end
			elseif data.type == "timer" then
				if not data.paused and data.realtime < cur then
					local ran, msg = system.pcall(data.callback, data.times_ran - 1, a_, b_, c_, d_, e_)

					if ran then
						if msg == "stop" then
							table.insert(remove_these, i)
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
						table.insert(remove_these, i)
						profiler.RemoveSection(data.id)
						break
					end

					if data.times_ran == data.repeats then
						table.insert(remove_these, i)
						profiler.RemoveSection(data.id)
						break
					else
						data.times_ran = data.times_ran + 1
						data.realtime = cur + data.time
					end
				end
			end
		end

		if remove_these[1] then
			for _, v in ipairs(remove_these) do
				--print(event.timers[v].type)
				event.timers[v] = nil
			end
			table.fixindices(event.timers)
			table.clear(remove_these)
		end
	end

	event.AddListener("Update", "timers", event.UpdateTimers)
end

return event