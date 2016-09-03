local lovemu = _G.lovemu or {}

lovemu.version = "0.9.0"
lovemu.speed = 1
lovemu.love_envs = lovemu.love_envs or utility.CreateWeakTable()

do
	local function base_typeOf(self, str)
		return str == self.name
	end

	local function base_type(self)
		return self.name
	end

	local created = utility.CreateWeakTable()
	local registered = {}

	function lovemu.TypeTemplate(name)
		local META = {}
		META.__lovemu_type = name
		return META
	end

	function lovemu.RegisterType(META)
		META.__index = META
		META.typeOf = base_typeOf
		META.type = base_type

		registered[META.__lovemu_type] = META

		if created[META.__lovemu_type] then
			for i,v in ipairs(created[META.__lovemu_type]) do
				setmetatable(v, META)
			end
		end
	end

	function lovemu.CreateObject(name)
		local META = registered[name]

		local self = setmetatable({}, META)

		created[META.__lovemu_type] = created[META.__lovemu_type] or {}
		table.insert(created[META.__lovemu_type], self)

		return self
	end

	function lovemu.Type(v)
		local t = type(v)

		if t == "table" and v.__lovemu_type then
			return v.__lovemu_type
		end

		return t
	end

	function lovemu.GetCreatedObjects(name)
		return created[name] or {}
	end
end

function lovemu.ErrorNotSupported(str, level)
	warning("[lovemu] " .. str)
end

function lovemu.CreateLoveEnv()
	local love = {}

	love._version = lovemu.version

	local version = lovemu.version:split(".")

	love._version_major = tonumber(version[1])
	love._version_minor = tonumber(version[2])
	love._version_revision = tonumber(version[3])
	love._lovemu_env = {}

	include("lua/libraries/lovemu/libraries/*", love)

	table.insert(lovemu.love_envs, love)

	return love
end

do
	local current_love

	local on_error = function(msg)
		current_love._lovemu_env.error_message = msg .. "\n" .. debug.traceback()
		llog(current_love._lovemu_env.error_message)
	end

	function lovemu.pcall(love, func, ...)
		if love._lovemu_env.error_message then return end
		current_love = love
		local ret = {xpcall(func, on_error, ...)}
		if ret[1] then
			return select(2, unpack(ret))
		end
	end
end

function lovemu.CallEvent(what, a,b,c,d,e,f)
	for i, love in ipairs(lovemu.love_envs) do
		if love[what] and not love._lovemu_env.error_message then
			local a,b,c,d,e,f = lovemu.pcall(love, love[what], a,b,c,d,e,f)
			if a then
				return a,b,c,d,e,f
			end
		end
	end
end

function lovemu.FixPath(path)
	if path:startswith("/") or path:startswith("\\") then
		return path:sub(2)
	end
	return path
end

function lovemu.RunGame(folder, ...)
	local love = lovemu.CreateLoveEnv(lovemu.version)

	warning("mounting love game folder: ", 1, R(folder .. "/"))
	vfs.CreateFolder("data/lovemu/")
	vfs.AddModuleDirectory("data/lovemu/")
	vfs.Mount(R(folder .. "/"))
	vfs.AddModuleDirectory(folder .. "/")

	local env
	local require = require
	env = setmetatable({
		love = love,
		require = function(name, ...)
			if name == "strict" then
				-- nonono
				-- nonono
				return true
			end

			llog("requre: ", name)

			name = name:gsub("[%.]+", ".")

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
			local t = _G.type(v)

			if t == "table" and v.__lovemu_type then
				return "userdata"
			end

			return t
		end,
		pcall = function(func, ...)
			if type(func) == "function" and debug.getinfo(func).what ~= "C" then
				setfenv(func, env)
			end
			return _G.pcall(func, ...)
		end,
		xpcall = function(func, err, ...)
			if type(func) == "function" and debug.getinfo(func).what ~= "C" then
				setfenv(func, env)
			end
			if type(err) == "function" and debug.getinfo(err).what ~= "C" then
				setfenv(err, env)
			end
			return _G.xpcall(func, err, ...)
		end,
		loadstring = function(...)
			local a, b = _G.loadstring(...)
			if type(a) == "function" then
				setfenv(a, env)
			end
			return a, b
		end,
	},
	{
		__index = _G,
	})

	env._G = env
	env.arg = {...}

	setmetatable(
		love,
		{
			__newindex = function(t, k, v)
				if type(v) == "function" then
					llog("love.%s = %s", k,v)
					setfenv(v, env)
				end
				rawset(t,k,v)
			end,
		}
	)

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

	local w = lovemu.config.screen.width or lovemu.config.window.width or 800
	local h = lovemu.config.screen.height or lovemu.config.window.height or 600
	local title = lovemu.config.title or "LovEmu"

	love.window.setMode(w, h)
	love.window.setTitle(title)

	local main = assert(vfs.loadfile("main.lua"))

	setfenv(main, env)
	setfenv(love.lovemu_update, env)
	setfenv(love.lovemu_draw, env)

	lovemu.pcall(love, main)
	lovemu.pcall(love, love.load, {})

	love.filesystem.setIdentity(love.filesystem.getIdentity())

	vfs.Mount(love.filesystem.getUserDirectory())

	lovemu.current_game = love
	love._lovemu_env.love_game_update_draw_hack = false

	return love
end

commands.Add("love_run", function(line, name, ...)
	local found
	if vfs.IsDirectory("lovers/" .. name) then
		found = lovemu.RunGame("lovers/" .. name, select(2, ...))
	elseif vfs.IsFile("lovers/" .. name .. ".love") then
		found = lovemu.RunGame("lovers/" .. name .. ".love", select(2, ...))
	elseif name:find("github") then
		local url = name

		if name:startswith("github/") then
			url = name:gsub("github/", "https://github.com/") .. "/archive/master.zip"
		else
			url = url .. "/archive/master.zip"
		end

		local args = {...}

		resource.Download(url, function(full_path)
			full_path = full_path .. "/" .. name:match(".+/(.+)") .. "-master"
			logn("running downloaded löve game: ", full_path)
			lovemu.RunGame(full_path, unpack(args))
		end)
	else
		for _, file_name in ipairs(vfs.Find("lovers/")) do
			if file_name:compare(name) and vfs.IsDirectory("lovers/" .. file_name) then
				found = lovemu.RunGame("lovers/" .. file_name)
				break
			end
		end
	end

	if found then
		if menu then menu.Close() end
	else
		return false, "love game " .. name .. " does not exist"
	end
end)

event.AddListener("WindowFileDrop", "lovemu", function(wnd, path)
	if vfs.IsDirectory(path) and vfs.IsFile(path .. "/main.lua") then
		lovemu.RunGame(path)
		if menu then menu.Close() end
	end
end)

return lovemu