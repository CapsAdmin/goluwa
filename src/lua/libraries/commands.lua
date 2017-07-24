local commands = _G.commands or {}

do
	local function vector(str, ctor)
		local num = str:split(" ")
		local ok = true

		if #num == 3 then
			for i, v in ipairs(num) do
				num[i] = tonumber(v)

				if not num[i] then
					ok = false
					break
				end
			end

			return ctor(unpack(num))
		end

		if not ok then
			local test = str:match("(b())")
			if test then
				return vector(test:sub(2, -2), ctor)
			end
		end
	end

	commands.ArgumentTypes = {
		["nil"] = function(str) return str end,
		self = function(str, me) return me end,
		vec3 = function(str, me) return vector(str, Vec3) end,
		ang3 = function(str, me) return vector(str, Ang3) end,
		vector = function(str, me) return vector(str, Vec3) end,
		angle = function(str, me) return vector(str, Ang3) end,
		boolean = function(arg)
			arg = arg:lower()

			if arg == "1" or arg == "true" or arg == "on" or arg == "yes" or arg == "y" then
				return true
			end

			if arg == "0" or arg == "false" or arg == "off" or arg == "no" or arg == "n" then
				return false
			end

			return false
		end,
		number = function(arg)
			return tonumber(arg)
		end,
		string = function(arg)
			if #arg > 0 then
				return arg
			end
		end,
		string_trim = function(arg)
			arg = arg:trim()
			if #arg > 0 then
				return arg
			end
		end,
		var_arg = function(arg) return arg end,
		arg_line = function(arg) return arg end,
		string_rest = function(arg) return arg end,
	}

	function commands.StringToType(type, ...)
		return commands.ArgumentTypes[type](...)
	end
end

do -- commands
	commands.added = commands.added or {}

	local capture_symbols = {
		["\""] = "\"",
		["'"] = "'",
		["("] = ")",
		["["] = "]",
		["`"] = "`",
		["´"] = "´",
	}

	local function parse_args(arg_line)
		if not arg_line or arg_line:trim() == "" then return {} end

		local args = {}
		local capture = {}
		local escape  = false

		local in_capture = false

		for _, char in ipairs(utf8.totable(arg_line)) do
			if escape then
				table.insert(capture, char)
				escape = false
			else
				if in_capture then
					if char == in_capture then
						in_capture = false
					end

					table.insert(capture, char)
				else
					if char == "," then
						table.insert(args, table.concat(capture, ""))
						table.clear(capture)
					else
						table.insert(capture, char)

						if capture_symbols[char] then
							in_capture = capture_symbols[char]
						end

						if char == "\\" then
							escape = true
						end
					end
				end
			end
		end

		table.insert(args, table.concat(capture, ""))

		return args
	end

	local start_symbols = {
		"%!",
		"%.",
		"%/",
		"",
	}

	commands.sub_commands = commands.sub_commands or {}

	local function parse_line(line)
		for _, v in ipairs(start_symbols) do
			local start, rest = line:match("^(" .. v .. ")(.+)")
			if start then

				for _, str in ipairs(commands.sub_commands) do
					local cmd, rest_ = rest:match("^("..str..")%s+(.+)$")
					if cmd then
						return v, cmd, rest_
					else
						local cmd, rest_ = rest:match("^("..str..")$")
						if cmd then
							return v, cmd, rest_
						end
					end
				end

				local cmd, rest_ = rest:match("^(%S+)%s+(.+)$")
				if not cmd then
					return v, rest:trim()
				else
					return v, cmd, rest_
				end
			end
		end
	end

	function commands.Add(command, callback)
		local aliases = command
		local argtypes
		local defaults

		if command:find("=") then
			aliases, argtypes =  command:match("(.+)=(.+)")
			if not aliases then
				aliases = command
			end
		end

		aliases = aliases:split("|")

		if argtypes then
			argtypes = argtypes:split(",")

			for i, v in ipairs(argtypes) do
				if v:find("|", nil, true) then
					argtypes[i] = v:split("|")
				else
					argtypes[i] = {v}
				end
			end

			for i, types in ipairs(argtypes) do
				for i2, arg in ipairs(types) do
					if arg:find("[", nil, true) then
						local temp, default = arg:match("(.+)(%b[])")

						if commands.ArgumentTypes[temp] then
							defaults = defaults or {}
							default = default:sub(2, -2)

							-- special case
							if temp == "string" then
								defaults[i] = default
							else
								defaults[i] = commands.StringToType(temp, default)
							end

							types[i2] = temp
						else
							log(aliases[1] .. ": no type information found for \"" .. temp .. "\"")
						end
					end
				end
			end
		end

		commands.added[aliases[1]] = {
			aliases = aliases,
			argtypes = argtypes,
			callback = callback,
			defaults = defaults
		}

		-- sub commands
		if #aliases == 1 and aliases[1]:find(" ", nil, true) then
			if not table.hasvalue(commands.sub_commands, aliases[1]) then
				table.insert(commands.sub_commands, aliases[1])
			end
		end
	end

	function commands.Remove(alias)
		local command, msg = commands.FindCommand(alias)

		if command then
			commands.added[command.aliases[1]] = nil
			return true
		end

		return nil, msg
	end

	function commands.FindCommand(str)
		local found = {}

		for _, command in pairs(commands.added) do
			for _, alias in ipairs(command.aliases) do
				if str:lower() == alias:lower() then
					return command
				end
				table.insert(found, {distance = string.levenshtein(str, alias), alias = alias, command = command})
			end
		end

		table.sort(found, function(a, b) return a.distance < b.distance end)

		return nil, "could not find command " .. str .. ". did you mean " .. found[1].alias .. "?"
	end

	function commands.GetCommands()
		return commands.added
	end

	function commands.IsAdded(alias)
		return commands.FindCommand(alias) ~= nil
	end

 	function commands.AddHelp(alias, help)
  		local command, msg = commands.FindCommand(alias)

  		if command then
			command.help = help
			return true
		end

		return nil, msg
  	end

	function commands.AddAutoComplete(alias, callback)
  		local command, msg = commands.FindCommand(alias)

  		if command then
			command.autocomplete = callback
			return true
		end

		return nil, msg
  	end

	function commands.GetHelpText(alias)
		local command, msg = commands.FindCommand(alias)
		if not command then return false, msg end

		local str = command.help

		if str then
			return str
		end

		local params = {}

		for i = 1, math.huge do
			local key = debug.getlocal(command.callback, i)
			if key then
				table.insert(params, key)
			else
				break
			end
		end

		str = alias .. " "

		for i = 1, #params do
			local arg_name = params[i]
			if arg_name ~= "_" then
				local types = command.argtypes and command.argtypes[i]
				local default = command.defaults and command.defaults[i]

				if types then
					str = str .. arg_name .. ""

					str = str .. "<"
					for _, type in pairs(types) do
						str = str .. type
						if _ ~= #types then
							str = str .. " or "
						end
					end
					str = str .. ">"
				else
					str = str .. "*" .. arg_name .. "*"
				end

				if default then
					str = str .. " = " .. tostring(default)
				end

				if i ~= #params then
					str = str .. ", "
				end
			end
		end

		local help = alias .. ":\n"
		help = help .. "\tusage example:\n\t\t" .. str .. "\n"
		help = help .. "\tlocation:\n\t\t" .. debug.getprettysource(command.callback, true) .. "\n"

		return help
	end

	function commands.IsCommandStringValid(str)
		return parse_line(str)
	end

	function commands.ParseString(str)
		local symbol, alias, arg_line = parse_line(str)

		local args = parse_args(arg_line)
		local command, err = commands.FindCommand(alias)

		if not command then return command, err end

		return command, alias, arg_line, args
	end

	function commands.GetArgLine()
		return command.arg_line or ""
	end

	function commands.RunCommandString(str)
		local command, alias, arg_line, args = assert(commands.ParseString(str))

		command.arg_line = arg_line

		local ret, reason = event.Call("PreCommandExecute", command, alias, unpack(args))

		if ret == false then return ret, reason or "no reason" end

		if command.argtypes then
			for i, arg in ipairs(args) do
				if command.argtypes[i] then
					for _, arg_type in ipairs(command.argtypes[i]) do
						if not commands.ArgumentTypes[arg_type] then
							log(alias .. ": no type information found for \"" .. arg_type .. "\"")
						end
					end
				end
			end

			for i, arg_types in ipairs(command.argtypes) do
				if command.defaults and args[i] == nil and command.defaults[i] then
					args[i] = command.defaults[i]
				end

				if args[i] ~= nil or not table.hasvalue(arg_types, "nil") then
					local val

					for _, arg_type in ipairs(arg_types) do
						if arg_type == "arg_line" then
							val = arg_line
						elseif arg_type == "string_rest" then
							val = table.concat({select(i, unpack(args))}, ","):trim()
						else
							local test = commands.ArgumentTypes[arg_type](args[i] or "")

							if test ~= nil then
								val = test
								break
							end
						end
					end

					if val == nil and command.defaults and command.defaults[i] and args[i] then
						val = command.defaults[i]
						local err = "unable to convert argument " .. (debug.getlocal(command.callback, i) or i) .. " >>|" .. (args[i] or "") .. "|<< to one of these types: " .. table.concat(command.argtypes[i], ", ") .. "\n"
						err = err .. "defaulting to " .. tostring(command.defaults[i])
						logn(err)
					end

					if val == nil then
						local err = "unable to convert argument " .. (debug.getlocal(command.callback, i) or i) .. " >>|" .. (args[i] or "") .. "|<< to one of these types: " .. table.concat(command.argtypes[i], ", ") .. "\n"
						err = err .. commands.GetHelpText(alias) .. "\n"
						error(err)
					end

					args[i] = val
				end
			end
		end

		return command.callback(unpack(args))
	end

	function commands.ExecuteCommandString(str)
		local a, b, c = pcall(commands.RunCommandString, str)

		if a == false then
			return false, b
		end

		if b == false then
			return false, c or "unknown reason"
		end

		return true
	end

	do
		commands.run_lua_environment = {}

		function commands.SetLuaEnvironmentVariable(key, var)
			commands.run_lua_environment[key] = var
		end

		function commands.RunLuaString(line, env_name)
			commands.SetLuaEnvironmentVariable("gl", desire("opengl"))
			commands.SetLuaEnvironmentVariable("ffi", desire("ffi"))
			commands.SetLuaEnvironmentVariable("findo", prototype.FindObject)
			if WINDOW then commands.SetLuaEnvironmentVariable("copy", window.SetClipboard) end

			local lua = ""

			for k in pairs(commands.run_lua_environment) do
				lua = lua .. ("local %s = commands.run_lua_environment.%s;"):format(k, k)
			end

			lua = lua .. line

			return assert(loadstring(lua, env_name or line))()
		end

		function commands.ExecuteLuaString(line, log_error, env_name)
			local ret = {pcall(commands.RunLuaString, line, env_name)}
			local ok = table.remove(ret, 1)

			if not ok then
				if log_error then
					logn(ret[1])
				end
				return false, ret[1]
			end

			return true, unpack(ret)
		end
	end

	function commands.RunString(line, skip_lua, skip_split, log_error)
		if CLI then
			logn(">> ", line)
		end

		if not skip_split and line:find("\n") then
			for line in (line .. "\n"):gmatch("(.-)\n") do
				commands.RunString(line, skip_lua, skip_split, log_error)
			end
			return
		end

		local ok, msg = commands.ExecuteCommandString(line)

		if not ok and log_error and not msg:find("could not find command") then
			logn(msg)

			return
		end

		if not ok and not skip_lua then
			ok, msg = commands.ExecuteLuaString(line)
		end

		if not ok and log_error then
			logn(msg)
		end
	end

	commands.Add("help|usage=string|nil", function(cmd)
		if not cmd then
			for k,v in spairs(commands.GetCommands()) do
				logn(assert(commands.GetHelpText(k)))
			end
		else
			local help, err = commands.GetHelpText(cmd)
			if help then
				logn(help)
			else
				for _, sub_cmd in ipairs(commands.sub_commands) do
					if sub_cmd:startswith(cmd) then
						logn(assert(commands.GetHelpText(sub_cmd)))
					end
				end
			end
		end
	end)
end

return commands