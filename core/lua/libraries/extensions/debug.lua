do
	local file
	local max_lines = 10000

	function debug.log_lines(b)
		if b == nil then b = not file end

		if b then
			local path = R("data/") .. "debug_lines.lua"
			file = assert(io.open(path, "wb"))
			jit.off()
			jit.flush()
			local i = 0

			debug.sethook(
				function()
					if not file then
						debug.sethook()
						return
					end

					local info = debug.getinfo(2)

					if i > max_lines then
						file:close()
						file = assert(io.open(path, "wb"))
						i = 0
					end

					file:write(info.source, ":", info.currentline, "\n")
					file:flush()
					i = i + 1
				end,
				"l"
			)
		else
			if file then
				file:close()
				file = nil
			end

			jit.on()
			jit.flush()
			debug.sethook()
		end
	end
end

function debug.get_name(func)
	local source = debug.get_source(func)
	local name, args = source:match("^(%S+)%s-=%s-function%s-(%b())")

	if name then
		name = name .. args
	else
		name = source:match("local%s-function%s-(%S+%b())") or
			source:match("^%s-function%s-(%S+%b())")
	end

	return name or "*anonymous*"
end

function debug.get_source(func)
	local info = debug.getinfo(func)
	local src = vfs.Read(e.ROOT_FOLDER .. "/" .. info.source:sub(2))

	if not src then src = vfs.Read(info.source:sub(2)) end

	if src then
		local lines = src:split("\n")
		local str = {}

		for i = info.linedefined, info.lastlinedefined do
			table.insert(str, lines[i])
		end

		return table.concat(str, "\n")
	end

	return "source unavailble for: " .. info.source
end

function debug.get_pretty_source(level, append_line, full_folder)
	local info = debug.getinfo(type(level) == "number" and (level + 1) or level)

	if info.source == "=[C]" and type(level) == "number" then
		info = debug.getinfo(type(level) == "number" and (level + 2) or level)
	end

	local pretty_source = "debug.getinfo = nil"

	if info then
		if info.source:sub(1, 1) == "@" then
			pretty_source = info.source:sub(2)

			if not full_folder and vfs then
				pretty_source = vfs.FixPathSlashes(pretty_source:replace(e.ROOT_FOLDER, ""))
			end

			if append_line then
				local line = info.currentline

				if line == -1 then line = info.linedefined end

				pretty_source = pretty_source .. ":" .. line
			end
		else
			pretty_source = info.source:sub(0, 25)

			if pretty_source ~= info.source then
				pretty_source = pretty_source .. "...(+" .. #info.source - #pretty_source .. " chars)"
			end

			if pretty_source == "=[C]" and jit.vmdef then
				local num = tonumber(tostring(info.func):match("#(%d+)"))

				if num then pretty_source = jit.vmdef.ffnames[num] end
			end
		end
	end

	return pretty_source
end

do
	local started = {}

	function debug.log_library(library, filter, post_calls_only, lib_name)
		if type(library) == "string" then
			lib_name = library
			library = _G[library]
		end

		if not lib_name then
			for k, v in pairs(_G) do
				if v == library then lib_name = k end
			end

			if not lib_name then
				for k, v in pairs(package.loaded) do
					if v == library then lib_name = k end
				end
			end

			lib_name = lib_name or "unknown"
		end

		local log_name = lib_name .. "_calls"
		local arg_line

		if started[library] then
			for name, func in pairs(started[library]) do
				library[name] = func
			end
		else
			if type(filter) == "string" then filter = {filter} end

			filter = filter or {}

			for _, v in pairs(filter) do
				filter[v] = true
			end

			started[library] = {}

			local function log_return(...)
				if not filter[name] then
					if (post_calls_only or post_calls_only == nil) and arg_line then
						local ret = {}

						for i = 1, select("#", ...) do
							table.insert(ret, serializer.GetLibrary("luadata").ToString((select(i, ...))):sub(0, 20))
						end

						if #ret ~= 0 then
							logf("%s = %s\n", table.concat(ret, ", "), arg_line)
						else
							logn(arg_line)
						end

						arg_line = nil
					end
				end

				set_log_file()
				return ...
			end

			for name, func in pairs(library) do
				if type(func) == "function" or type(func) == "cdata" then
					library[name] = function(...)
						set_log_file(log_name)

						if not post_calls_only and not filter[name] then
							local args = {}

							for i = 1, select("#", ...) do
								table.insert(args, serializer.GetLibrary("luadata").ToString((select(i, ...))))
							end

							arg_line = ("%s.%s(%s) "):format(lib_name, name, table.concat(args, ", "):sub(0, 100))
						end

						return log_return(func(...))
					end
					started[library][name] = func
				end
			end
		end
	end
end

function debug.trace(skip_print)
	local lines = {}

	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")

		if info then
			lines[#lines + 1] = (
				"%i:\t\"%s\"\t%s:%d"
			):format(level, info.name or "unknown", info.source or "", info.currentline)
		else
			break
		end
	end

	local str

	if debug.debugging then
		str = {}
		-- this doesn't really be long here..
		local stop = #lines

		for i = 2, #lines do
			if lines[i]:find("event") then stop = i - 2 end
		end

		for i = 2, stop do
			table.insert(str, lines[i])
		end
	else
		str = lines
	end

	str = table.concat(str, "\n")

	if not skip_print then logn(str) end

	return str
end

function debug.get_params(func)
	local params = {}

	for i = 1, math.huge do
		local key = debug.getlocal(func, i)

		if key then table.insert(params, key) else break end
	end

	return params
end

function debug.get_paramsx(func)
	local params = {}

	for i = 1, math.huge do
		local key, val = debug.getlocal(func, i)

		if key then table.insert(params, {key = key, val = val}) else break end
	end

	return params
end

function debug.get_upvalues(func)
	local params = {}

	for i = 1, math.huge do
		local key, val = debug.getupvalue(func, i)

		if key then table.insert(params, {key = key, val = val}) else break end
	end

	return params
end

function debug.dump_call(level, line, info_match)
	level = level + 1
	local info = debug.getinfo(level)
	local path = e.ROOT_FOLDER .. info.source:sub(2)
	local currentline = line or info.currentline

	if info_match and info.func ~= info_match.func then return end

	if info.source == "=[C]" then return end

	if info.source:find("ffi_binds") then return end

	if info.source:find("console%.lua") then return end

	if info.source:find("string%.lua") then return end

	if info.source:find("globals%.lua") then return end

	if info.source:find("strung%.lua") then return end

	if path == "../../../lua/init.lua" then return end

	if vfs.IsFile(path) then
		local script = vfs.Read(path)
		local lines = script:split("\n")

		for i = -20, 20 do
			local line = lines[currentline + i]

			if line then
				line = line:gsub("\t", "  ")

				if i == 0 then
					line = (currentline + i) .. ":==>\t" .. line
				else
					line = (currentline + i) .. ":\t" .. line
				end

				logn(line)
			else
				if i == 0 then
					line = (">"):rep(string.len(currentline)) .. ":"
				else
					line = (currentline + i) .. ":"
				end

				logn(
					line,
					" ",
					"This line does not exist. It may be due to inlining so try running jit.off()"
				)
			end
		end
	end

	logn(path)
	logn("LOCALS: ")

	for _, data in pairs(debug.get_paramsx(level + 1)) do
		--if not data.key:find("(",nil,true) then
		local val

		if type(data.val) == "table" then
			val = tostring(data.val)
		elseif type(data.val) == "string" then
			val = data.val:sub(0, 10)

			if val ~= data.val then
				val = val .. " .. " .. utility.FormatFileSize(#data.val)
			end
		else
			val = serializer.GetLibrary("luadata").ToString(data.val)
		end

		logf("%s = %s\n", data.key, val)
	--end
	end

	logn(debug.traceback())

	if info_match then
		print(info_match.func)
		print(info.func)
	end

	return true
end

function debug.log_calls(b, type)
	if not b then
		debug.sethook()
		return
	end

	type = type or "r"
	local hook
	hook = function()
		debug.sethook()
		set_log_file("lua_calls")
		logn(debug.traceback())
		set_log_file()
		debug.sethook(hook, type)
	end
	debug.sethook(hook, type)
end