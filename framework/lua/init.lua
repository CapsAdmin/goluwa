runfile("!lua/libraries/extensions/*")
runfile("!lua/libraries/filesystem/files/*")
runfile("!lua/libraries/serializers/*")

if GRAPHICS then
	math2d = runfile("!lua/libraries/graphics/math2d.lua") -- 2d math functions
	math3d = runfile("!lua/libraries/graphics/math3d.lua") -- 3d math functions
end

structs = runfile("!lua/libraries/structs.lua") -- Vec3(x,y,z), Vec2(x,y), Ang3(p,y,r),  etc
input = runfile("!lua/libraries/input.lua") -- keyboard and mouse input
tasks = runfile("!lua/libraries/tasks.lua") -- high level coroutine library
threads = runfile("!lua/libraries/threads.lua")

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
	camera = runfile("!lua/libraries/graphics/camera.lua") -- 2d and 3d camera used for rendering
	render = runfile("!lua/libraries/graphics/render/render.lua") -- OpenGL abstraction

	if render then
		render2d = runfile("!lua/libraries/graphics/render2d/render2d.lua") -- low level 2d rendering based on the render library
		fonts = runfile("!lua/libraries/graphics/fonts/fonts.lua") -- font rendering
		gfx = runfile("!lua/libraries/graphics/gfx/gfx.lua") -- high level 2d and 3d functions based on render2d, fonts and render
		window = runfile("!lua/libraries/window/window.lua") -- window implementation
	end
end

if not render or not window then
	GRAPHICS = false
	WINDOW = false
end

if SOUND then
	audio = runfile("!lua/libraries/audio/audio.lua") -- high level implementation of OpenAl

	if not audio then
		SOUND = false
	end
elseif CLI then
	audio = runfile("!lua/libraries/audio/decoding.lua") -- only decoding
end

resource.AddProvider("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/base/", true)

event.AddListener("Initialize", function()
	if SOUND then
		audio.Initialize()
	end

	--steam.InitializeWebAPI()

	if NETWORK then
		network.Initialize()
	end
end)

event.AddListener("MainLoopStart", function()
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
end)