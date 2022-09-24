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
				list.insert(found, res)
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
	return list.concat(found, "\n")
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
							list.remove(params, 1)
						end

						nice_name = ("%s%s%s(%s)"):format(name, dot, key, list.concat(params, ", "))
					else
						nice_name = ("%s.%s = %s"):format(name, key, val)
					end

					if name == "_G" or name == "_M" then
						list.insert(found, {key = key, val = val, name = name, nice_name = nice_name})
					else
						list.insert(
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

		list.sort(found, function(a, b)
			return #a.key < #b.key
		end)

		for _, v in ipairs(found) do
			list.insert(tbl, v)
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
							list.insert(out[path], {str = line, line = i, start = start, stop = stop})
						end
					end
				end
			end
		end

		return out
	end
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
				list.insert(args, tostringx(v))
			end

			logn(name or "", ".", v.func_name, "(", list.concat(args, ", "), ")")
		end
	end
end

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