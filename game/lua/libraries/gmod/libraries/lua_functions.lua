function gine.env.include(path)
	vfs.modify_chunkname = function(full_path)
		if full_path:find("/addons/") then return "@" .. full_path:match("^.+/(addons/.+)$") end
		if full_path:find("/gamemodes/") then return "@" .. full_path:match("^.+/(gamemodes/.+)$") end
		if full_path:find("/lua/") then return "@" .. full_path:match("^.+/(lua/.+)$") end
	end

	local ok, err = runfile({
		"lua/" .. path,
		"lua/" .. path:lower(),
		path,
		path:lower(),
	})

	vfs.modify_chunkname = nil

	if ok == false then
		debug.trace()
		error(err, 2)
	end

	return ok
end

function gine.env.module(name, _ENV)
	--logn("gine: module(",name,")")

	local tbl = package.loaded[name] or gine.env[name] or {}

	if _ENV == package.seeall then
		_ENV = gine.env
		setmetatable(tbl, {__index = _ENV})
	elseif _ENV then
		wlog(_ENV, 2)
	end

	if not tbl._NAME then
		tbl._NAME = name
		tbl._M = tbl
		tbl._PACKAGE = name:gsub("[^.]*$", "")
	end

	package.loaded[name] = tbl
	gine.env[name] = tbl

	setfenv(2, tbl)
end

function gine.env.require(name, ...)
	--logn("gine: require(",name,")")

	local func, err, path = require.load(name, gine.package_loaders)

	if type(func) == "function" then
		if debug.getinfo(func).what ~= "C" then
			setfenv(func, gine.env)
		end

		return require.require_function(name, func, path, name)
	end

	if pcall(require, name) then
		return require(name)
	end

	if gine.env[name] then return gine.env[name] end

	if not func and err then print(name, err) end

	return func
end

function gine.env.CompileString(code, identifier, handle_error)
	if handle_error == nil then handle_error = true end

	local ok, code = pcall(gine.PreprocessLua, code)

	if not ok then
		if not handle_error then
			return code
		end

		error(err, 2)
	end

	local func, err = loadstring(code, "@" .. identifier)

	if func then
		setfenv(func, gine.env)
		return func
	end

	if handle_error then
		error(err, 2)
	end

	return err
end

function gine.env.CompileFile(name)
	local full_path = R("lua/" .. name)

	if full_path:find("/addons/") then
		full_path = full_path:match("^.+/(addons/.+)$")
	elseif full_path:find("/gamemodes/") then
		full_path = full_path:match("^.+/(gamemodes/.+)$")
	elseif full_path:find("/lua/") then
		full_path = full_path:match("^.+/(lua/.+)$")
	end

	return gine.env.CompileString(vfs.Read("lua/" .. name), "@" .. full_path, false)
end
