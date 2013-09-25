local console = {}
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
	console.AddedCommands = {}

	function console.AddCommand(cmd, callback)
		cmd = cmd:lower()
		
		console.AddedCommands[cmd] = callback
	end

	function console.RemoveCommand(cmd, callback)
		cmd = cmd:lower()	
		
		console.AddedCommands[cmd] = nil
	end

	function console.GetCommands()
		return console.AddedCommands
	end
	
	function console.RunCommand(cmd, ...)
		console.CallCommand(cmd, table.concat({...}, " "), ...)
	end

	local function call(data, line, ...)
		return xpcall(data, mmyy.OnError, line, ...)
	end

	function console.CallCommand(cmd, line, ...)
		cmd = cmd:lower()

		local data = console.AddedCommands[cmd]

		if data then
			return call(data, line, ...)
		end
	end

	-- thanks lexi!
	-- http://www.facepunch.com/showthread.php?t=827179

	function console.ParseCommandArgs(line)
		local cmd, val = line:match("(.-)=(.+)")
		
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
	
	function console.RunString(line, skip_lua)
		if line:find("\n") then
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
				
					return xpcall(func, mmyy.OnError, select(2, unpack(args)))
				end
				
				local func, err = loadstring(line)
				
				if not func then return func, err end
				
				return xpcall(func, mmyy.OnError)
			end
		end
	end
end

do -- console vars
	console.cvar_file_name = "%DATA%/cvars.txt"
	console.vars = nil
	
	-- what's the use?
	do -- cvar meta
		local META = {}
		META.__index = META
		
		function META:Get()
			return console.vars[self.cvar]
		end
		
		function META:Set(var)
			console.SetVariable(self.cvar, var)
		end
			
		console.CVarMeta = META
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
				logf("%s = %s", name, luadata.ToString(luadata.FromString(console.vars[name] or def)))
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
			end

		end

		console.AddCommand(name, func)
		
		return setmetatable({cvar = name}, console.CVarMeta)
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

return console