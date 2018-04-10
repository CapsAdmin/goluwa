local timer = gine.env.timer

function timer.Create(id, delay, repetitions, func)
	return event.Timer("gine_" .. tostring(id), delay, repetitions, function() func() end)
end

function timer.Destroy(id)
	return event.RemoveTimer("gine_" .. tostring(id))
end

timer.Remove = timer.Destroy

function timer.Stop(id)
	return event.StopTimer("gine_" .. tostring(id))
end

function timer.Start(id)
	return event.StartTimer("gine_" .. tostring(id))
end

function timer.Exists(id)
	return event.IsTimer("gine_" .. tostring(id))
end

function timer.Simple(delay, func)
	return event.Delay(delay, function() func() end)
end
