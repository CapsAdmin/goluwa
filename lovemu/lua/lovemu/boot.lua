function lovemu.boot(folder)
	render.EnableGBuffer(false)

	local love = {}
	love._version = lovemu.version
	love._version_major = 9

	_G.love = love
	include("lovemu/love/*")
	_G.love = nil
	
	window.Open()	
	
	lovemu.errored = false
	lovemu.error_msg = ""
	lovemu.delta = 0
	lovemu.demoname = folder
	
	function love.load()
	end

	function love.update(dt)
	end	

	function love.draw()
	end
	
	function love.mousepressed()
	end
	
	function love.mousereleased()
	end
	
	function love.keypressed()
	end
	
	function love.keyreleased()
	end
		
	do -- error screen
		local font = love.graphics.newFont(8)

		function love.errhand(msg)
			love.graphics.setFont(font)
			msg = tostring(msg)
			love.graphics.setBackgroundColor(89, 157, 220)
			love.graphics.setColor(255, 255, 255, 255)
			
			local trace = debug.traceback()

			local err = {}

			table.insert(err, "Error\n")
			table.insert(err, msg.."\n\n")

			for l in string.gmatch(trace, "(.-)\n") do
				if not string.match(l, "boot.lua") then
					l = string.gsub(l, "stack traceback:", "Traceback\n")
					table.insert(err, l)
				end
			end

			local p = table.concat(err, "\n")

			p = string.gsub(p, "\t", "")
			p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

			local function draw()
				love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
			end
			
			draw()
		end
	end
	
	vfs.AddModuleDirectory("lovers/" .. lovemu.demoname .. "/")
	vfs.Mount(R("lovers/" .. lovemu.demoname .. "/"))
			
	local env = setmetatable({
		love = love, 
		require = function(name, ...)
			if package.loaded[name] then return package.loaded[name] end
			local t = {name, ...}
			if lovemu.debug then print("LOADING REQUIRE PATH "..t[1]) end
			local func, err, path = require.load(name, ...) 
			
			if type(func) == "function" then
				
				if debug.getinfo(func).what ~= "C" then
					setfenv(func, getfenv(2))
				end
				
				return require.require_function(name, func, path) 
			end
			
			return func
		end,
	}, 
	{
		__index = _G,
	})
	
	env._G = env

	lovemu.conf={}
	function love.conf(t) --partial
		t.screen={}
		t.window={}
		t.modules={}
		t.screen.height = 600      
		t.screen.width = 800  
		t.title = "LovEmu"      
		t.author = "Shell32"
	end
	love.conf(lovemu.conf)

	if vfs.Exists(R("conf.lua"))==true then
		print("LOADING CONF.LUA")
		
		local func = assert(vfs.loadfile("conf.lua"))
		setfenv(func, env)
		func()
	end
	
	love.conf(lovemu.conf)
	
	if not lovemu.conf.screen then
		lovemu.conf.screen={}
	end
	
	local w = lovemu.conf.screen.width or 800
	local h = lovemu.conf.screen.height or 600
	local title = lovemu.conf.title or "LovEmu"
	
	love.window.setMode(w,h)
	love.window.setTitle(title)
		
	local main = assert(vfs.loadfile("main.lua"))
	setfenv(main, env)
	if not xpcall(main, system.OnError) then return end
	if not xpcall(love.load, system.OnError) then return end
	
	local function run(dt)
		love.update(dt)
		love.draw(dt)
	end
		
	setfenv(run, env)
	
	local id = "lovemu_" .. folder
	
	event.AddListener("OnClose", id, function()
		event.RemoveListener("OnDraw2D", id)
		return e.EVENT_DESTROY
	end)
	
	event.AddListener("OnDraw2D", id, function(dt)		
		love.graphics.clear()
		lovemu.delta = dt
		surface.SetWhiteTexture()
		
		if lovemu.errored == false then
			local err, msg = xpcall(run, system.OnError, dt)
			if err == false then
				logn(msg)
				
				lovemu.errored = true
				lovemu.error_msg = msg
				
				love.errhand(lovemu.error_msg)
			end
		else
			love.errhand(lovemu.error_msg)
		end
	end)
end