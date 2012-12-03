local timer = {} 

timer.CurrentTimers = {}

function timer.GetTable()
	return timer.CurrentTimers
end

function timer.Simple(time, callback)
	check(time, "number", "function")
	check(callback, "function", "nil")

	if not callback then
		callback = time
		time = 0
	end

	local realtime = os.clock() + time

	timer.CurrentTimers["SimpleTimer:" .. tostring(callback) .. tostring(time)] = {
		callback = callback,
		realtime = realtime,
	}
end

timer.Thinkers = {}

function timer.Thinker(callback, speed)
	table.insert(timer.Thinkers, {callback = callback, speed = speed})
end

function timer.Create(tag, time, repeats, callback, run_now)
	check(time, "number")
	check(repeats, "number")
	check(callback, "function")

	tag = tostring(tag)
	time = math.abs(time)
	repeats = math.max(repeats, 0)


	local realtime = os.clock() + time
	timer.CurrentTimers[tag] = {
		realtime = realtime,
		tag = tag,
		time = time,
		repeats = repeats,
		callback = callback,
		times_ran = 1,
	}

	if run_now then
		callback()
	end
end

function timer.Remove(tag)
	tag = tostring(tag)
	timer.CurrentTimers[tag] = nil
end

function timer.Update()
	local cur = os.clock()

	for tag, data in pairs(timer.CurrentTimers) do
		if data.realtime < cur then
			if data.times_ran then
				local ran, msg = pcall(data.callback, data.times_ran - 1)
				if ran then
					if msg == "stop" then
						timer.CurrentTimers[tag] = nil
					end
					if msg == "restart" then
						data.times_ran = 1
					end
					if type(msg) == "number" then
						data.realtime = os.clock() + msg
					end
				else
					print(tag, msg)
				end

				if data.times_ran == data.repeats then
					timer.CurrentTimers[tag] = nil
				else
					data.times_ran = data.times_ran + 1
					data.realtime = os.clock() + data.time
				end
			else
				local ran, err = pcall(data.callback, 0)

				if not ran then
					print(tag, err)
				end

				timer.CurrentTimers[tag] = nil
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

_G.Thinker = timer.Thinker

return timer