pvars = runfile("lua/libraries/pvars.lua") -- permanent variables
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
end

if PHYSICS then
	physics = runfile("!lua/libraries/physics/physics.lua") -- physics
	if not physics then
		PHYSICS = false
	end
end

entities = runfile("lua/libraries/entities/entities.lua") -- entity component system

event.AddListener("Initialize", function()
	pvars.Initialize()

	pvars.Setup("system_texteditor_path", false)
	pvars.Setup("system_tasks_enabled", false, function(val) tasks.enabled = val end)
	
	if CLI then tasks.enabled = true end
	
	--steam.InitializeWebAPI()
	
	if PHYSICS then
		physics.Initialize()
	end
	
	if CLI then
		event.AddListener("Update", "cli", function()
			if not tasks.IsBusy() and not sockets.active_sockets[1] then
				system.ShutDown()
			end
		end)
	end
end)

if WINDOW then
	event.AddListener("MainLoopStart", function()
		window.Open()
	end)

	event.AddListener("Update", "title_bar_fps", function()
		system.UpdateTitlebarFPS()
	end)
end

if GRAPHICS then
	event.AddListener("WindowOpened", function()
		render2d.Initialize()
		fonts.Initialize()
		gfx.Initialize()

		if render2d.IsReady() then
			vfs.AutorunAddons("graphics/")
		end
	end)
end