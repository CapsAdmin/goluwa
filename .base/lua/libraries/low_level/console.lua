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
	ply = function(str)
		return easylua.FindEntity(str) or NULL
	end,
	name = function(ply)
		if ply and ply:IsValid() then
			return ply:GetNick()
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
arg_types["@"] = arg_types.ply
arg_types["#"] = arg_types.ply


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

	function console.AddCommand(cmd, callback, help)
		cmd = cmd:lower()
		
		console.AddedCommands[cmd] = {callback = callback, help = help}
	end

	function console.RemoveCommand(cmd, callback)
		cmd = cmd:lower()	
		
		console.AddedCommands[cmd] = nil
	end

	function console.GetCommands()
		return console.AddedCommands
	end
	
	function console.RunCommand(cmd, ...)
		local ok, reason = console.CallCommand(cmd, table.concat({...}, " "), ...)
		
		if not ok then
			logn("failed to execute command ", cmd, "!")
			logn(reason) 
			
			if console.AddedCommands[cmd].help then
				logn(console.AddedCommands[cmd].help)
			end
		end
	end

	local function call(data, line, ...)
		local a, b, c = xpcall(data, system.OnError, line, ...)

		if a and b ~= nil and c then
			return b, c
		end
		
		return a, b
	end

	function console.CallCommand(cmd, line, ...)
		cmd = cmd:lower()

		local data = console.AddedCommands[cmd]

		if data then
			return call(data.callback, line, ...)
		end
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
			
			local data = {args = parse_args(rest), line = rest, cmd = cmd, symbol = symbol}
			
			local ok, err = execute_args(data.args)
			if not ok then return nil, err end
			return data
		end
	end
	
	function console.RunString(line, skip_lua, skip_split)
		if not skip_split and line:find("\n") then
			for line in (line .. "\n"):gmatch("(.-)\n") do
				console.RunString(line)
			end
			return
		end
	
		local data, err = console.ParseCommandArgs(line)
		
		if data then						
			if console.AddedCommands[data.cmd] then
				return console.CallCommand(data.cmd, data.line, unpack(data.args))
			end
			
			if not skip_lua then
				--[==[
				local func = _G[cmd]
				
				if not func and cmd:find("%.") then
					local keys = cmd:explode(".")
					if _G[keys[1]] then
						
						local val = _G[keys[1]]
						
						for i = 2, #keys do
							if hasindex(val[keys[i]]) and val[keys[i]] then
								last = val[keys[i]]
							end
						end
						
						func = last
					end
				end
				
				if type(func) == "function" then
					
					for key, val in pairs(args) do
						local num = tonumber(args[key])
						
						if num then
							val = num
						elseif not _G[val] then
							local ok, var = pcall(loadstring(("return %s"):format(val)))
							
							if ok then
								val = var
							end
						end
						
						args[key] = val
					end
				
					return xpcall(func, system.OnError, select(2, unpack(args)))
				end]==]
				
				local func, err = loadstring(line)
				
				if not func then return func, err end
				
				return xpcall(func, system.OnError)
			end
		end 
	end
end

do -- console vars
	console.cvar_file_name = "%DATA%/cvars.txt"
	console.vars = nil
	
	-- what's the use?
	do -- cvar meta
		local META = utilities.CreateBaseMeta("cvar")
		
		function META:Get()
			if not console.vars then console.ReloadVariables() end
			
			return console.vars[self.cvar]
		end
		
		function META:Set(var)
			console.SetVariable(self.cvar, var)
		end
			
		console.cvar_meta = META
	end
	
	function console.ReloadVariables()
		console.vars = luadata.ReadFile(console.cvar_file_name)
	end
	
	function console.CreateVariable(name, def, callback)
		if not console.vars then console.ReloadVariables() end

		console.vars[name] = console.vars[name] or def

		local T = type(def)
		
		local func = function(line, value)
			if not value then	
				value = console.vars[name] or def
				
				if T == "string" then
					value = ("%q"):format(value)
				end
				
				logf("%s = %s\n", name, luadata.ToString(luadata.FromString(value)))
			else
					
				if T ~= "string" then
					value = luadata.FromString(value)
				end
			
				if type(value) ~= T then
					value = def
				end
			
				console.SetVariable(name, value)
				
				if callback then
					callback(value)
				end
				
				logf("%s = %s\n", name, value)
			end
			
		end

		console.AddCommand(name, func)
		
		return console.cvar_meta:New({cvar = name})
	end

	function console.GetVariable(var, def)
		if not console.vars then console.ReloadVariables() end
		
		return console.vars[var] or def
	end

	function console.SetVariable(name, value)
		if not console.vars then console.ReloadVariables() end
		
		console.vars[name] = value
		luadata.SetKeyValueInFile(console.cvar_file_name, name, value)
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
			logn(info.help)
		end
	end
end)

return console