local timer = {}
timer.timers = timer.timers or {}

function timer.Thinker(callback, run_now, frequency, iterations, id)
	if run_now and callback() ~= nil then return end

	local info = {
		key = id or callback,
		key = callback,
		type = "thinker",
		realtime = 0,
		callback = callback,
	}

	if iterations == true then
		info.fps = frequency or 120
		info.fps = 1 / info.fps
	else
		info.frequency = frequency or 0
		info.iterations = iterations or 1
	end

	list.insert(timer.timers, info)
end

function timer.Delay(time, callback, id, obj, ...)
	if not callback then
		callback = time
		time = 0
	end

	time = time or 0

	if id then
		for _, v in ipairs(timer.timers) do
			if v.key == id then
				v.realtime = system.GetElapsedTime() + time
				return
			end
		end
	end

	if obj and has_index(obj) and obj.IsValid then
		local old = callback
		callback = function(...)
			if obj:IsValid() then return old(...) end
		end
	end

	list.insert(
		timer.timers,
		{
			key = id or callback,
			type = "delay",
			callback = callback,
			realtime = system.GetElapsedTime() + time,
			args = {...},
		}
	)
end

function timer.Repeat(id, time, repeats, callback, run_now, error_callback)
	if not callback then
		callback = repeats
		repeats = 0
	end

	id = tostring(id)
	time = math.abs(time)
	repeats = math.max(repeats, 0)
	local data

	for _, v in ipairs(timer.timers) do
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
	data.error_callback = error_callback or function(id, msg)
		logn(id, msg)
	end
	list.insert(timer.timers, data)

	if run_now then
		callback(repeats - 1)
		data.repeats = data.repeats - 1
	end
end

function timer.RemoveTimer(id)
	for k, v in ipairs(timer.timers) do
		if v.key == id then
			list.remove(timer.timers, k)
			--profiler.RemoveSection(v.id)
			return true
		end
	end
end

function timer.StopTimer(id)
	for k, v in ipairs(timer.timers) do
		if v.key == id then
			v.realtime = 0
			v.times_ran = 1
			v.paused = true
			return true
		end
	end
end

function timer.StartTimer(id)
	for k, v in ipairs(timer.timers) do
		if v.key == id then
			v.paused = false
			return true
		end
	end
end

function timer.IsTimer(id)
	for k, v in ipairs(timer.timers) do
		if v.key == id then return true end
	end
end

local remove_these = {}

function timer.UpdateTimers(a_, b_, c_, d_, e_)
	local cur = system.GetElapsedTime()

	for i, data in ipairs(timer.timers) do
		if data.type == "thinker" then
			if data.fps then
				local time = 0

				repeat
					local start = system.GetTime()
					local ok, res = system.pcall(data.callback)

					if system.GetFrameTime() >= data.fps then break end

					if not ok or res ~= nil then
						list.insert(remove_these, i)

						break
					end

					time = time + (system.GetTime() - start)				
				until time >= data.fps
			else
				if data.realtime < cur then
					local fps = ((cur + data.frequency) - data.realtime)
					local extra_iterations = math.ceil(fps / data.frequency) - 2

					if extra_iterations == math.huge then extra_iterations = 1 end

					local errored = false

					for _ = 1, data.iterations + extra_iterations do
						local ok, res = system.pcall(data.callback)

						if not ok or res ~= nil then
							errored = true

							break
						end
					end

					if errored then list.insert(remove_these, i) end

					data.realtime = cur + data.frequency
				end
			end
		elseif data.type == "delay" then
			if data.realtime < cur then
				if not data.args then
					system.pcall(data.callback)
				else
					system.pcall(data.callback, unpack(data.args))
				end

				list.insert(remove_these, i)
			end
		elseif data.type == "timer" then
			if not data.paused and data.realtime < cur then
				local ran, msg = system.pcall(data.callback, data.times_ran - 1, a_, b_, c_, d_, e_)

				if ran then
					if msg == "stop" then list.insert(remove_these, i) end

					if msg == "restart" then data.times_ran = 1 end

					if type(msg) == "number" then data.realtime = cur + msg end
				else
					if data.error_callback(data.id, msg) == nil then
						list.insert(remove_these, i)
					--profiler.RemoveSection(data.id)
					end
				end

				if data.times_ran == data.repeats then
					list.insert(remove_these, i)
				--profiler.RemoveSection(data.id)
				else
					data.times_ran = data.times_ran + 1
					data.realtime = cur + data.time
				end
			end
		end
	end

	if remove_these[1] then
		for _, v in ipairs(remove_these) do
			--print(timer.timers[v].type)
			timer.timers[v] = nil
		end

		list.fix_indices(timer.timers)
		list.clear(remove_these)
	end
end

event.AddListener("Update", "timers", timer.UpdateTimers, {on_error = system.OnError})
return timer