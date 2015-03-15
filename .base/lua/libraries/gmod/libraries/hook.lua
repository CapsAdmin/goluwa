local gmod = ... or gmod
local hook = gmod.env.hook

function hook.Add(eventName, identifier, func)
	return event.AddListener(eventName, identifier, func)
end

function hook.Remove(eventName, identifier)
	return event.RemoveListener(eventName, identifier)
end

function hook.Run(eventName, ...)
	return event.Call(eventName, ...)
end