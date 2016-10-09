function gmod.env.include(path)
	local ok, err = include({
		path,
		"lua/" .. path,
		path:lower(),
		"lua/" .. path:lower()
	})
	if not ok then
		logn(err, path)
	end
end

function gmod.env.module(name, _ENV)
	--logn("gmod: module(",name,")")

	local tbl = package.loaded[name] or gmod.env[name] or {}

	if _ENV == package.seeall then
		_ENV = gmod.env
		setmetatable(tbl, {__index = _ENV})
	elseif _ENV then
		warning(_ENV, 2)
	end

	if not tbl._NAME then
		tbl._NAME = name
		tbl._M = tbl
		tbl._PACKAGE = name:gsub("[^.]*$", "")
	end

	package.loaded[name] = tbl
	gmod.env[name] = tbl

	setfenv(2, tbl)
end

function gmod.env.require(name, ...)
	--logn("gmod: require(",name,")")

	local func, err, path = require.load(name, gmod.dir, true)

	if type(func) == "function" then
		if debug.getinfo(func).what ~= "C" then
			setfenv(func, gmod.env)
		end

		return require.require_function(name, func, path, name)
	end

	if pcall(require, name) then
		return require(name)
	end

	if gmod.env[name] then return gmod.env[name] end

	if not func and err then print(name, err) end

	return func
end

function gmod.env.CompileString(code, identifier, handle_error)
	if handle_error == nil then handle_error = true end
	local func, err = loadstring(code)
	if func then
		setfenv(func, gmod.env)
		return func
	end
	if handle_error then
		error(err, 2)
	end
	return err
end

function gmod.env.CompileFile(name)
	return gmod.env.CompileString(vfs.Read("lua/" .. name), "@lua/" .. name)
end