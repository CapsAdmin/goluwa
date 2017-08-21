local info = assert(debug.getinfo(1), "debug.getinfo(1) returns nothing")
local init_lua_path = info.source
local internal_addon_name = assert(init_lua_path:match("@(.+)/lua/init.lua"), "could not find internal addon name from " .. init_lua_path)

pvars = runfile("lua/libraries/pvars.lua") -- like cvars
commands = runfile("lua/libraries/commands.lua") -- console command type interface for running in repl, chat, etc

runfile("../" .. internal_addon_name .. "/lua/libraries/extensions/*")

if CURSES then
	repl = runfile("lua/libraries/repl.lua") -- read eval print loop using curses
	if not repl then
		CURSES = false
	end
end

expression = runfile("lua/libraries/expression.lua") -- used by chat and editor to run small and safe lua expressions
autocomplete = runfile("lua/libraries/autocomplete.lua") -- mainly used in console and chatsounds
profiler = runfile("lua/libraries/profiler.lua") -- for profiling
language = runfile("lua/libraries/language.lua") _G.L = language.LanguageString -- L"options", for use in gui menus and such.

runfile("lua/libraries/prototype/ecs_entity.lua")
runfile("lua/libraries/prototype/base_ecs_component.lua")

_G.P = profiler.ToggleTimer
_G.I = profiler.ToggleInstrumental
_G.S = profiler.ToggleStatistical

steam = runfile("lua/libraries/steam/steam.lua") -- utilities for dealing with steam, the source engine and steamworks

if NETWORK then
	runfile("../" .. internal_addon_name .. "/lua/libraries/network/network.lua") -- medium (?) level communication between server and client
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
	gui.Initialize()
end

entities = runfile("lua/libraries/entities/entities.lua") -- entity component system

pvars.Initialize()
pvars.Setup("text_editor_path", false)

--steam.InitializeWebAPI()

if CURSES then
	repl.Initialize()
end

local rate_cvar = pvars.Setup(
	"system_fps_max",
	-1,
	function(rate)
		if window and window.IsOpen() then
			if rate == 0 then
				render.SwapInterval(true)
			else
				render.SwapInterval(false)
			end
		end
	end,
	"-1\t=\trun as fast as possible\n 0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)"
)

event.AddListener("Update", "rate_limit", function()
	local rate = rate_cvar:Get()

	if rate > 0 then
		system.Sleep(math.floor(1/rate * 1000))
	end
end)

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

system.ExecuteArgs()
