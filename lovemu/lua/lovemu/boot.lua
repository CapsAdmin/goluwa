function lovemu.CreateLoveEnv(version)
	local love = {}
	
	love._version = lovemu.version
	
	local version = lovemu.version:explode(".")
	
	love._version_major = tonumber(version[1])
	love._version_minor = tonumber(version[2])
	love._version_revision = tonumber(version[3])

	include("lovemu/love/*", love)
	
	love.math = math
	
	return love
end

function lovemu.RunGame(folder)
	--require("socket")
	--require("socket.http")
	
	--render.EnableGBuffer(false)

	local love = lovemu.CreateLoveEnv(lovemu.version)
		
	lovemu.errored = false
	lovemu.error_msg = ""
	lovemu.delta = 0
	lovemu.demoname = folder
	lovemu.love = love
	lovemu.textures = {}
		
	window.Open()	
		
	warning("mounting love game folder: ", R("lovers/" .. lovemu.demoname .. "/"))
	vfs.CreateFolder("data/lovemu/")
	vfs.AddModuleDirectory("data/lovemu/")	
	vfs.Mount(R("lovers/" .. lovemu.demoname .. "/"))
	vfs.AddModuleDirectory("lovers/" .. lovemu.demoname .. "/")
			
	local env
	env = setmetatable({
		love = love,
		require = function(name, ...)
			logn("[lovemu] requre: ", name)
			
			if name:startswith("love.") and love[name:match(".+%.(.+)")] then
				return love[name:match(".+%.(.+)")]
			end
			
			local func, err, path = require.load(name, folder, true) 
						
			if type(func) == "function" then
				if debug.getinfo(func).what ~= "C" then
					setfenv(func, env)
				end
				
				return require.require_function(name, func, path, name) 
			end
			
			if pcall(require, name) then
				return require(name)
			end
			
			if not func and err then print(name, err) end
			
			return func
		end,
		type = function(v)
			local t = type(v)
			
			if t == "table" and v.__lovemu_type then
				return "userdata"
			end
			
			return t
		end,
	}, 
	{
		__index = _G,
	})
	
	env._G = env
	
	do -- config
		lovemu.config = {
			screen = {}, 
			window = {},
			modules = {},
			height = 600,
			width = 800,
			title = "LOVEMU no title",
			author = "who knows",
		}
		
		if vfs.IsFile("conf.lua") then			
			local func = assert(vfs.loadfile("conf.lua"))
			setfenv(func, env)
			func()
		end
			
		love.conf(lovemu.config)
	end
	
	--check if lovemu.config.screen exists
	if not lovemu.config.screen then
		lovemu.config.screen={}
	end
	
	local w = lovemu.config.screen.width or 800
	local h = lovemu.config.screen.height or 600
	local title = lovemu.config.title or "LovEmu"
	
	love.window.setMode(w,h)
	love.window.setTitle(title)
		
	local main = assert(vfs.loadfile("main.lua"))
	
	setfenv(main, env)
	setfenv(love.load, env)
	
	if not xpcall(main, system.OnError) then return end
	if not xpcall(love.load, system.OnError, {}) then return end
			
	
	local id = "lovemu_" .. folder
		
	local function run(dt)
		love.update(dt)
		love.draw(dt)
	end
		
	setfenv(run, env)
		
	surface.CreateFont("lovemu", {path = "fonts/vera.ttf", size = 11})
		
	event.AddListener("Draw2D", id, function(dt)
		render.SetCullMode("none")
		surface.SetFont("lovemu")
		love.graphics.clear()
		lovemu.delta = dt
		surface.SetColor(1,1,1,1)
		surface.SetWhiteTexture()
		
		if not lovemu.errored then
			surface.PushMatrix()
			local err, msg = xpcall(run, system.OnError, dt)
			surface.PopMatrix()
			if not err then
				warning(msg)
				
				lovemu.errored = true
				lovemu.error_msg = msg
				
				love.errhand(lovemu.error_msg)
			end
		else
			love.errhand(lovemu.error_msg)
		end
		render.SetCullMode("back")
	end, {priority = math.huge}) -- draw this first
end