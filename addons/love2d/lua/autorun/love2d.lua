local function init_love(cd, ...)
	local path = R"bin/windows/x86/love.dll"

	-- make it so require("love") and require("graphics") work properly in love's boot lua
	if not package.love_loader_added then
		local loader

		loader = function(mod)
			-- there's no need for this unless _G.love exists
			if not _G.love then 
				for k,v in pairs(package.loaders) do 
					if v == loader then 
						table.remove(package.loaders, k) 
						return 
					end
				end
			else
				mod = mod:gsub("%.", "_")
				
				-- see if it's a lua file first
				local lua_path = love.current_dir .. mod .. ".lua"
				local func = loadfile(lua_path)
				
				if func then
					return func
				end
				
				-- maybe it's a dll
				local dll_path = love.current_dir .. mod .. (WINDOWS and ".dll" or "")
				local func = package.loadlib(dll_path, "luaopen_" .. mod)
				
				if func then
					return func
				end
				
				-- require("love.*")
				if mod:find("love") then
					local func = package.loadlib(path, "luaopen_" .. mod)() 
					if func then
						return func
					end
				end
			end
		end

		table.insert(package.loaders, loader)
		package.love_loader_added = true 
	end
	
	if not love then	
		system.SetDLLDirectory(path:sub(0,-10))		
			_G.arg = {...}
			package.preload["love"] = package.loadlib(path, "luaopen_love") 
			package.loadlib(path, "luaopen_love_boot")()
			love._exe = true 
		system.SetDLLDirectory()
			
		if love then
			love.current_dir = cd
		end
		
		love.boot() 
		love.init()
		
		love.love_dll = ffi.load("love")
		
		ffi.cdef[[
			int PHYSFS_addToSearchPath(const char *newDir, int appendToPath);
			int PHYSFS_removeFromSearchPath(const char *oldDir);
		]]
	
		-- newThread doesn't use PHYSFS ..
		local old = love.thread.newThread			
		love.thread.newThread = function(path, nope)
			local full_path
			
			if nope then 	
				path = nope
			end
			
			if type(path) == "string" and path:find("%.lua") then
				full_path = vfs.GetAbsolutePath(love.current_dir .. path) 
				
				if not full_path then
					full_path = vfs.GetAbsolutePath(path)
				end
			end
			
			return old(full_path or path)
		end

		-- some backwards compatibility to 0.8
		love.graphics.quad = love.graphics.polygon
		love.graphics.drawq = love.graphics.draw
		love.graphics.setDefaultImageFilter = love.graphics.setDefaultFilter
		love.graphics.setIcon = function() end
		love.graphics.setCaption = love.window.setTitle
		love.graphics.setMode = function(w, h, fullscreen, vsync, fsaa) 
			local flags={}
			flags.fullscreen=fullscreen
			flags.vsync=vsync
			flags.fsaa=fsaa
			flags.centered=true
			flags.resizable=false
			flags.borderless=false
			love.window.setMode(w, h, flags)
		end
	end	
	
	if love then
		love.current_dir = cd
	end
		
	if not love.goluwa_init then
		local old = love.graphics.present
		
		function love.graphics.present(...)
			coroutine.yield()
			return old(...)
		end
	end
	
	_G.arg = {...}
	
	return coroutine.create(love.run)
end 
    
local function run_lover(name, ...)
	 
	local path = R"lovers/" .. name .. "/"
	local func = assert(loadfile(path .. "/main.lua")) 
	local co = init_love(path, path, ...) 
	love.love_dll.PHYSFS_addToSearchPath(path, 1) 
	func()	
 
	Thinker(function()
		local ok, msg = coroutine.resume(co)
			
		if not ok then
			logf("love2d %s error: %s\n", name, msg)
			love.love_dll.PHYSFS_removeFromSearchPath(path) 
			return true
		end
	end)
end

console.AddCommand("lover", function(line, name, ...)
	run_lover(name, ...)
end)