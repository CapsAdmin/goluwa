local utility = _G.utility or {}

function utility.GetLikelyLibraryDependencies(path)
	local ext = vfs.GetExtensionFromPath(path)
	local original = vfs.GetFileNameFromPath(path)

	if not vfs.IsFile(path) then return nil, "file not found" end

	local content = vfs.Read(path)
	local done = {}
	local found = {}

	if content then
		if ext == "so" then
			for name in content:gmatch("([%.%w_-]+%.so[%w%.]*)\0") do
				if not done[name] then
					list.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end

			original = list.remove(found, #found).name
		elseif ext == "dll" then
			for name in content:gmatch("([%.%w_-]+%.dll)\0") do
				if not done[name] then
					list.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end
		--original = list.remove(found, 1).name
		elseif ext == "dylib" then
			for name in content:gmatch("([%.%w_-]+%.dylib)\0") do
				if not done[name] then
					list.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end

			original = list.remove(found, 1).name
		end

		for i, info in ipairs(found) do
			local where = "bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/"
			local found = vfs.GetFiles({path = where, filter = path, filter_plain = true, full_path = true})

			if found[1] then
				for _, full_path in ipairs(found) do
					-- look first in the vfs' bin directories
					fs.PushWorkingDirectory(full_path:match("(.+/)"))
					local ok, err, what = package.loadlib(info.name, "")

					if what == "open" then
						info.status = "MISSING"
					elseif what == "init" then
						info.status = "FOUND"

						break
					end

					fs.PopWorkingDirectory()
				end
			else
				local ok, err, what = package.loadlib(info.name, "")

				if what == "open" then
					info.status = "MISSING"
				elseif what == "init" then
					info.status = "FOUND"
				end
			end
		end
	end

	if system.OSCommandExists("ldd") then
		local p = io.popen("ldd " .. path)
		local msg = p:read("*all")
		print(msg)
		p:close()
		local missing_glib = msg:match("(GLIBC_%S- not found)")

		if missing_glib then
			for k, v in pairs(found) do
				if v.name:find("libc.so", nil, true) then
					found[k].status = missing_glib

					break
				end
			end
		end
	end

	return {name = original, dependencies = found}
end

do
	local cache = {}

	function utility.GetLikelyLibraryDependenciesFormatted(path)
		local data = cache[path] or utility.GetLikelyLibraryDependencies(path)
		cache[path] = data

		if not data then return end

		local str = data.name .. " likely dependencies:\n"

		for _, info in ipairs(data.dependencies) do
			str = str .. "\t" .. (info.status) .. "\t\t" .. info.name .. "\n"
		end

		return str
	end
end

do
	local function go(path, done)
		local data = utility.GetLikelyLibraryDependencies(path)
		local dir = vfs.GetFolderFromPath(R(path))

		if WINDOWS then
			for _, info in ipairs(data.dependencies) do
				if info.status == "MISSING" and not done[info.name] then
					local path = "C:/msys64/usr/bin/" .. info.name

					if vfs.IsFile(path) then
						done[info.name] = true
						logn("\tfound ", info.name)
						vfs.CopyFileFileOnBoot(path, dir .. info.name)
						go(dir .. info.name, done)
					end
				end
			end
		end
	end

	function utility.FetchDependencies(path)
		logn("finding missing libraries for ", vfs.GetFileNameFromPath(path))
		return go(path, {})
	end
end

function utility.AddPackageLoader(func, loaders)
	loaders = loaders or package.loaders

	for i, v in ipairs(loaders) do
		if v == func then
			list.remove(loaders, i)

			break
		end
	end

	list.insert(loaders, func)
end

do
	local ran = {}

	function utility.RunOnNextGarbageCollection(callback, id)
		if id then
			ran[id] = false
			getmetatable(newproxy(true)).__gc = function(...)
				if not ran[id] then
					callback(...)
					ran[id] = true
				end
			end
		else
			getmetatable(newproxy(true)).__gc = callback
		end
	end
end

do
	local function handle_path(path)
		if vfs.IsPathAbsolute(path) then return path end

		if path == "." then path = "" end

		return system.GetWorkingDirectory() .. path
	end

	function utility.CLIPathInputToTable(str, extensions)
		local paths = {}
		str = str:trim()

		if handle_path(str):ends_with("/**") then
			vfs.GetFilesRecursive(handle_path(str:sub(0, -3)), extensions, function(path)
				list.insert(paths, R(path))
			end)
		elseif handle_path(str):ends_with("/*") then
			for _, path in ipairs(vfs.Find(handle_path(str:sub(0, -2)), true)) do
				if not extensions or vfs.GetExtensionFromPath(path):ends_with_these(extensions) then
					list.insert(paths, path)
				end
			end
		elseif str:find(",", nil, true) then
			for i, path in ipairs(str:split(",")) do
				path = handle_path(vfs.FixPathSlashes(path:trim()))

				if
					vfs.IsFile(path) and
					(
						not extensions or
						vfs.GetExtensionFromPath(path):ends_with_these(extensions)
					)
				then
					list.insert(paths, R(path))
				end
			end
		elseif LINUX and str:find("%s") then
			for i, path in ipairs(str:split(" ")) do
				path = handle_path(vfs.FixPathSlashes(path:trim()))

				if
					vfs.IsFile(path) and
					(
						not extensions or
						vfs.GetExtensionFromPath(path):ends_with_these(extensions)
					)
				then
					list.insert(paths, R(path))
				end
			end
		elseif
			vfs.IsFile(handle_path(str)) and
			(
				not extensions or
				vfs.GetExtensionFromPath(str):ends_with_these(extensions)
			)
		then
			list.insert(paths, R(handle_path(str)))
		else
			list.insert(paths, handle_path(str))
		end

		return paths
	end
end

function utility.GenerateCheckLastFunction(func, arg_count)
	local lua = ""
	lua = lua .. "local func = ...\n"

	for i = 1, arg_count do
		lua = lua .. "local last_" .. i .. "\n"
	end

	lua = lua .. "return function("

	for i = 1, arg_count do
		lua = lua .. "_" .. i

		if i ~= arg_count then lua = lua .. ", " end
	end

	lua = lua .. ")\n"
	lua = lua .. "\tif\n"

	for i = 1, arg_count do
		lua = lua .. "\t\t_" .. i .. " ~= last_" .. i

		if i ~= arg_count then lua = lua .. " or\n" else lua = lua .. "\n" end
	end

	lua = lua .. "\tthen\n"
	lua = lua .. "\t\tfunc("

	for i = 1, arg_count do
		lua = lua .. "_" .. i

		if i ~= arg_count then lua = lua .. ", " end
	end

	lua = lua .. ")\n"

	for i = 1, arg_count do
		lua = lua .. "\t\tlast_" .. i .. " = _" .. i .. "\n"
	end

	lua = lua .. "\tend\n"
	lua = lua .. "end"
	return assert(loadstring(lua))(func)
end

do
	local stack = {}

	function utility.PushTimeWarning()
		list.insert(stack, os.clock())
	end

	function utility.PopTimeWarning(what, threshold, category)
		threshold = threshold or 0.1
		local start_time = list.remove(stack)

		if not start_time then return end

		local delta = os.clock() - start_time

		if delta > threshold then
			if category then
				logf("%s %f seconds spent in %s\n", category, delta, what)
			else
				logf("%f seconds spent in %s\n", delta, what)
			end
		end
	end
end

function utility.CreateDeferredLibrary(name)
	return setmetatable(
		{
			queue = {},
			Start = function(self)
				_G[name] = self
			end,
			Stop = function()
				_G[name] = nil
			end,
			Call = function(self, lib)
				for _, v in ipairs(self.queue) do
					if not lib[v.key] then error(v.key .. " was not found", 2) end

					print(self, lib)
					lib[v.key](unpack(v.args))
				end

				return lib
			end,
		},
		{
			__index = function(self, key)
				return function(...)
					list.insert(self.queue, {key = key, args = {...}})
				end
			end,
		}
	)
end

function utility.CreateCallbackThing(cache)
	cache = cache or {}
	local self = {}

	function self:check(path, callback, extra)
		if cache[path] then
			if cache[path].extra_callbacks then
				for key, old in pairs(cache[path].extra_callbacks) do
					local callback = extra[key]

					if callback then
						cache[path].extra_callbacks[key] = function(...)
							old(...)
							callback(...)
						end
					end
				end
			end

			if cache[path].callback then
				local old = cache[path].callback
				cache[path].callback = function(...)
					old(...)
					callback(...)
				end
				return true
			end
		end
	end

	function self:start(path, callback, extra)
		cache[path] = {callback = callback, extra_callbacks = extra}
	end

	function self:callextra(path, key, out)
		if not cache[path] or not cache[path].extra_callbacks[key] then return end

		return cache[path].extra_callbacks[key](out)
	end

	function self:stop(path, out, ...)
		if not cache[path] then return end

		cache[path].callback(out, ...)
		cache[path] = out
	end

	function self:get(path)
		return cache[path]
	end

	function self:uncache(path)
		cache[path] = nil
	end

	return self
end

function utility.MakePushPopFunction(lib, name, func_set, func_get, reset)
	func_set = func_set or lib["Set" .. name]
	func_get = func_get or lib["Get" .. name]
	local stack = {}
	local i = 1
	lib["Push" .. name] = function(a, b, c, d)
		stack[i] = stack[i] or {}
		local a_, b_, c_, d_ = func_get()
		stack[i][1], stack[i][2], stack[i][3], stack[i][4] = a_, b_, c_, d_
		func_set(a, b, c, d)
		i = i + 1
		return a_, b_, c_, d_
	end
	lib["Pop" .. name] = function()
		i = i - 1

		if i < 1 then error("stack underflow", 2) end

		if i == 1 and reset then reset() end

		local a, b, c, d = stack[i][1], stack[i][2], stack[i][3], stack[i][4]
		func_set(a, b, c, d)
		return a, b, c, d
	end
end

function utility.SafeRemove(obj, gc)
	if has_index(obj) then
		if obj.IsValid and not obj:IsValid() then return end

		if type(obj.Remove) == "function" then
			obj:Remove()
		elseif type(obj.Close) == "function" then
			obj:Close()
		end

		if gc and type(obj.__gc) == "function" then obj:__gc() end
	end
end

utility.remakes = {}

function utility.RemoveOldObject(obj, id)
	if has_index(obj) and type(obj.Remove) == "function" then
		id = id or (debug.getinfo(2).currentline .. debug.getinfo(2).source)

		if typex(utility.remakes[id]) == typex(obj) then
			utility.remakes[id]:Remove()
		end

		utility.remakes[id] = obj
	end

	return obj
end

do
	local hooks = {}

	function utility.SetFunctionHook(tag, tbl, func_name, type, callback)
		local old = hooks[tag] or tbl[func_name]

		if type == "pre" then
			tbl[func_name] = function(...)
				local args = {callback(old, ...)}

				if args[1] == "abort_call" then return end

				if #args == 0 then return old(...) end

				return unpack(args)
			end
		elseif type == "post" then
			tbl[func_name] = function(...)
				local args = {old(...)}

				if callback(old, unpack(args)) == false then return end

				return unpack(args)
			end
		end

		return old
	end

	function utility.RemoveFunctionHook(tag, tbl, func_name)
		local old = hooks[tag]

		if old then
			tbl[func_name] = old
			hooks[tag] = nil
		end
	end
end

function utility.SourceControlClone(str, dir)
	assert(vfs.CreateDirectoriesFromPath("os:" .. dir))
	local dir = R(dir)

	if str:find("%.git$") then
		local url, branch = str:match("(.-github%.com/.-/.-)/tree/(.+)%.git$")

		if url then
			str = url
			branch = "-b " .. branch
		end

		branch = branch or ""

		if vfs.IsDirectory(dir .. ".git") then
			os.execute(print("git -C " .. dir .. " pull"))
		else
			os.execute(print("git clone " .. str .. " " .. dir .. " --depth 1 " .. branch .. " "))
		end
	elseif str:find("hg%.") then
		local clone_, branch = str:match("(.+);(.+)")
		str = clone_ or str

		if branch then
			os.execute("hg clone " .. str .. " " .. dir .. " -r " .. branch)
		else
			os.execute("hg clone " .. str .. " " .. dir)
		end
	elseif str:find("svn%.") or str:find("svn%:") then
		if not system.OSCommandExists("svn") then
			error("svn is not found in PATH")
		end

		os.execute("svn checkout " .. str .. " " .. dir)
	else
		os.execute(str)
	end
end

return utility