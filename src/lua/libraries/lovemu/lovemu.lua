local lovemu = _G.lovemu or {}

lovemu.version = "0.9.0"
lovemu.speed = 1

do
	local function base_typeOf(self, str)
		return str == self.name
	end

	local function base_type(self)
		return self.name
	end

	local created = {}

	function lovemu.CreateObject(META)

		META.__index = META
		META.typeOf = base_typeOf
		META.type = base_type

		local self = setmetatable({}, META)

		self.__lovemu_type = META.Type

		created[META.Type] = created[META.Type] or {}
		table.insert(created[META.Type], self)

		return self
	end

	function lovemu.Type(v)
		if type(v) == "table" and v.__lovemu_type then
			return v.__lovemu_type
		end
		return type(v)
	end

	function lovemu.GetCreatedObjects(name)
		return created[name] or {}
	end
end

function lovemu.ErrorNotSupported(str, level)
	warning("[lovemu] " .. str)
end

function lovemu.CheckSupported(demo)
	local supported = {}

	for path in vfs.Iterate("lua/libraries/lovemu/libraries/", nil, true) do
		local file = vfs.Open(path)
		for line in file:Lines() do
			local name = line:match("(love%..-)%b()")
			if name then
				local partial = line:match("--partial(.+)\n", nil, true)

				if partial then
					partial = partial:trim()

					if partial ~= "" then
						partial = "partial"
					end

					supported[name] = partial
				else
					supported[name] = true
				end
			end
		end
	end

	local found = {}

	for _, path in pairs(vfs.Search("lovers/" .. demo .. "/", "lua")) do
		local file = vfs.Open(path)
		for line in file:Lines() do
			local name = line:match("(love%.[_%a]-%.[_%a]-)[^_%a]")
			if name then
				found[name] = true
			end
		end
	end

	for k in pairs(found) do
		if supported[k] then
			if type(supported[k]) == "string" then
				logn("partial:\t", k, " -- ", supported[k])
			end
		else
			logn("not supported: ", k)
		end
	end
end

function lovemu.GetGames()
	return vfs.Find("lovers/")
end

function lovemu.CreateLoveEnv()
	local love = {}

	love._version = lovemu.version

	local version = lovemu.version:explode(".")

	love._version_major = tonumber(version[1])
	love._version_minor = tonumber(version[2])
	love._version_revision = tonumber(version[3])

	include("lua/libraries/lovemu/libraries/*", love)

	return love
end

function lovemu.RunGame(folder, ...)
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
	env.arg = {...}

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

	if not system.pcall(main) then return end
	if not system.pcall(love.load, {}) then return end


	local id = "lovemu_" .. folder

	local function run(dt)
		love.update(dt)
		love.draw(dt)
	end

	setfenv(run, env)

	surface.CreateFont("lovemu", {path = "fonts/vera.ttf", size = 11})

	event.AddListener("Draw2D", id, function(dt)
		for i = 1, lovemu.speed do
			surface.SetFont("lovemu")
			lovemu.delta = dt
			surface.SetWhiteTexture()

			love.graphics.clear()
			love.graphics.setColor(love.graphics.getColor())
			love.graphics.setFont(love.graphics.getFont())

			if not lovemu.errored then
				surface.PushMatrix()
				local err, msg = system.pcall(run, dt)
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
			render.SetCullMode("front")
		end
	end, {priority = math.huge}) -- draw this first
end

console.AddCommand("love", function(line, command, ...)
	if command == "run" then
		local name = tostring((...))
		if vfs.IsDir("lovers/" .. name) then
			lovemu.RunGame(name)
		elseif vfs.IsFile("lovers/" .. name .. ".love") then
			lovemu.RunGame(name .. ".love")
		else
			return false, "love game " .. name .. " does not exist"
		end
	elseif command == "check" then
		local name = tostring((...))
		if vfs.IsDir("lovers/" .. name) then
			lovemu.CheckSupported(name)
		else
			return false, "love game " .. name .. " does not exist"
		end
	elseif command == "version" then
		local name = tostring((...))
		lovemu.version = version
		logn("Changed internal version to " .. version)
	else
		return false, "no such command"
	end
end, function()
	logn("Usage:")
	logn("\tlovemu     <command> <params>\n\nCommands:\n")
	logn("\tcheck      <folder name>        //check game compatibility with lovemu")
	logn("\trun        <folder name>        //runs a game  ")
	logn("\tversion    <version>            //change internal love version, default: 0.9.0")
end)

return lovemu