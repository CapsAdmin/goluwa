local profiler2 = require("nattlua.other.profiler2")
local profiler = {}
local should_run = true

if _G.ON_EDITOR_SAVE or not jit then should_run = false end

function profiler.Start()
	if not should_run then return end

	profiler2.EasyStart()
end

function profiler.Stop()
	if not should_run then return end

	profiler2.EasyStop()
end

function profiler.PushZone(name--[[#: string]])
	if not should_run then return end

	profiler2.PushSection(name)
end

function profiler.PopZone()
	if not should_run then return end

	profiler2.PopSection()
end

return profiler