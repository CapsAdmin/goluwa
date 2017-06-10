-- golwua cli --gluacheck something.lua

local function get_paths(line)
	local paths = {}
	line = line:trim()

	if line:endswith("/") then
		vfs.Search(line, "lua", function(path)
			if vfs.IsFile(path) then
				table.insert(paths, R(path))
			end
		end)
	elseif line:find(",", nil, true) then
		for path in (line .. ","):gmatch('(.-),') do
			path = path:trim()
			if vfs.IsFile(path) and path:endswith(".lua") then
				table.insert(paths, R(path))
			end
		end
	elseif vfs.IsFile(line) and line:endswith(".lua") then
		table.insert(paths, R(line))
	else
		table.insert(paths, line)
	end

	return paths
end

local function get_luacheck_envrionment()
	local globals = serializer.ReadFile("luadata", "luacheck_cache")

	if not globals then
		globals = {"NULL"}
		local done = {}

		local cl_env = runfile("lua/libraries/gmod/cl_exported.lua")
		local sv_env = runfile("lua/libraries/gmod/sv_exported.lua")

		for _, env in pairs({cl_env, sv_env}) do
			for name in pairs(env.enums) do
				if not done[name] then
					table.insert(globals, name)
					done[name] = true
				end
			end

			for name in pairs(env.globals) do
				if not done[name] then
					table.insert(globals, name)
					done[name] = true
				end
			end

			for lib_name, functions in pairs(env.functions) do
				globals[lib_name] = globals[lib_name] or {fields = {}}
				for func_name in pairs(functions) do
					globals[lib_name].fields[func_name] = {}
				end
			end
		end

		serializer.WriteFile("luadata", "luacheck_cache", globals)
	end

	return globals
end

commands.Add("glua2lua", function(line)
	local paths = get_paths(line)

	for i, path in ipairs(paths) do
		if path == "stdin" or path == "-" then

		else
			local glua, err = vfs.Read(path)
			if glua then
				local lua = gine.PreprocessLua(glua)

				if glua ~= lua then
					local ok, err = loadstring(lua, "")

					if not ok and err:find("jumps into the scope of local") then
						ok = true
						logn(err)
					end

					if ok then
						vfs.Write(path, lua)
					else
						local line, err = err:match(".+\"]:(%d+): (.+)")
						logn(path)
						line = tonumber(line)
						local lines = lua:split("\n")
						for i = -5, 5 do
							local str = lines[line + i] or ""
							if i == 0 then
								str = str .. " <<< " .. err
								logf("%d:\t%s\n", line + i, str)
							else
								logf("%d:\t%s\n", line + i, str)
							end
						end
					end
				end
			else
				logn(path, err)
			end
		end
	end
end)

commands.Add("gluacheck", function(line)
	local paths = get_paths(line)

	local lua_strings = {}

	for i, path in ipairs(paths) do
		local code

		if path == "stdin" or path == "-" then
			code = io.stdin:read("*all")
		else
			code = gine.PreprocessLua(assert(vfs.Read(path)))
		end

		lua_strings[i] = code
	end

	local luacheck = require("luacheck")

	local data = luacheck.check_strings(lua_strings, {
		max_line_length = false,
		read_globals = get_luacheck_envrionment(),
		-- ignore = {"113", "143"}, -- ignore all global lookups
	})

	for i, path in ipairs(paths) do
		for _, msg in ipairs(data[i]) do
			logf("%s:%s:%s %s\n", path, msg.line, msg.column, luacheck.get_message(msg))
		end
	end

	os.exitcode = (data.errors > 0 or data.fatals > 0) and 1 or 0
end)
