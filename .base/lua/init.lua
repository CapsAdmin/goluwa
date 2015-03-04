local profile_start_time = os.clock()

-- check if this environment is compatible
if not require("ffi") then
	error("goluwa requires ffi to run!")
end

do -- constants
	-- if WINDOWS and X86 then blah blah end
	_G[jit.os:upper()] = true
	_G[jit.arch:upper()] = true

	-- enums table
	e = e or {}
	
	e.USERNAME = tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	_G[e.USERNAME:upper()] = true
	
	local env_vars = {
		"USE_GLFW",
		"SERVER",
		"CLIENT",
		"GRAPHICS",
		"SOUND",
		"DEBUG",
		"DISABLE_CURSES",
	}
	
	for _, key in pairs(env_vars) do
		if os.getenv(key) == "1" and _G[key] == nil then
			_G[key] = true
		end
	end
	
	-- assume client if nothing was provided
	if SERVER == nil and CLIENT == nil then
		CLIENT = true
	end
	if SOUND == nil then SOUND = true end
	if GRAPHICS == nil then GRAPHICS = true end
end

-- put all c functions in a table so we can override them if needed 
-- without doing the local oldfunc = print thing over and over again
if not _OLD_G then
	-- this will be replaced with utility.GetOldGLibrary() later on
	_OLD_G = {}
	local done = {[_G] = true}
	
	local function scan(tbl, store)
		for key, val in pairs(tbl) do
			local t = type(val)
			
			if t == "table" and not done[val] and val ~= store then
				store[key] = store[key] or {}
				done[val] = true
				scan(val, store[key])
			else
				store[key] = val
			end
		end
	end
	
	scan(_G, _OLD_G)
end

if not DISABLE_CURSES then
	-- this will be replaced later on with logn
	_G.LOG_BUFFER = {}

	print = function(...)
		table.insert(_G.LOG_BUFFER, table.concat(..., ", ") .. "\n")
		return _OLD_G.print(...)
	end
end

do -- file system

	-- this is required because fs needs winapi and syscall
	table.insert(package.loaders, function(name) name = name:gsub("%.", "/") return loadfile("../../lua/modules/" .. name .. ".lua") end)
	table.insert(package.loaders, function(name) name = name:gsub("%.", "/") return loadfile("../../lua/modules/" .. name .. "/init.lua") end)
	fs = dofile("../../lua/libraries/fs.lua")
	table.remove(package.loaders)
	table.remove(package.loaders)
	-- remove them because we do it properly later on

	e.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	e.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)" .. (".-/"):rep(3)) -- the root folder is always 3 paths up (.base/bin/os_arch)
	e.BASE_FOLDER = e.BIN_FOLDER:match("(.+/)" .. (".-/"):rep(2))
	
	-- the userdata folder
	e.USERDATA_FOLDER = e.ROOT_FOLDER .. ".userdata/" .. e.USERNAME:lower() .. "/"
	
	-- create them
	fs.createdir(e.ROOT_FOLDER .. ".userdata/")
	fs.createdir(e.USERDATA_FOLDER)

	do -- this is ugly but it's because we haven't included the global extensions yet..
		_G.check = function() end
		
		include = function() end
		
		ffi = require("ffi")

		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/globals.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/debug.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/string.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/table.lua")
		prototype = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/prototype.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/get_is_set.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/base_object.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/null.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/templates/buffer.lua")
		utility = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/utilities/utility.lua")
		
		vfs = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/vfs.lua")
		
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/path_utilities.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/base_file.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/find.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/helpers.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/lua_utilities.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/addons.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/monitoring.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/files/os.lua")
	--	dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/files/vpk.lua")

		vfs.IsDir = vfs.IsFolder
	end
	
	-- mount the /userdata/*username*/ folder
	vfs.Mount("os:" .. e.USERDATA_FOLDER, "data")
	
	-- mount the /.base folder
	vfs.MountAddon("os:" .. e.BASE_FOLDER)
	
	-- a nice global for loading resources externally from current dir
	-- 
	_G.R = vfs.GetAbsolutePath
	
	vfs.AddModuleDirectory("lua/modules/")
	vfs.AddModuleDirectory("lua/")
	
	-- replace require with the pure lua version (lua/procure/init.lua)
	-- this is needed for the file system and lovemu
	_G.require = dofile("../../lua/libraries/require.lua")
end

do -- libraries
	_G.include = vfs.include
		
	include("libraries/extensions/ffi.lua")

	if WINDOWS then
		winapi = require("winapi")
	else
		posix = require("syscall")
	end

	-- standard library extensions
	include("libraries/extensions/globals.lua")
	include("libraries/extensions/debug.lua")
	include("libraries/extensions/math.lua")
	include("libraries/extensions/string.lua")
	include("libraries/extensions/table.lua")
	include("libraries/extensions/os.lua")

	-- libraries
	prototype = include("libraries/prototype/prototype.lua")
	structs = include("libraries/structs.lua") -- Vec3(x,y,z), Vec2(x,y), Ang3(p,y,r),  etc
	utf8 = include("libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
	event = include("libraries/event.lua") goluwa = event.events -- event handler
	utility = include("libraries/utilities/utility.lua") -- more like i-dont-know-where-these-functions-go
	crypto = include("libraries/crypto.lua")
	threads = include("libraries/threads.lua")

	-- serializing
	serializer = include("libraries/serializing/serializer.lua")

	system = include("libraries/system.lua")
	console = include("libraries/console.lua")
	profiler = include("libraries/profiler.lua")
	cookies = include("libraries/cookies.lua")
	expression = include("libraries/expression.lua")
	autocomplete = include("libraries/autocomplete.lua")
	input = include("libraries/input.lua")
	
	language = include("libraries/language.lua")
	_G.L = language.LanguageString
	
	-- meta
	include("libraries/extensions/function.lua")
	
	-- network
	sockets = include("libraries/network/sockets/sockets.lua") -- luasocket wrapper mostly for web stuff
	enet = include("libraries/network/enet.lua") -- low level udp library
	
	network = include("libraries/network/network.lua") -- high level implementation of enet
	packet = include("libraries/network/packet.lua") -- medium (?) level communication between server and client
	message = include("libraries/network/message.lua") -- high level communication between server and client
	
	nvars = include("libraries/network/nvars.lua") -- variable synchronization between server and client
	clients = include("libraries/network/clients.lua") -- high level wrapper for a connected client
	chat = include("libraries/network/chat.lua") -- chat, duh!
		
	resource = include("libraries/resource.lua")
	
	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/extras/")
	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/base/")
	
	if CLIENT then
		-- graphics
		render = include("libraries/graphics/render/render.lua") -- OpenGL abstraction
		
		if render then
			surface = include("libraries/graphics/surface/surface.lua") -- high level 2d rendering of the render library
			window = include("libraries/graphics/window.lua") -- high level window implementation
			video = include("libraries/graphics/video.lua") -- gif support (for now)
			include("libraries/graphics/particles.lua")
					
			if not SCITE then
				window.Open()
			end
		end
		
		-- audio
		audio = include("libraries/audio/audio.lua") -- high level implementation of OpenAl
		
		if audio then
			chatsounds = include("libraries/audio/chatsounds.lua")
		end
	end
	
	if not render or not window.IsOpen() then
		GRAPHICS = nil
	end
	
	if not audio then
		SOUND = nil
	end
	
	-- other
	physics = include("libraries/entities/physics.lua") -- bullet physics
	entities = include("libraries/entities/entities.lua") -- entity component system
	steam = include("libraries/steam/steam.lua")
	lovemu = include("libraries/love/lovemu.lua")
	love = lovemu.CreateLoveEnv()

	if not DISABLE_CURSES then
		include("libraries/extensions/console_curses.lua") -- high level implementation of curses extending _G.console	
	end

	if GRAPHICS then
		gui = include("libraries/gui/init.lua")
	end
	
	-- include the filesystem again so it will include all the details such as zip file reading
	include("libraries/filesystem/vfs.lua")
end

console.CreateVariable("editor_path", system.FindFirstEditor(true, true) or "")

sockets.Initialize()

if audio then
	audio.Initialize()
end

if not ZEROBRANE and not DISABLE_CURSES then
	console.InitializeCurses()
end

--steam.InitializeWebAPI()

if CLIENT then
	clients.local_client = clients.Create("unconnected")
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

if SOUND then
	vfs.AutorunAddons("sound/")
end

if GRAPHICS then
	vfs.AutorunAddons("graphics/")
end

-- execute /.userdata/*USERNAME*/cfg/autoexec.lua
console.Exec("autoexec")

system._CheckCreatedEnv()

vfs.MonitorEverything(true)
system.ExecuteArgs()

logf("launched on %s by %s as %s\n", os.date(), e.USERNAME, CLIENT and "client" or "server")
logf("launch time took %s seconds\n", os.clock() - profile_start_time)

include("main_loop.lua")
