local timer = {}

timer.current = {}

function timer.Create(identifier, delay, repetitions, func)
	return event.CreateTimer("gmod_" .. tostring(identifier), delay, repetitions, func)
end

function timer.Destroy(identifier)
	return event.RemoveTimer("gmod_" .. tostring(identifier))
end

function timer.Simple(delay, func)
	return event.Delay(delay, func)
end

function timer.Exists() end
function timer.UnPause() end
function timer.Toggle() end
function timer.Adjust() end
function timer.Stop() end
function timer.Start() end
function timer.Remove() end
function timer.Check() end
function timer.RepsLeft() end
function timer.TimeLeft() end
function timer.Pause() end

return timer