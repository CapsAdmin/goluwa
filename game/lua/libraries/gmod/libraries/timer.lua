local timer = gine.env.timer

function timer.Create(id, delay, repetitions, func)
	return _G.timer.Repeat("gine_" .. tostring(id), delay, repetitions, function()
		func()
	end)
end

function timer.Destroy(id)
	return _G.timer.RemoveTimer("gine_" .. tostring(id))
end

timer.Remove = timer.Destroy

function timer.Stop(id)
	return _G.timer.StopTimer("gine_" .. tostring(id))
end

function timer.Start(id)
	return _G.timer.StartTimer("gine_" .. tostring(id))
end

function timer.Exists(id)
	return _G.timer.IsTimer("gine_" .. tostring(id))
end

function timer.Simple(delay, func)
	return _G.timer.Delay(delay, function()
		func()
	end)
end