local profile_start_time = os.clock()

pvars.Initialize()
pvars.Setup("text_editor_path", false)

if SOCKETS then
	sockets.Initialize()
end

if WINDOW then
	local profile_start_time = os.clock()
	if window.Open() then
		if VERBOSE_STARTUP then
			llog("opening window took %s seconds", os.clock() - profile_start_time)
		end

		if GRAPHICS then
			render2d.Initialize()
			fonts.Initialize()
			gfx.Initialize()
		end
	else
		GRAPHICS = false
		WINDOW = false
	end
end

if SOUND then
	audio.Initialize()
end

if PHYSICS then
	physics.Initialize()
end

--steam.InitializeWebAPI()

if NETWORK then
	enet.Initialize()

	if CLIENT then
		clients.local_client = clients.Create("unconnected")
	end
end

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
-- this will skip the src folder though
vfs.MountAddons(e.ROOT_FOLDER)

system._CheckCreatedEnv()

if VERBOSE_STARTUP then
	llog("initializing libraries took %s seconds", os.clock() - profile_start_time)
end

do -- autorun
	local profile_start_time = os.clock()

	-- call goluwa/*/lua/init.lua if it exists
	vfs.InitAddons()

	-- load everything in goluwa/*/lua/autorun/*
	vfs.AutorunAddons()

	-- load everything in goluwa/*/lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME)

	-- load everything in goluwa/*/lua/autorun/client/*
	if CLIENT then
		vfs.AutorunAddons("client/")
	end

	-- load everything in goluwa/*/lua/autorun/server/*
	if SERVER then
		vfs.AutorunAddons("server/")
	end

	-- load everything in goluwa/*/lua/autorun/shared/*
	if CLIENT or SERVER then
		vfs.AutorunAddons("shared/")
	end

	if SOUND then
		vfs.AutorunAddons("sound/")
	end

	if GRAPHICS and render2d.IsReady() then
		vfs.AutorunAddons("graphics/")
	end

	if VERBOSE_STARTUP then
		llog("autorunning scripts took %s seconds", os.clock() - profile_start_time)
	end
end

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

event.Thinker(function()
	if collectgarbage("count") > 900000 then
		collectgarbage()
		llog("emergency gc!")
	end
end, false, 1/10)

-- main loop

local function main()
	local last_time = 0
	local i = 0ULL

	local function update()
		local time = system.GetTime()

		local dt = time - (last_time or 0)

		system.SetFrameTime(dt)
		system.SetFrameNumber(i)
		system.SetElapsedTime(system.GetElapsedTime() + dt)
		i = i + 1

		local ok, err = pcall(event.Call, "Update", dt)

		if not ok then
			if system.MessageBox then
				system.MessageBox("fatal error", tostring(err))
			else
				error("fatal error: " .. tostring(err))
			end
			os.exit()
			return false
		end

		last_time = time

		system.UpdateTitlebarFPS(dt)

		local rate = rate_cvar:Get()

		if rate > 0 then
			system.Sleep(math.floor(1/rate * 1000))
		end
	end

	if LOOP then
		while system.run == true do
			if update() == false then
				return
			end
		end
	else
		function UpdateGoluwa()
			if update() == false or not system.run then
				event.Call("ShutDown")
				--os.realexit(system.run)
				return false
			end
			return true
		end
	end
end

-- when including this file it will get stuck in the while loop so "lua/" is never popped from the stack
-- maybe instead of push popping directories maybe the directory should persist for each file
vfs.PopFromFileRunStack()

event.Call("Initialize")
system.ExecuteArgs()

if VERBOSE_STARTUP then
	llog("startup took %s seconds", os.clock() - profiler.startup_time)
end

if TMUX then
	logn("== tmux session started ==")
	logn("run 'detach' here to detach the session")
	logn("run 'exit' here or ctrl c twice to exit goluwa")
	logn("run './goluwa attach' in your terminal reattach to this goluwa tmux session")
end


main()

event.Call("ShutDown")

if TMUX then
	os.execute("tmux kill-session")
end

os.realexit(os.exitcode)