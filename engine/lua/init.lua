pvars = runfile("lua/libraries/pvars.lua") -- like cvars
commands = runfile("lua/libraries/commands.lua") -- console command type interface for running in repl, chat, etc

runfile("!lua/libraries/extensions/*")

expression = runfile("lua/libraries/expression.lua") -- used by chat and editor to run small and safe lua expressions
autocomplete = runfile("lua/libraries/autocomplete.lua") -- mainly used in console and chatsounds
language = runfile("lua/libraries/language.lua") _G.L = language.LanguageString -- L"options", for use in gui menus and such.

runfile("lua/libraries/prototype/ecs_entity.lua")
runfile("lua/libraries/prototype/base_ecs_component.lua")

_G.P = profiler.ToggleTimer
_G.I = profiler.ToggleInstrumental
_G.S = profiler.ToggleStatistical
_G.LOOM = profiler.ToggleLoom

steam = runfile("lua/libraries/steam/steam.lua") -- utilities for dealing with steam, the source engine and steamworks

if NETWORK then
	runfile("!lua/libraries/network/network.lua") -- medium (?) level communication between server and client
	packet = runfile("lua/libraries/network/packet.lua") -- high level communication between server and client
	message = runfile("lua/libraries/network/message.lua") -- high level communication between server and client

	nvars = runfile("lua/libraries/network/nvars.lua") -- variable synchronization between server and client
	clients = runfile("lua/libraries/network/clients.lua") -- high level wrapper for a connected client
end

if GRAPHICS then
	runfile("lua/libraries/graphics/gfx/video.lua", gfx)
	runfile("lua/libraries/graphics/gfx/particles.lua", gfx)
	runfile("lua/libraries/graphics/gfx/markup.lua", gfx)
	runfile("lua/libraries/graphics/gfx/polygon_3d.lua", gfx)
	gui = runfile("lua/libraries/graphics/gui/gui.lua")
	render3d = runfile("lua/libraries/graphics/render3d/render3d.lua")
	--gui.Initialize()
end

if PHYSICS then
	physics = runfile("!lua/libraries/physics/physics.lua") -- physics
	if not physics then
		PHYSICS = false
	end
end

entities = runfile("lua/libraries/entities/entities.lua") -- entity component system

pvars.Initialize()

pvars.Setup("system_texteditor_path", false)
pvars.Setup("system_tasks_enabled", false, function(val) tasks.enabled = val end)

if CLI then tasks.enabled = true end

--steam.InitializeWebAPI()

if PHYSICS then
	physics.Initialize()
end

local rate_cvar = pvars.Setup2({
	key = "system_fps_max",
	default = -1,
	modify = function(num) if num < 1 and num ~= 0 then return -1 end return num end,
	callback = function(rate)
		if window and window.IsOpen() then
			if rate == 0 then
				render.GetWindow():SwapInterval(true)
			else
				render.GetWindow():SwapInterval(false)
			end
		end
	end,
	help = "-1\t=\trun as fast as possible\n 0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)",
})

local battery_limit = pvars.Setup("system_battery_limit", true)

do
	local rate = rate_cvar:Get()

	event.Timer("rate_limit", 0.1, 0, function()
		rate = rate_cvar:Get()

		-- todo: user is changing properties in game
		if rate > 0 and GRAPHICS and gui and gui.world and gui.world.options then
			rate = math.max(rate, 10)
		end

		if window and battery_limit:Get() and system.IsUsingBattery() and system.GetBatteryLevel() < 0.95 then
			render.GetWindow():SwapInterval(true)
			if system.GetBatteryLevel() < 0.20 then
				rate = 10
			end
			if not window.IsFocused() then
				rate = 5
			end
		end

		if SERVER then
			rate = 66
		end
	end)

	event.AddListener("FrameEnd", "rate_limit", function()
		if rate > 0 then
			system.Sleep(math.floor(1/rate * 1000))
		end
	end)
end

if TMUX then
	logn("== tmux session started ==")
	logn("run 'detach' here to detach the session")
	logn("run 'exit' here or ctrl c twice to exit goluwa")
	logn("run './goluwa attach' in your terminal reattach to this goluwa tmux session")
end

if TMUX then
	event.AddListener("ShutDown", "tmux", function()
		os.execute("tmux kill-session")
	end)
end

event.AddListener("Initialize", function()
	system.ExecuteArgs()
end)

if CLI then
	event.AddListener("VFSPreWrite", "log_write", function(path, data)
		if path:startswith("data/") or vfs.GetPathInfo(path).full_path:startswith(e.DATA_FOLDER) then
			return
		end

		if path:startswith(system.GetWorkingDirectory()) then
			path = path:sub(#system.GetWorkingDirectory() + 1)
		end

		logn("[vfs] writing ", path, " - ", utility.FormatFileSize(#data))
	end)

	event.AddListener("Update", "cli", function()
		if not tasks.IsBusy() and not sockets.active_sockets[1] then
			system.ShutDown()
		end
	end)
end