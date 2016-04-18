function debug.getprettysource(level, append_line, full_folder)
	local info = debug.getinfo(type(level) == "number" and (level + 1) or level)
	local pretty_source

	if info.source:sub(1, 1) == "@" then
		if full_folder then
			pretty_source = info.source:sub(2)
		else
			pretty_source = info.source:sub(2 + #e.ROOT_FOLDER):match(".-/(.+)") or info.source:sub(2)
		end

		if append_line then
			pretty_source = pretty_source .. ":" .. info.currentline
		end
	else
		pretty_source = info.source:sub(0, 25)
		if pretty_source ~= info.source then
			pretty_source = pretty_source .. "...(+"..#info.source - #pretty_source.." chars)"
		end
	end

	return pretty_source
end

do
	local started = {}

	function debug.loglibrary(library, filter, post_calls_only, lib_name)
		if type(library) == "string" then
			lib_name = library
			library = _G[library]
		end

		if not lib_name then
			for k,v in pairs(_G) do
				if v == library then
					lib_name = k
				end
			end

			if not lib_name then
				for k,v in pairs(package.loaded) do
					if v == library then
						lib_name = k
					end
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
			if type(filter) == "string" then
				filter = {filter}
			end

			filter = filter or {}

			for k,v in pairs(filter) do filter[v] = true end

			started[library] = {}

			local function log_return(...)
				if not filter[name] then
					if (post_calls_only or post_calls_only == nil) and arg_line then
						local ret = {}
						for i = 1, select("#", ...) do
							table.insert(ret, serializer.GetLibrary("luadata").ToString((select(i, ...))):sub(0,20))
						end

						if #ret ~= 0 then
							logf("%s = %s\n", table.concat(ret, ", "), arg_line)
						else
							logn(arg_line)
						end

						arg_line = nil
					end
				end

				setlogfile()

				return ...
			end

			for name, func in pairs(library) do
				if type(func) == "function" or type(func) == "cdata" then
					library[name] = function(...)
						setlogfile(log_name)

						if not post_calls_only and not filter[name] then

							local args = {}
							for i = 1, select("#", ...) do
								table.insert(args, serializer.GetLibrary("luadata").ToString((select(i, ...))))
							end

							arg_line = ("%s.%s(%s) "):format(lib_name, name, table.concat(args, ", "):sub(0,100))
						end

						return log_return(func(...))
					end

					started[library][name] = func
				end
			end
		end
	end

end

function debug.openscript(lua_script, line)
	if not console then return false end

	local path = pvars.Get("editor_path")

	if not path then return false end
	lua_script = R(lua_script) or lua_script

	if not vfs.IsFile(lua_script) then
		logf("debug.openscript: script %q doesn't exist\n", lua_script)
		return false
	end

	path = path:gsub("%%LINE%%", line or 0)
	path = path:gsub("%%PATH%%", lua_script)

	llog("os.execute(%q)", path)

	os.execute(path)

	return true
end

function debug.openfunction(func, line)
	local info = debug.getinfo(func)
	if info.what == "Lua" or info.what == "main" then
		if info.source:sub(1, 1) == "@" then
			info.source = info.source:sub(2)
		end
		return debug.openscript(e.ROOT_FOLDER .. info.source, line or info.linedefined)
	end
end

function debug.trace(skip_print)
	local lines = {}

	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")

		if info then
			lines[#lines + 1] = ("%i: Line %d\t\"%s\"\t%s"):format(level, info.currentline, info.name or "unknown", info.source or "")
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
			if lines[i]:find("event") then
				stop = i - 2
			end
		end

		for i = 2, stop do
			table.insert(str, lines[i])
		end
	else
		str = lines
	end

	str = table.concat(str, "\n")

	if not skip_print then
		logn(str)
	end

	return str
end

function debug.getparams(func)
    local params = {}

	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end

function debug.getparamsx(func)
    local params = {}

	for i = 1, math.huge do
		local key, val = debug.getlocal(func, i)
		if key then
			table.insert(params, {key = key, val = val})
		else
			break
		end
	end

    return params
end

function debug.getupvalues(func)
	local params = {}

	for i = 1, math.huge do
		local key, val = debug.getupvalue(func, i)
		if key then
			table.insert(params, {key = key, val = val})
		else
			break
		end
	end

    return params
end

function debug.dumpcall(level, line, info_match)
	level = level + 1
	local info = debug.getinfo(level)
	local path = e.ROOT_FOLDER .. info.source:sub(2)
	local currentline = line or info.currentline

	if info_match and info.func ~= info_match.func then
		return
	end

	if info.source == "=[C]" then return end
	if info.source:find("ffi_binds") then return end
	if info.source:find("console%.lua") then return end
	if info.source:find("string%.lua") then return end
	if info.source:find("globals%.lua") then return end
	if info.source:find("strung%.lua") then return end
	if path == "../../../lua/init.lua" then return end

	local script = vfs.Read(path)

	if script then
		local lines = script:explode("\n")

		for i = -20, 20 do
			local line = lines[currentline + i]

			if line then
				line = line:gsub("\t", "  ")
				if i == 0 then
					line = (currentline + i) .. ":==>\t" ..  line
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

				logn(line, " ", "This line does not exist. It may be due to inlining so try running jit.off()")
			end
		end
	end

	logn(path)


	logn("LOCALS: ")
	for _, data in pairs(debug.getparamsx(level+1)) do
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

function debug.logcalls(b, type)
	if not b then
		debug.sethook()
		return
	end

	type = type or "r"

	local hook

	hook = function()
		debug.sethook()

		setlogfile("lua_calls")
			logn(debug.traceback())
		setlogfile()

		debug.sethook(hook, type)
	end

	debug.sethook(hook, type)
end

function debug.stepin()
	if not commands.curses then return end

	debug.debugging = true

	local step

	local curses = require("ffi.curses")

	step = function(mode, line)
		commands.Clear()

		debug.dumpcall(2, line)
		curses.doupdate()

		while debug.debugging do
			local key = repl.GetActiveKey()

			if key == "KEY_SPACE" then
				debug.debugging = false
				debug.sethook()
				commands.ScrollLogHistory(1)
				break
			elseif key == "KEY_ENTER" then
				debug.sethook(step, "r")
				break
			elseif key == "KEY_LEFT" then
				debug.sethook(step, "r")
				break
			elseif key == "KEY_RIGHT" then
				debug.sethook(step, "l")
				break
			elseif key == "KEY_NPAGE" then
				debug.sethook(step, "c")
				break
			elseif key == "KEY_DOWN" then
				debug.sethook(step, "l")
				break
			end
		end
	end

	debug.sethook(step, "c")
end