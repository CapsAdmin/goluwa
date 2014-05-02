local console = _G.console or {}
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

	-- thanks lexi!
	-- http://www.facepunch.com/showthread.php?t=827179

	function console.ParseCommandArgs(line)
		local cmd, val = line:match("^(%S-)%s-=%s+(.+)$")
				
		if cmd and val then
			return {cmd:trim(), val:trim()}
		end
	
		local quote = line:sub(1,1) ~= '"'
		local ret = {}
		
		for chunk in string.gmatch(line, '[^"]+') do
			quote = not quote
			if quote then
				table.insert(ret,chunk)
			else
				for chunk in string.gmatch(chunk, "%S+") do -- changed %w to %S to allow all characters except space
					table.insert(ret, chunk)
				end
			end
		end

		return ret
	end
	
	function console.RunString(line, skip_lua, skip_split)
		if not skip_split and line:find("\n") then
			for line in (line .. "\n"):gmatch("(.-)\n") do
				console.RunString(line)
			end
			return
		end
	
		local args = console.ParseCommandArgs(line)
		
		local cmd = args[1]
		
		if cmd then			
			local ccmd = cmd:lower()
			
			if console.AddedCommands[ccmd] then
				local arg_line = line:sub(#args[1]+1):trim()
				return console.CallCommand(ccmd, arg_line, select(2, unpack(args)))
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
				
				logf("%s = %s", name, luadata.ToString(luadata.FromString(value)))
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
				
				logf("%s = %s", name, value)
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
			logf("\ttype %q to go to this function", "source " .. line)
			logn("\tdebug info:")
			logn("\t\targuments\t=\t", table.concat(debug.getparams(info.callback), ", "))
			logn("\t\tfunction\t=\t", tostring(info.callback))
		else
			logn(info.help)
		end
	end
end)

return console