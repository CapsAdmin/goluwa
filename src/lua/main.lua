local profile_start_time = os.clock()

pvars.Setup("editor_path", system.FindFirstEditor(true, true) or "")

pvars.Initialize()

if sockets then
	sockets.Initialize()

	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/base/")
	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/extras/")
end

if WINDOW and window then
	if window.Open() then
		if GRAPHICS then
			gui.Initialize()
		end
	end
end
if audio then
	audio.Initialize()
end

if CURSES then
	repl.Initialize()
end

if lovemu then
	love = lovemu.CreateLoveEnv() -- https://www.love2d.org/wiki/love
end

if physics then
	physics.Initialize()
end

--steam.InitializeWebAPI()

if network then
	enet.Initialize()
	
	if CLIENT then
		clients.local_client = clients.Create("unconnected")
	end
end

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
vfs.MountAddons(e.ROOT_FOLDER)

-- load everything in lua/autorun/*
vfs.AutorunAddons()

-- load everything in lua/autorun/*USERNAME*/*
vfs.AutorunAddons(e.USERNAME)

-- load everything in lua/autorun/client/*
if CLIENT then
	vfs.AutorunAddons("client/")
end

-- load everything in lua/autorun/server/*
if SERVER then
	vfs.AutorunAddons("server/")
end

-- load everything in lua/autorun/shared/*
if CLIENT or SERVER then
	vfs.AutorunAddons("server/")
end

if SOUND then
	vfs.AutorunAddons("sound/")
end

if GRAPHICS and surface.IsReady() then
	vfs.AutorunAddons("graphics/")
end

-- execute /data/users/*USERNAME*/cfg/autoexec.lua
commands.RunString(vfs.Read("cfg/autoexec.cfg"))

system._CheckCreatedEnv()

vfs.MonitorEverything(true)
system.ExecuteArgs()

llog("initializing libraries took %s seconds\n", os.clock() - profile_start_time)

local rate_cvar = pvars.Setup(
	"system_fps_max",
	0,
	function(rate)
		if window and window.IsOpen() then
			if rate == 0 then
				window.SwapInterval(true)
			else
				window.SwapInterval(false)
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
	event.Call("Initialize")

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

	if not LOOP then
		function UpdateGoluwa()
			if update() == false or not system.run then
				event.Call("ShutDown")
				--os.realexit(system.run)
				return false
			end
			return true
		end
	else
		while system.run == true do
			if update() == false then
				return
			end
		end
	end
end

-- when including this file it will get stuck in the while loop so "lua/" is never popped from the stack
-- maybe instead of push popping directories maybe the directory should persist for each file
vfs.PopFromIncludeStack()

main()

if not LOOP then
	event.Call("ShutDown")
	os.realexit(system.run)
end