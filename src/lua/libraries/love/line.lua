local line = _G.line or {}

line.speed = 1
line.love_envs = line.love_envs or utility.CreateWeakTable()

pvars.Setup("line_enable_audio", true)
pvars.Setup("love_version", "0.9.0")

do
	local function base_typeOf(self, str)
		return str == self.name
	end

	local function base_type(self)
		return self.name
	end

	local created = utility.CreateWeakTable()
	local registered = {}

	function line.TypeTemplate(name)
		local META = {}
		META.__line_type = name
		return META
	end

	function line.RegisterType(META)
		META.__index = META
		META.typeOf = base_typeOf
		META.type = base_type

		registered[META.__line_type] = META

		-- some löve scripts get it from here
		debug.getregistry()[META.__line_type] = META

		if created[META.__line_type] then
			for i,v in ipairs(created[META.__line_type]) do
				setmetatable(v, META)
			end
		end
	end

	function line.CreateObject(name)
		local META = registered[name]

		local self = setmetatable({}, META)

		created[META.__line_type] = created[META.__line_type] or {}
		table.insert(created[META.__line_type], self)

		return self
	end

	function line.Type(v)
		local t = type(v)

		if t == "table" and v.__line_type then
			return v.__line_type
		end

		return t
	end

	function line.GetCreatedObjects(name)
		return created[name] or {}
	end
end

function line.ErrorNotSupported(str, level)
	wlog("[line] " .. str)
end

function line.CreateLoveEnv(version)
	version = version or pvars.Get("love_version")

	local love = {}

	love._version = version

	local version = version:split(".")

	love._version_major = tonumber(version[1])
	love._version_minor = tonumber(version[2])
	love._version_revision = tonumber(version[3])
	love._line_env = {}
	runfile("lua/libraries/love/libraries/*", love)

	table.insert(line.love_envs, love)

	setmetatable(love, {__newindex = function(_, key, val)
		event.Call("LoveNewIndex", love, key, val)
		rawset(love, key, val)
	end})

	return love
end

do
	local current_love

	local on_error = function(msg)
		current_love._line_env.error_message = msg .. "\n" .. debug.traceback()
		logn(current_love._line_env.error_message)
	end

	function line.pcall(love, func, ...)
		if love._line_env.error_message then return end
		current_love = love
		local ret = {xpcall(func, on_error, ...)}
		if ret[1] then
			return select(2, unpack(ret))
		end
	end
end

function line.CallEvent(what, a,b,c,d,e,f)
	for i, love in ipairs(line.love_envs) do
		if love[what] and not love._line_env.error_message then
			local a,b,c,d,e,f = line.pcall(love, love[what], a,b,c,d,e,f)
			if a then
				return a,b,c,d,e,f
			end
		end
	end
end

function line.FixPath(path)
	if path:startswith("/") or path:startswith("\\") then
		return path:sub(2)
	end
	return path
end

function line.RunGame(folder, ...)
	local love = line.CreateLoveEnv()

	wlog("mounting love game folder: ", R(folder .. "/"))
	vfs.CreateFolder("data/love/")
	vfs.AddModuleDirectory("data/love/")
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

			if name == "socket" then
				env.socket = sockets.luasocket
				return sockets.luasocket
			end

			llog("require: ", name)

			name = name:gsub("[%.]+", ".")

			if name:startswith("love.") and love[name:match(".+%.(.+)")] then
				return love[name:match(".+%.(.+)")]
			end

			local func, err, path = require.load(name, folder)
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

			if t == "table" and v.__line_type then
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
					event.Call("LoveNewIndex", t, k, v)
					setfenv(v, env)
				end
				rawset(t,k,v)
			end,
		}
	)

	do -- config
		line.config = {
			screen = {},
			window = {},
			modules = {},
			height = 600,
			width = 800,
			title = "LINE no title",
			author = "who knows",
		}

		if vfs.IsFile("conf.lua") then
			local func = assert(vfs.LoadFile("conf.lua"))
			setfenv(func, env)
			func()
		end

		love.conf(line.config)
	end

	--check if line.config.screen exists
	if not line.config.screen then
		line.config.screen={}
	end

	local w = line.config.screen.width or line.config.window.width or 800
	local h = line.config.screen.height or line.config.window.height or 600
	local title = line.config.title or "Line"

	love.window.setMode(w, h)
	love.window.setTitle(title)

	local main = assert(vfs.LoadFile("main.lua"))

	setfenv(main, env)
	setfenv(love.line_update, env)
	setfenv(love.line_draw, env)

	line.pcall(love, main)
	line.pcall(love, love.load, {})

	love.filesystem.setIdentity(love.filesystem.getIdentity())

	vfs.Mount(love.filesystem.getUserDirectory())

	line.current_game = love
	love._line_env.love_game_update_draw_hack = false

	return love
end

function line.IsGameRunning()
	return line.current_game ~= nil
end

commands.Add("love_run", function(_, name, ...)
	local found
	if vfs.IsDirectory("lovers/" .. name) then
		found = line.RunGame("lovers/" .. name, select(2, ...))
	elseif vfs.IsFile("lovers/" .. name .. ".love") then
		found = line.RunGame("lovers/" .. name .. ".love", select(2, ...))
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
			line.RunGame(full_path, unpack(args))
		end)
	else
		for _, file_name in ipairs(vfs.Find("lovers/")) do
			if file_name:compare(name) and vfs.IsDirectory("lovers/" .. file_name) then
				found = line.RunGame("lovers/" .. file_name)
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

event.AddListener("WindowFileDrop", "line", function(wnd, path)
	if vfs.IsDirectory(path) and vfs.IsFile(path .. "/main.lua") then
		line.RunGame(path)
		if menu then menu.Close() end
	end
end)

return line
