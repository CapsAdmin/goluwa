local commands = _G.commands or {}

local ffi = require("ffi")

local start_symbols = {
	"%!",
	"%.",
	"%/",
	"",
}

local arg_types = {
	vec3 = Vec3,
	ang3 = Ang3,
	client = function(str)
		return NULL-- easylua.FindEntity(str) or NULL
	end,
	name = function(client)
		if client and client:IsValid() then
			return client:GetNick()
		end
	end,
}

if expression then
	arg_types.e = function(str)
		local _, res = assert(expression.Compile(str))
		return res()
	end
end

arg_types.v3 = arg_types.vec3
arg_types.a3 = arg_types.ang3
arg_types["@"] = arg_types.client
arg_types["#"] = arg_types.client


local capture_symbols = {
	["\""] = "\"",
	["'"] = "'",
	["("] = ")",
	["["] = "]",
	["`"] = "`",
	["´"] = "´",
}

commands.added = commands.added or {}

function commands.Add(cmd, callback, help, autocomplete)
	cmd = cmd:lower()

	commands.added[cmd] = {callback = callback, help = help, autocomplete = autocomplete}
end

function commands.AddAutocomplete(cmd, callback)
	cmd = cmd:lower()

	if commands.added[cmd] then
		commands.added[cmd].autocomplete = callback
	end
end

function commands.AddHelp(cmd, str)
	cmd = cmd:lower()

	if commands.added[cmd] then
		commands.added[cmd].help = str
	end
end

function commands.Remove(cmd)
	cmd = cmd:lower()

	commands.added[cmd] = nil
end

function commands.GetCommands()
	return commands.added
end

local function call(data, line, ...)
	local a, b, c = system.pcall(data, line, ...)

	if a and b ~= nil then
		return b, c
	end

	return a, b
end

local function call_command(cmd, line, ...)
	cmd = cmd:lower()

	local data = commands.added[cmd]

	if data then
		local ok, reason = call(data.callback, line, ...)
		 if not ok then
			logn("failed to execute command ", cmd, "!")
			logn(reason)

			local help = commands.added[cmd].help

			if help then
				if type(help) == "function" then
					help()
				else
					logn(help)
				end
			end
		end

		return ok, reason
	end
end

function commands.RunCommand(cmd, ...)
	return call_command(cmd, table.concat({...}, ","), ...)
end

do -- arg parsing
	local function parse_args(arg_line)
		if not arg_line or arg_line:trim() == "" then return {} end

		local chars = arg_line:utotable()

		local args = {}
		local capture = {}
		local escape  = false

		local in_capture = false

		for _, char in ipairs(chars) do
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
						table.insert(args, table.concat(capture, ""):trim())
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

		table.insert(args, table.concat(capture, ""):trim())

		for i, str in ipairs(args) do
			if tonumber(str) then
				args[i] = tonumber(str)
			else
				local cmd, rest = str:match("^(.+)%((.+)%)$")

				if not cmd then
					local t = str:sub(1,1):charclass()
					if t then
						cmd, rest = str:match("^("..t.."+)(.+)$")
					end
				end

				if cmd then
					cmd = cmd:trim():lower()
					if arg_types[cmd] then

						if capture_symbols[rest:sub(1,1)] then
							rest = rest:sub(2, -2)
						end

						args[i] = {cmd = cmd, args = parse_args(rest), line = str}
					end
				end
			end
		end

		return args
	end

	local function parse_line(line)
		for _, v in ipairs(start_symbols) do
			local start, rest = line:match("^(" .. v .. ")(.+)")
			if start then
				local cmd, rest_ = rest:match("^(%S+)%s+(.+)$")
				if not cmd then
					return v, rest:trim()
				else
					return v, cmd, rest_
				end
			end
		end
	end

	local function execute_args(args, udata)
		local errors = {}

		for i, arg in ipairs(args) do
			if type(arg) == "table" then

				local ok, res = execute_args(arg.args, udata)

				if not ok then
					table.insert(errors, res)
				end

				if arg_types[arg.cmd] then
					local ok, res = pcall(arg_types[arg.cmd], unpack(arg.args))

					if ok then
						args[i] = res
					else
						table.insert(errors, ("%q: %s"):format(arg.line, res))
					end
				end
			end
		end

		if #errors > 0 then
			return nil, table.concat(errors, "\n")
		end

		return true
	end

	function commands.IsCommandStringValid(line)
		local symbol = parse_line(line)
		return commands.added[cmd] ~= nil, symbol and symbol:sub(2,2)
	end

	function commands.ParseArguments(line)
		local symbol, cmd, rest = parse_line(line)

		local data = {args = parse_args(rest), line = rest or "", cmd = cmd, symbol = symbol}

		local ok, err = execute_args(data.args)
		if not ok then return nil, err end
		return data
	end
end

function commands.RunString(line, skip_lua, skip_split, log_error)
	if type(line) ~= "string" then return end

	if not skip_split and line:find("\n") then
		for line in (line .. "\n"):gmatch("(.-)\n") do
			commands.RunString(line, skip_lua, skip_split, log_error)
		end
		return
	end

	local data, err = commands.ParseArguments(line)

	if data then
		if commands.added[data.cmd] then
			return call_command(data.cmd, data.line, unpack(data.args))
		end

		if pvars.IsSetup(data.cmd) then
			local val = data.line

			if data.line ~= "" then
				if data.line == "nil" then
					val = nil
				else
					if pvars.GetObject(data.cmd):GetType() ~= "string" then
						val = serializer.GetLibrary("luadata").FromString(val)
					end
				end

				pvars.Set(data.cmd, val)
			end

			logn(data.cmd, " (",pvars.GetObject(data.cmd):GetType(),") = ", pvars.Get(data.cmd))

			return
		end

		if not skip_lua then
			return commands.RunLua(line, log_error)
		end
	end

	if log_error and err then
		logn(err)
	end
end

commands.run_lua_environment = {}

function commands.SetLuaEnvironmentVariable(key, var)
	commands.run_lua_environment[key] = var
end

function commands.RunLua(line, log_error, env_name)
	commands.SetLuaEnvironmentVariable("copy", window.SetClipboard)
	commands.SetLuaEnvironmentVariable("gl", desire("libopengl"))
	commands.SetLuaEnvironmentVariable("findo", prototype.FindObject)
	local lua = ""

	for k in pairs(commands.run_lua_environment) do
		lua = lua .. ("local %s = commands.run_lua_environment.%s;"):format(k, k)
	end

	lua = lua .. line

	local func, err = loadstring(lua, env_name or line)

	if log_error and not func then
		logn(err)
		return func, err
	end

	if not func then return func, err end

	local ret = {system.pcall(func)}

	if log_error and not ret[1] then
		if ret[2] then logn(ret[2]) end
		return unpack(ret)
	end

	return unpack(ret)
end

commands.Add("help", function(line)
	local info = commands.GetCommands()[line]
	if info then
		if not info.help then
			logn("\tno help was found for ", line)
			logf("\ttype %q to go to this function\n", "source " .. line)
			logn("\tdebug info:")
			logn("\t\targuments\t=\t", table.concat(debug.getparams(info.callback), ", "))
			logn("\t\tfunction\t=\t", tostring(info.callback))
		else
			if type(info.help) == "function" then
				info.help()
			else
				logn(info.help)
			end
		end
	end
end)

return commands