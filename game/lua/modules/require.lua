local require = {}

do -- loaders
	local function path_loader(name, paths, loader_func)
		local errors = {}
		local loader

		name = name or ""

		name = name:gsub("%.", "/")

		for path in paths:gmatch("[^;]+") do
			path = path:gsub("%?", name)

			if current_hint and current_hint(path) then

			end

			local func, err, path = loader_func(path)

			if func then
				return func, err, path
			end

			err = err or "nil"

			table.insert(errors, err)
		end

		table.sort(errors, function(a, b) return #a > #b end)

		return table.concat(errors, "\n"), paths
	end

	local function preload_loader(name)
		if type(package.preload[name]) == "function" then
			return package.preload[name], nil, name
		elseif package.preload[name] ~= nil then
			return nil, ("package.preload[%q] is %q\n"):format(name, type(package.preload[name])), nil, name
		else
			return nil, ("no field package.preload[%q]\n"):format(name), nil, name
		end
	end

	local function lua_loader(name)
		return path_loader(name, package.path, function(path)
			local func, err = loadfile(path)
			return func, err, path
		end)
	end

	local function c_loader(name)
		local init_func_name = "luaopen_" .. name:gsub("^.*%-", "", 1):gsub("%.", "_")

		return path_loader(name, package.cpath, function(path)
			local func, err, how = package.loadlib(path, init_func_name)

			if not func then
				if how == "open" and not err:startswith(path) or vfs.IsFile(path) then
					local deps = utility.GetLikelyLibraryDependenciesFormatted(full_path)
					if deps then
						err = err .. "\n" .. deps
					end
				end
			end
			return func, err, path
		end)
	end

	local function c_loader2(name)
		local symbol

		if name:find(".", nil, true) then
			symbol = "luaopen_" .. name:gsub("^.*%-", "", 1):gsub("%.", "_")
			name = name:match("(.+)%.")
		else
			symbol = "luaopen_" .. name:gsub("^.*%-", "", 1):gsub("%.", "_")
		end

		return path_loader(name, package.cpath, function(path)
			local func, err, how = package.loadlib(path, symbol)

			if not func then
				if how == "open" and not err:startswith(path) or vfs.IsFile(path) then
					err = err .. "\n" .. utility.GetLikelyLibraryDependenciesFormatted(path)
				end
			end
			return func, err, path
		end)
	end

	require.loaders = {}
	for i,v in ipairs(package.loaders) do
		require.loaders[i] = v
	end

	-- we don't need the default loaders since we reimplement them here
	for i = #require.loaders, 1, -1 do
		if debug.getinfo(require.loaders[i]).what == "C" then
			table.remove(require.loaders, i)
		end
	end

	table.insert(require.loaders, 1, c_loader2)
	table.insert(require.loaders, 1, c_loader)
	table.insert(require.loaders, 1, lua_loader)
	table.insert(require.loaders, 1, preload_loader)
end

function require.load(name, loaders)
	loaders = loaders or require.loaders

	local errors = {}

	for _, loader in ipairs(loaders) do
		local ok, func, msg, path = pcall(loader, name)

		if ok and type(func) == "string" then
			msg = func
			func = nil
		end

		if not ok then
			msg = func
			func = nil
		end

		if func then
			return func, nil, path
		else
			table.insert(errors, msg)
		end
	end

	if _G[name] then
		return _G[name], nil, name
	end

	if not errors[1] then
		errors[1] = string.format("module %q not found\n", name)
	end

	local err = table.concat(errors, "\n")

	err = err:gsub("\n\n", "\n")

	return nil, err, name
end

local function indent_error(str)
	local last_line
	str = "\n" .. str .. "\n"
	str = str:gsub("(.-\n)", function(line)
		line = "\t" .. line:trim() .. "\n"
		if line == last_line then
			return ""
		end
		last_line = line
		return line
	end)
	return str
end

function require.require(name)
	if package.loaded[name] == nil then
		local func, err, path = require.load(name)

		if not func then
			error(indent_error(err), 2)
		end

		if path then
			path = path:match("(.+)[\\/]")
		end

		if vfs and vfs.PushToFileRunStack and path then
			vfs.PushToFileRunStack(path .. "/")
		end

		local res, err = require.require_function(name, func, path)

		if vfs and vfs.PopFromFileRunStack and path then
			vfs.PopFromFileRunStack()
		end

		if res == nil then
			error(indent_error(err), 2)
		end

		return res
	end
	return package.loaded[name]
end

function require.module(modname, ...)
	local ns = package.loaded[modname] or {}

	if type(ns) ~= "table" then
		ns = _G[modname]
		if not ns then
			error (string.format("name conflict for module '%s'", modname))
		end
		package.loaded[modname] = ns
	end

	if not ns._NAME then
		ns._NAME = modname
		ns._M = ns
		ns._PACKAGE = modname:gsub("[^.]*$", "")
	end

	for i = 1, select("#", ...) do
		select(i, ...)(ns)
	end

	setfenv(2, ns)


	_G[modname] = ns
end

function require.require_function(name, func, path, arg_override, loaded)
	loaded = loaded or package.loaded

	if loaded[name] == nil and loaded[path] == nil then
		local dir = path

		if dir then
			dir = dir:match("(.+)[\\/]")
		end

		local ok, res = pcall(func, arg_override or dir)

		if ok == false then
			return nil, res
		end

		if res and not loaded[path] and not loaded[name] then
			loaded[name] = res
		elseif not res and loaded[name] == nil and loaded[path] == nil then
			--wlog("module %s (%s) was required but nothing was returned", name, path)
			loaded[name] = true
		end
	end

	if loaded[path] ~= nil then
		return loaded[path]
	end

	return loaded[name]
end

setmetatable(require, {__call = function(_, name) return require.require(name) end})

return require