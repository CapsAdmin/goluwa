do
	local cache = {}
	function system.GetFFIBuildLibrary(name, require)
		if cache[name] ~= nil then return cache[name] end

		local val, res = loadfile("./" .. name .. ".lua")

		if val then
			val, res = pcall(val)

			if val then
				cache[name] = res
				return res
			end
		end

		if require then
			error("unable to load library " .. name .. ": " .. res, 2)
		end

		llog("unable to load library " .. name .. ": " .. res)
	end
end
runfile("!lua/libraries/extensions/*")
runfile("!lua/libraries/filesystem/files/*")
runfile("!lua/libraries/serializers/*")

if GRAPHICS then
	math2d = runfile("lua/libraries/graphics/math2d.lua") -- 2d math functions
	math3d = runfile("lua/libraries/graphics/math3d.lua") -- 3d math functions
end

structs = runfile("lua/libraries/structs.lua") -- Vec3(x,y,z), Vec2(x,y), Ang3(p,y,r),  etc
input = runfile("lua/libraries/input.lua") -- keyboard and mouse input
tasks = runfile("lua/libraries/tasks.lua") -- high level coroutine library
threads = runfile("lua/libraries/threads.lua")

if PHYSICS then
	physics = runfile("lua/libraries/physics/physics.lua") -- bullet physics
	if not physics then
		PHYSICS = false
	end
end

if SOCKETS then
	sockets = runfile("lua/libraries/sockets/sockets.lua") -- luasocket wrapper mostly for web stuff

	if not sockets then
		SOCKETS = false
	end
end

resource = runfile("lua/libraries/sockets/resource.lua") -- used for downloading resources with resource.Download("http://...", function(path) end)

if SERVER or CLIENT then
	network = runfile("!lua/libraries/network/network.lua") -- high level implementation of enet

	if network then
		NETWORK = true
	else
		NETWORK = false
		CLIENT = false
		SERVER = false
	end
end

if GRAPHICS then
	camera = runfile("lua/libraries/graphics/camera.lua") -- 2d and 3d camera used for rendering
	render = runfile("lua/libraries/graphics/render/render.lua") -- OpenGL abstraction

	if render then
		render2d = runfile("lua/libraries/graphics/render2d/render2d.lua") -- low level 2d rendering based on the render library
		fonts = runfile("lua/libraries/graphics/fonts/fonts.lua") -- font rendering
		gfx = runfile("lua/libraries/graphics/gfx/gfx.lua") -- high level 2d and 3d functions based on render2d, fonts and render
		window = runfile("lua/libraries/graphics/window.lua") -- window implementation
	end
end

if not render or not window then
	GRAPHICS = false
	WINDOW = false
end

if SOUND then
	audio = runfile("lua/libraries/audio/audio.lua") -- high level implementation of OpenAl

	if not audio then
		SOUND = false
	end
end

if SOCKETS then
	sockets.Initialize()
end

resource.AddProvider("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/base/", true)

if WINDOW then
	if window.Open() then
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
	network.Initialize()
end

system._CheckCreatedEnv()

event.AddListener("Initialize", function()
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
end)

if THREAD then return end

-- only if we're in 32 bit lua
if #tostring({}) == 10 then
	event.Thinker(function()
		if collectgarbage("count") > 900000 then
			collectgarbage()
			llog("emergency gc!")
		end
	end, false, 1/10)
end

-- main loop
local last_time = 0
local i = 0ULL

function system.MainLoop()
	while system.run == true do
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
	end
end