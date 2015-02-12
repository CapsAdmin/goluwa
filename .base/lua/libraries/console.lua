local console = _G.console or {}

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
		local ok, res = assert(expression.Compile(str))
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

local function allowed(udata, arg)
	return true
end

local SERVER = true

local result = ""

function console.StartCapture()
	result = ""

	log = function(str)
		result = result .. str
	end

	logn = function(str)
		result = result .. str .. "\n"
	end

end

function console.EndCapture()
	log = _OLD_G.log
	logn = _OLD_G.logn
	return result
end

function console.Capture(func, ...)
	console.StartCapture()
		func(...)
	return console.EndCapture()
end

function console.Exec(cfg)
	check(cfg, "string")

	local content = vfs.Read("cfg/"  .. cfg .. ".cfg")

	if content then
		console.RunString(content)
		return true
	end

	return false
end

do -- commands	
	console.AddedCommands = console.AddedCommands or {}

	function console.AddCommand(cmd, callback, help, autocomplete)
		cmd = cmd:lower()
		
		console.AddedCommands[cmd] = {callback = callback, help = help, autocomplete = autocomplete}
	end

	function console.RemoveCommand(cmd, callback)
		cmd = cmd:lower()	
		
		console.AddedCommands[cmd] = nil
	end

	function console.GetCommands()
		return console.AddedCommands
	end
	
	local function call(data, line, ...)
		local a, b, c = xpcall(data, system.OnError, line, ...)

		if a and b ~= nil then
			return b, c
		end
		
		return a, b
	end

	local function call_command(cmd, line, ...)
		cmd = cmd:lower()

		local data = console.AddedCommands[cmd]

		if data then
			local ok, reason = call(data.callback, line, ...)
			 if not ok then
				logn("failed to execute command ", cmd, "!")
				logn(reason) 
				
				local help = console.AddedCommands[cmd].help
				
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
	
	function console.RunCommand(cmd, ...)
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
			
			for i, char in ipairs(chars) do	
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
			for k,v in ipairs(start_symbols) do
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
					
					if arg_types[arg.cmd] and allowed(udata, arg) then
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
		
		function console.IsValidCommand(line)
			local symbol, cmd, rest = parse_line(line)
			return console.AddedCommands[cmd] ~= nil, symbol and symbol:sub(2,2)
		end
		
		function console.ParseCommandArgs(line)
			local symbol, cmd, rest = parse_line(line)
			
			local data = {args = parse_args(rest), line = rest or "", cmd = cmd, symbol = symbol}
			
			local ok, err = execute_args(data.args)
			if not ok then return nil, err end
			return data
		end
	end
	
	function console.RunString(line, skip_lua, skip_split, log_error)
		if not skip_split and line:find("\n") then
			for line in (line .. "\n"):gmatch("(.-)\n") do
				console.RunString(line, skip_lua, skip_split, log_error)
			end
			return
		end
		
		local data, err = console.ParseCommandArgs(line)

		if data then						
			if console.AddedCommands[data.cmd] then
				return call_command(data.cmd, data.line, unpack(data.args))
			end
			
			if not skip_lua then
				return console.RunLua(line, log_error)
			end
		end 
		
		if log_error and err then
			logn(err)
		end
	end
	
	console.run_lua_environment = {
		copy = system.SetClipboard,
		gl = requirew("lj-opengl"),
	}
	
	function console.SetLuaEnvironmentVariable(key, var)
		console.run_lua_environment[key] = var
	end
	
	function console.RunLua(line, log_error, env_name)
		local lua = ""
		
		for k, v in pairs(console.run_lua_environment) do
			lua = lua .. ("local %s = console.run_lua_environment.%s;"):format(k, k)
		end
		
		lua = lua .. line

		local func, err = loadstring(lua, env_name or line)

		if log_error and not func then 
			logn(err)
			return func, err
		end
		
		if not func then return func, err end
		
		local ret = {xpcall(func, system.OnError)}
		
		if log_error and not ret[1] then
			if ret[2] then logn(ret[2]) end
			return unpack(ret)
		end
		
		return unpack(ret)
	end
end

do -- console vars
	console.cvar_file_name = "%DATA%/cvars.txt"
 	
	-- what's the use?
	do -- cvar meta
		local META = prototype.CreateTemplate("cvar")
		
		function META:Get()
			if not console.vars then 
				console.ReloadVariables() 
			end
			
			return console.vars[self.name]
		end
		
		function META:Set(var)
			console.SetVariable(self.name, var)
		end
		
		prototype.Register(META)
	end
	
	function console.ReloadVariables()
		console.vars = serializer.ReadFile("luadata", console.cvar_file_name) or {}
	end
	
	local luadata = serializer.GetLibrary("luadata")
	
	function console.CreateVariable(name, def, callback, help)
		if not console.vars then console.ReloadVariables() end

		if console.vars[name] == nil then 
			console.vars[name] = def
		end

		local T = type(def)
		
		local func = function(line, value)
			if value == nil then	
				if console.vars[name] ~= nil then	
					value = console.vars[name]
				end
				
				if value == nil then
					value = def
				end
				
				if T == "string" then
					value = ("%q"):format(value)
				end
				
				logf("%s == %s\n", name, luadata.ToString(value))
				logn("default == ", luadata.ToString(def))
				local help = console.GetCommands()[name].help
				if help then
					if type(help) == "function" then
						help()
					else
						logn(help)
					end
				end
			else
				if T ~= "string" then
					value = luadata.FromString(value)
				end
							
				if value == nil then
					value = def
				end
			
				console.SetVariable(name, value)
				
				if type(callback) == "function" then
					callback(value)
				end
				
				logf("%s = %s (%s)\n", name, value, typex(value))
			end
			
		end

		if type(callback) == "string" then 
			help = callback 
		end
		
		console.AddCommand(name, func, help)
		
		if type(callback) == "function" then
			event.Delay(function() 
				callback(console.GetVariable(name))
			end)
		end
		
		return prototype.CreateObject("cvar", {name = name})
	end
	
	function console.IsVariableAdded(var)
		return console.AddedCommands and console.AddedCommands[var] ~= nil
	end

	function console.GetVariable(var, def)
		if not console.vars then console.ReloadVariables() end
		
		if console.vars[var] == nil then
			return def
		end
		
		return console.vars[var]
	end

	function console.SetVariable(name, value)
		if not console.vars then console.ReloadVariables() end
		
		console.vars[name] = value
		serializer.SetKeyValueInFile("luadata", console.cvar_file_name, name, value)
	end
end


do -- title
	if not console.SetTitleRaw then
		local set_title
		if WINDOWS then
			ffi.cdef("int SetConsoleTitleA(const char* blah);")

			set_title = function(str)
				return ffi.C.SetConsoleTitleA(str)
			end
		end

		if LINUX then
			local iowrite = _OLD_G.io.write
			set_title = function(str)
				return iowrite and iowrite('\27]0;', str, '\7') or nil
			end
		end
		
		console.SetTitleRaw = set_title
	end
	
	local titles = {}
	local str = ""
	local last = 0
	local last_title
	
	local lasttbl = {}
	
	function console.SetTitle(title, id)
		local time = os.clock()
		
		if not lasttbl[id] or lasttbl[id] < time then
			if id then
				titles[id] = title
				str = "| "
				for k,v in pairs(titles) do
					str = str ..  v .. " | "
				end
				if str ~= last_title then
					console.SetTitleRaw(str)
				end
			else
				str = title
				if str ~= last_title then
					console.SetTitleRaw(title)
				end
			end
			last_title = str
			lasttbl[id] = os.clock() + 0.05
		end
	end
	
	function console.GetTitle()
		return str
	end
end

do -- for fun
	console.cmd = setmetatable(
		{}, 
		{
			__index = function(self, key)				
				key = key:lower()
				
				-- lua commands
				if console.AddedCommands[key] then
					return function(...)
						console.RunCommand(key, ...)
					end
				end
				
				-- lua cvars
				local tbl = console.vars
				
				if not console.vars then
					console.ReloadVariables()
				end
				
				if tbl[key] then
					return tbl[key]
				end
			end,
			
			__newindex = function(self, key, val)
				key = key:lower()
			
				console.RunString(key .. " " .. val, true)
			end
		}
	)
end

console.AddCommand("help", function(line)
	local info = console.GetCommands()[line]
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

return console