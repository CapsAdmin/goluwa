local utility = _G.utility or {}

do
	local done = {}

	function utility.StartMonitorCoverage(file_path)
		debug.sethook(
			function(event, line)
				for i = 2, math.huge do
					local info = debug.getinfo(i)

					if not info then break end

					if info.source:ends_with(file_path) then
						done[info.currentline] = true
					end
				end
			end,
			"l"
		)
	end

	function utility.StopMonitorCoverage()
		debug.sethook()
		local res = done
		done = {}
		return res
	end
end

function utility.NumberToBytes(num, endian, signed)
	if num < 0 and not signed then
		num = -num
		print("warning, dropping sign from number converting to unsigned")
	end

	local res = {}
	local n = math.ceil(select(2, math.frexp(num)) / 8) -- number of bytes to be used.
	if signed and num < 0 then num = num + 2 ^ n end

	for k = n, 1, -1 do -- 256 = 2^8 bits per char.
		local mul = 2 ^ (8 * (k - 1))
		res[k] = math.floor(num / mul)
		num = num - res[k] * mul
	end

	assert(num == 0)

	if endian == "big" then
		local t = {}

		for k = 1, n do
			t[k] = res[n - k + 1]
		end

		res = t
	end

	local bytes = string.char(unpack(res))

	if #bytes ~= 4 then bytes = bytes .. ("\0"):rep(4 - #bytes) end

	return bytes
end

function utility.BytesToNumber(str, endian, signed)
	local t = {str:byte(1, -1)}

	if endian == "big" then --reverse bytes
		local tt = {}

		for k = 1, #t do
			tt[#t - k + 1] = t[k]
		end

		t = tt
	end

	local n = 0

	for k = 1, #t do
		n = n + t[k] * 2 ^ ((k - 1) * 8)
	end

	if signed then
		n = (n > 2 ^ (#t * 8 - 1) - 1) and (n - 2 ^ (#t * 8)) or n -- if last bit set, negative.
	end

	return n
end

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
					table.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end

			original = table.remove(found, #found).name
		elseif ext == "dll" then
			for name in content:gmatch("([%.%w_-]+%.dll)\0") do
				if not done[name] then
					table.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end
		--original = table.remove(found, 1).name
		elseif ext == "dylib" then
			for name in content:gmatch("([%.%w_-]+%.dylib)\0") do
				if not done[name] then
					table.insert(found, {name = name, status = "MISSING"})
					done[name] = true
				end
			end

			original = table.remove(found, 1).name
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

function utility.AddPackageLoader(func, loaders)
	loaders = loaders or package.loaders

	for i, v in ipairs(loaders) do
		if v == func then
			table.remove(loaders, i)

			break
		end
	end

	table.insert(loaders, func)
end

do
	function utility.StartRecordingCalls(lib, filter)
		lib.old_funcs = lib.old_funcs or {}
		lib.call_log = lib.call_log or {}
		local i = 1

		for k, v in pairs(lib) do
			if (type(v) == "cdata" or type(v) == "function") and (not filter or filter(k)) then
				lib.old_funcs[k] = v
				lib[k] = function(...)
					local ret = v(...)
					lib.call_log[i] = {func_name = k, ret = ret, args = {...}}
					i = i + 1
					return ret
				end
			end
		end
	end

	function utility.StopRecordingCalls(lib, name)
		if not lib.old_funcs then return end

		for k, v in pairs(lib.old_funcs) do
			lib[k] = v
		end

		local tbl = lib.call_log
		lib.call_log = nil

		for i, v in ipairs(tbl) do
			log(("%3i"):format(i), ": ")

			if v.ret ~= nil then log(v.ret, " ") end

			local args = {}

			for k, v in pairs(v.args) do
				table.insert(args, tostringx(v))
			end

			logn(name or "", ".", v.func_name, "(", table.concat(args, ", "), ")")
		end
	end
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
				table.insert(paths, R(path))
			end)
		elseif handle_path(str):ends_with("/*") then
			for _, path in ipairs(vfs.Find(handle_path(str:sub(0, -2)), true)) do
				if not extensions or vfs.GetExtensionFromPath(path):ends_with_these(extensions) then
					table.insert(paths, path)
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
					table.insert(paths, R(path))
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
					table.insert(paths, R(path))
				end
			end
		elseif
			vfs.IsFile(handle_path(str)) and
			(
				not extensions or
				vfs.GetExtensionFromPath(str):ends_with_these(extensions)
			)
		then
			table.insert(paths, R(handle_path(str)))
		else
			table.insert(paths, handle_path(str))
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
		table.insert(stack, os.clock())
	end

	function utility.PopTimeWarning(what, threshold, category)
		threshold = threshold or 0.1
		local start_time = table.remove(stack)

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
					table.insert(self.queue, {key = key, args = {...}})
				end
			end,
		}
	)
end

do
	function utility.StripLuaCommentsAndStrings(code, post_process)
		code = code:gsub("\\\\", "____ESCAPE_ESCAPE")
		code = code:gsub("\\'", "____SINGLE_QUOTE_ESCAPE")
		code = code:gsub("\\\"", "____DOUBLE_QUOTE_ESCAPE")
		local singleline_comments = {}
		local multiline_comments = {}
		local double_quote_strings = {}
		local single_quote_strings = {}
		local multiline_strings = {}
		code = code:gsub("(%-%-%[(=*)%[.-%]%2%])", function(str)
			table.insert(multiline_comments, str)
			return "____COMMENT_MULTILINE_" .. #multiline_comments .. "____" .. " "
		end)
		code = code:gsub("(%[(=*)%[.-%]%2%])", function(str)
			table.insert(multiline_strings, str)
			return "____STRING_MULTILINE_" .. #multiline_strings .. "____" .. " "
		end)
		code = code:gsub("%b\"\"", function(str)
			table.insert(double_quote_strings, str)
			return "____STRING_DOUBLE_QUOTE_" .. #double_quote_strings .. "____" .. " "
		end)
		code = code:gsub("(%-%-.-)\n", function(str)
			table.insert(singleline_comments, str)
			return "____COMMENT_SINGLELINE_" .. #singleline_comments .. "____" .. " "
		end)
		code = code:gsub("%b''", function(str)
			table.insert(single_quote_strings, str)
			return "____STRING_SINGLE_QUOTE_" .. #single_quote_strings .. "____" .. " "
		end)
		local res = {
			singleline_comments = singleline_comments,
			multiline_comments = multiline_comments,
			double_quote_strings = double_quote_strings,
			single_quote_strings = single_quote_strings,
			multiline_strings = multiline_strings,
		}

		if post_process then code = post_process(code, res) or code end

		return code, res
	end

	function utility.RestoreLuaCommentsAndStrings(code, data)
		for i, v in ipairs(data.multiline_comments) do
			code = code:replace("____COMMENT_MULTILINE_" .. i .. "____", v)
		end

		for i, v in ipairs(data.multiline_strings) do
			code = code:replace("____STRING_MULTILINE_" .. i .. "____", v)
		end

		for i, v in ipairs(data.double_quote_strings) do
			code = code:replace("____STRING_DOUBLE_QUOTE_" .. i .. "____", v)
		end

		for i, v in ipairs(data.singleline_comments) do
			code = code:replace("____COMMENT_SINGLELINE_" .. i .. "____", v .. "\n")
		end

		for i, v in ipairs(data.single_quote_strings) do
			code = code:replace("____STRING_SINGLE_QUOTE_" .. i .. "____", v)
		end

		code = code:gsub("____ESCAPE_ESCAPE", "\\\\")
		code = code:gsub("____SINGLE_QUOTE_ESCAPE", "\\'")
		code = code:gsub("____DOUBLE_QUOTE_ESCAPE", "\\\"")
		return code
	end
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

do
	local ffi = desire("ffi")
	local ok, lib

	if ffi then
		ok, lib = pcall(ffi.load, "lz4")

		if ok then
			ffi.cdef[[
				int LZ4_compress        (const char* source, char* dest, int inputSize);
				int LZ4_decompress_safe (const char* source, char* dest, int inputSize, int maxOutputSize);
			]]

			function utility.Compress(data)
				local size = #data
				local buf = ffi.new("uint8_t[?]", ((size) + ((size) / 255) + 16))
				local res = lib.LZ4_compress(data, buf, size)

				if res ~= 0 then return ffi.string(buf, res) end
			end

			function utility.Decompress(source, orig_size)
				local dest = ffi.new("uint8_t[?]", orig_size)
				local res = lib.LZ4_decompress_safe(source, dest, #source, orig_size)

				if res > 0 then return ffi.string(dest, res) end
			end
		end
	end

	if not ok then
		utility.Compress = function()
			error("lz4 is not avaible: " .. lib, 2)
		end
		utility.Decompress = utility.Compress
	end
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

function utility.FindReferences(reference)
	local done = {}
	local found = {}
	local found2 = {}
	local revg = {}

	for k, v in pairs(_G) do
		revg[v] = tostring(k)
	end

	local function search(var, str)
		if done[var] then return end

		if revg[var] then str = revg[var] end

		if rawequal(var, reference) then
			local res = str .. " = " .. tostring(reference)

			if not found2[res] then
				table.insert(found, res)
				found2[res] = true
			end
		end

		local t = type(var)

		if t == "table" then
			done[var] = true

			for k, v in pairs(var) do
				search(k, str .. "." .. tostring(k))
				search(v, str .. "." .. tostring(k))
			end
		elseif t == "function" then
			done[var] = true

			for _, v in pairs(debug.get_upvalues(var)) do
				if v.val then search(v.val, str .. "^" .. v.key) end
			end
		end
	end

	search(_G, "_G")
	return table.concat(found, "\n")
end

function utility.TableToColumns(title, tbl, columns, check, sort_key)
	if false and gui then
		local frame = gui.CreatePanel("frame", nil, "table_to_columns_" .. title)
		frame:SetSize(Vec2() + 300)
		frame:SetTitle(title)
		local list = frame:CreatePanel("list")
		list:SetupLayout("fill")
		local keys = {}

		for i, v in ipairs(columns) do
			keys[i] = v.friendly or v.key
		end

		list:SetupSorted(unpack(keys))

		for _, data in ipairs(tbl) do
			local args = {}

			for i, info in ipairs(columns) do
				if info.tostring then
					args[i] = info.tostring(data[info.key], data, tbl)
				else
					args[i] = data[info.key]
				end

				if type(args[i]) == "string" then args[i] = args[i]:trim() end
			end

			list:AddEntry(unpack(args))
		end

		return
	end

	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then table.insert(top, {key = k, val = v}) end
	end

	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...)
				return ...
			end
			data.friendly = data.friendly or data.key
			max_lengths[data.key] = max_lengths[data.key] or 0
			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then max_lengths[data.key] = #str end

			temp[key] = data
		end
	end

	columns = temp
	local width = 0

	for _, v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end

		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "
	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (
			" "
		):rep(width / 2 - math.floor(#title / 2)) .. title .. (
			" "
		):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (
				" "
			):rep(-#v.friendly + max_lengths[v.key] - 1) -- 2 = : + |
	end

	out = out .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end

	out = out .. "|\n"

	for _, v in ipairs(top) do
		for _, column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (
					" "
				):rep(-#v.str[column.key] + column.length + 1)
		end

		out = out .. "|\n"
	end

	out = out .. "|"
	out = out .. ("_"):rep(width - 1) .. "|\n"
	return out
end

function utility.TableToFlags(flags, valid_flags, operation)
	if type(flags) == "string" then flags = {flags} end

	local out = 0

	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]

		if not flag then error("invalid flag", 2) end

		if type(operation) == "function" then
			out = operation(out, tonumber(flag))
		else
			out = bit.band(out, tonumber(flag))
		end
	end

	return out
end

function utility.FlagsToTable(flags, valid_flags)
	if not flags then return valid_flags.default_valid_flag end

	local out = {}

	for k, v in pairs(valid_flags) do
		if bit.band(flags, v) > 0 then out[k] = true end
	end

	return out
end

do -- long long
	local ffi = desire("ffi")

	if ffi then
		local btl = ffi.typeof([[union {
			char b[8];
			int64_t i;
		  }]])

		function utility.StringToLongLong(str)
			return btl(str).i
		end
	end
end

do -- find value
	local found = {}
	local done = {}
	local skip = {
		ffi = true,
	}
	local keywords = {
		AND = function(a, func, x, y)
			return func(a, x) and func(a, y)
		end,
	}

	local function args_call(a, func, ...)
		local tbl = {...}

		for i = 1, #tbl do
			local val = tbl[i]

			if not keywords[val] then
				local keyword = tbl[i + 1]

				if keywords[keyword] and tbl[i + 2] then
					local ret = keywords[keyword](a, func, val, tbl[i + 2])

					if ret ~= nil then return ret end
				else
					local ret = func(a, val)

					if ret ~= nil then return ret end
				end
			end
		end
	end

	local function strfind(str, ...)
		return args_call(str, string.compare, ...) or args_call(str, string.find, ...)
	end

	local function _find(tbl, name, dot, level, ...)
		if level >= 3 then return end

		for key, val in pairs(tbl) do
			local T = type(val)
			key = tostring(key)

			if name == "_M" then
				if val.Type == val.ClassName then
					key = val.Type
				else
					key = val.Type .. "." .. val.ClassName
				end
			end

			if not skip[key] and T == "table" and not done[val] then
				done[val] = true
				_find(val, name .. "." .. key, dot, level + 1, ...)
			else
				if (T == "function" or T == "number") and strfind(name .. "." .. key, ...) then
					local nice_name

					if type(val) == "function" then
						local params = debug.get_params(val)

						if dot == ":" and params[1] == "self" then
							table.remove(params, 1)
						end

						nice_name = ("%s%s%s(%s)"):format(name, dot, key, table.concat(params, ", "))
					else
						nice_name = ("%s.%s = %s"):format(name, key, val)
					end

					if name == "_G" or name == "_M" then
						table.insert(found, {key = key, val = val, name = name, nice_name = nice_name})
					else
						table.insert(
							found,
							{
								key = ("%s%s%s"):format(name, dot, key),
								val = val,
								name = name,
								nice_name = nice_name,
							}
						)
					end
				end
			end
		end
	end

	local function find(tbl, ...)
		found = {}
		_find(...)

		table.sort(found, function(a, b)
			return #a.key < #b.key
		end)

		for _, v in ipairs(found) do
			table.insert(tbl, v)
		end
	end

	function utility.FindValue(...)
		local found = {}
		done = {
			[_G] = true,
			[package] = true,
			[_OLD_G] = true,
		}
		find(found, _G, "_G", ".", 1, ...)
		find(found, prototype.GetAllRegistered(), "_M", ":", 1, ...)
		return found
	end
end

do -- find in files
	function utility.FindInLoadedLuaFiles(find)
		local out = {}

		for path in pairs(vfs.GetLoadedLuaFiles()) do
			if
				not path:find("modules") or
				(
					path:find("ffi", nil, true) and
					(
						not path:find("header.lua") and
						not path:find("enums")
					)
				)
			then
				local str = vfs.Read(path)

				if str then
					for i, line in ipairs(str:split("\n")) do
						local start, stop = line:find(find)

						if start then
							out[path] = out[path] or {}
							table.insert(out[path], {str = line, line = i, start = start, stop = stop})
						end
					end
				end
			end
		end

		return out
	end
end

do
	-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/stage1.lua
	local size_units = {
		"B",
		"KiB",
		"MiB",
		"GiB",
		"TiB",
		"PiB",
		"EiB",
		"ZiB",
		"YiB",
	}

	function utility.FormatFileSize(size)
		local unit_index = 1

		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end

		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
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

function utility.SwapEndian(num, size)
	if size == 4 then return bit.bswap(num) end

	if size == 2 then return bit.rshift(bit.bswap(num), 16) end

	local result = 0

	for shift = 0, (size * 8) - 8, 8 do
		result = bit.bor(bit.lshift(result, 8), bit.band(bit.rshift(num, shift), 0xff))
	end

	return result
end

function utility.NumberToBinary(num, bits)
	bits = bits or 32
	local bin = {}

	for i = 1, bits do
		if num > 0 then
			rest = math.fmod(num, 2)
			table.insert(bin, rest)
			num = (num - rest) / 2
		else
			table.insert(bin, 0)
		end
	end

	return table.concat(bin):reverse()
end

function utility.BinaryToNumber(bin)
	return tonumber(bin, 2)
end

function utility.NumberToHex(num)
	return ("0x%X"):format(num)
end

function utility.HexToNumber(hex)
	return tonumber(hex, 16)
end

function utility.NumberToOctal(num)
	return ("%o"):format(num)
end

function utility.OctalToNumber(hex)
	return tonumber(hex, 8)
end

return utility