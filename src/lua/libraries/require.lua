-- Copyright (c) 2012 Rob Hoelz <rob@hoelz.ro>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local meta = {}
local _M = setmetatable({}, meta)

_M.VERSION = "0.01"

-- XXX assert(type(package.preload[name]) == "function")?
local function preload_loader(name)
	if package.preload[name] then
		return package.preload[name]
	else
		return ("no field package.preload[%q]\n"):format(name)
	end
end

local function path_loader(name, paths, loader_func)
	local errors = {}
	local loader
	local found_path

	name = name or ""

	name = name:gsub("%.", "/")

	for path in paths:gmatch("[^;]+") do
		path = path:gsub("%?", name)

		local errmsg

		loader, errmsg = loader_func(path)

		if loader then
			found_path = path
			break
		else
			-- XXX error for when file isn"t readable?
			-- XXX error for when file isn"t valid Lua (or loadable?)
			if errmsg then
				table.insert(errors, (errmsg:gsub("\\", "/")))
			else
				table.insert(errors, string.format("no file %q", path:gsub("\\", "/")))
			end
		end
	end

	if loader then
		return loader, nil, found_path
	else
		table.sort(errors, function(a, b) return #a > #b end)
		return table.concat(errors, "\n") .. "\n"
	end
end

local function lua_loader(name)
	return path_loader(name, package.path, loadfile), nil, package.path
end

local function get_init_function_name(name)
	name = name:gsub("^.*%-", "", 1)
	name = name:gsub("%.", "_")

	return "luaopen_" .. name
end

local function c_loader(name)
	local init_func_name = get_init_function_name(name)

	return path_loader(name, package.cpath, function(path)
		return package.loadlib(path, init_func_name), nil, path
	end)
end

local function all_in_one_loader(name)
	local init_func_name = get_init_function_name(name)
	local base_name = name:match("^[^.]+")

	return path_loader(base_name, package.cpath, function(path)
		return package.loadlib(path, init_func_name), nil, path
	end)
end

local function find_chunk(loaders, errors, name, hint)
	for _, loader in ipairs(loaders) do
		local chunk, err, path = select(2, pcall(loader, name))
		if require.debug then print(chunk, err, path) end
		if type(chunk) == "function" then
			if hint and not (path and path:lower():find(hint:lower(), nil, true)) then
				table.insert(errors, ("hint %q was given but it was not found in in the returned path %q\n"):format(hint, path))
			else
				return chunk, path
			end
		elseif type(chunk) == "string" then
			table.insert(errors, chunk)
		elseif chunk == nil and type(err) == "string" then
			table.insert(errors, err)
		end
	end
end

local function load(name, hint, skip_error)
	local errors = { string.format("module %q not found\n", name) }

	local func, path

	func, path = find_chunk(_M.loaders, errors, name, hint)
	if func then return func, nil, path end
	func, path = find_chunk(package.loaders, errors, name, hint)
	if func then return func, nil, path end

	if _G[name] then
		return _G[name]
	end

	errors = table.concat(errors, "")

	if not chunk and not skip_error then
		error(errors, 3)
	end

	return chunk, errors, path
end

local function require(name)
	if package.loaded[name] == nil then
		local func, err, path = load(name)
		if path then path = path:match("(.+)[\\/]") end

		if vfs and vfs.PushToIncludeStack and path then
			vfs.PushToIncludeStack(path .. "/")
		end

		local args = {pcall(func, path)}

		if vfs and vfs.PopFromIncludeStack and path then
			vfs.PopFromIncludeStack()
		end

		if args[1] == false then error(args[2], 2) end

		local result = args[2]

		if result ~= nil then
			package.loaded[name] = result
		elseif package.loaded[name] == nil then
			package.loaded[name] = true
		end
	end

	return package.loaded[name]
end


local MODULE_CALLED
local IN_MODULE
local OLD_MODULE = _G.module
function module(name, ...)
	_M.module_name = name
	if IN_MODULE then
		MODULE_CALLED = true
		return OLD_MODULE(IN_MODULE, ...)
	else
		return OLD_MODULE(name, ...)
	end
end

local function require_function(name, func, path, arg_override)
	if package.loaded[name] == nil and package.loaded[path] == nil then

	local dir = path
	if dir then dir = dir:match("(.+)[\\/]") end

	IN_MODULE = name
		local result = func(arg_override or dir)
		if MODULE_CALLED then
			_G[_M.module_name] = result or package.loaded[path] or package.loaded[name]
			MODULE_CALLED = false
		end
	IN_MODULE = false

		if result ~= nil and not package.loaded[path] and not package.loaded[name] then
			package.loaded[name] = result
		elseif package.loaded[name] == nil and package.loaded[path] == nil then
			package.loaded[name] = true
		end
	end

	return package.loaded[path] or package.loaded[name] -- or package.loaded[path] in case of module(...)
end


local loadermeta = {}

function loadermeta:__call(...)
	return self.impl(...)
end

local function makeloader(loader_func, name)
	return setmetatable({ impl = loader_func, name = name }, loadermeta)
end

-- XXX make sure that any added loaders are preserved (esp. luarocks)
_M.loaders = {
	makeloader(preload_loader, "preload"),
	makeloader(lua_loader, "lua"),
	makeloader(all_in_one_loader, "all_in_one"),
	makeloader(c_loader, "c"),
}

function meta:__call(name)
	return require(name)
end

_M.load = load
_M.require_function = require_function

return _M