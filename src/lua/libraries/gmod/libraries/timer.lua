local timer = gine.env.timer

function timer.Create(identifier, delay, repetitions, func)
	return event.Timer("gine_" .. tostring(identifier), delay, repetitions, func)
end

function timer.Destroy(identifier)
	return event.RemoveTimer("gine_" .. tostring(identifier))
end

timer.Remove = timer.Destroy

function timer.Simple(delay, func)
	return event.Delay(delay, func)
end
