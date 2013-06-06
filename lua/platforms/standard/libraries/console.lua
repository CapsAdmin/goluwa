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
	console.Prefix = "o "
	
	console.AddedCommands = {}

	function console.AddCommand(cmd, callback, server)
		cmd = cmd:lower()
		
		if console.AddInternalConsoleCommand then
			console.AddInternalConsoleCommand(cmd)
		end
		
		console.AddedCommands[cmd] = {callback = callback, server = server}
	end

	function console.RemoveCommand(cmd, callback)
		cmd = cmd:lower()
		
		if console.RemoveInternalConsoleCommand and console.AddedCommands[cmd] then
			console.RemoveInternalConsoleCommand(cmd)
		end
		
		console.AddedCommands[cmd] = nil
	end

	function console.GetCommands()
		return console.AddedCommands
	end
	
	function console.RunCommand(cmd, ...)
		console.CallCommand(cmd, table.concat({...}, " "), nil, ...)
	end

	local function call(data, client, line, ...)
		return xpcall(data.callback, OnError, client, line, ...)
	end

	function console.CallCommand(cmd, line, client, ...)
		cmd = cmd:lower()

		local data = console.AddedCommands[cmd]

		if data then
			client = client or NULL
			
			if CLIENT then
				if data.server == true or data.server == "server" then
					message.Send("cmd", cmd, ...)
				elseif data.server == "shared" then
					message.Send("cmd", cmd, ...)
					return call(data, client, line, ...)
				elseif not data.server or data.server == "client" then
					return call(data, client, line, ...)
				end
			end

			if SERVER then
				return call(data, client, line, ...)
			end
		end
	end

	-- thanks lexi!
	-- http://www.facepunch.com/showthread.php?t=827179

	function console.ParseCommandArgs(line)
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

	function console.CallCommandLine(line)
		local cmd = line:match("(.-) ") or line:match("(.+)") or ""
		local arg_line = line:match(".- (.+)") or ""		

		cmd = cmd:lower()
				
		if not console.AddedCommands[cmd] then
			cmd, arg_line = line:match("(.-)%s-(.+)")
			
			if not cmd or cmd == "" then
				cmd = arg_line or ""
				arg_line = ""
			end
			
			cmd = cmd:lower()
		end

		if console.AddedCommands[cmd] then
			return console.CallCommand(cmd, arg_line, nil, unpack(console.ParseCommandArgs(arg_line)))
		end
		
		return false, string.format("unknown command %q", cmd)
	end
end

do -- console vars
	console.cvar_file_name = "cvars.txt"
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
		if not console.vars then
			console.ReloadVariables()
		end

		console.vars[name] = console.vars[name] or def

		local func = function(client, line, value)
			if not value then
				logf("%s = %s", name, luadata.ToString(console.vars[name]))
			else
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
		return console.vars[var] or def
	end

	function console.SetVariable(name, value)
		console.vars[name] = value
		luadata.SetKeyValueInFile(console.cvar_file_name, name, value)
	end
	
	event.AddListener("MenuInitialized", "cvars", function()
		console.ReloadVariables()
	end, 10)
end

do -- filtering

	local blacklist = {}

	function console.AddToBlackList(str)
		check(str, "string")

		return table.insert(blacklist, str)
	end

	function console.RemoveFromBlackList(id)
		check(id, "number")

		blacklist[id] = nil
	end

	function console.GetBlackList()
		return blacklist
	end

	function console.ClearBlackList()
		blacklist = {}
	end
	
	console.CreateVariable("con_filter", "normal")

	function console.IsLineAllowed(line)
		local mode = console.GetVariable("con_filter")
		
		if mode == "normal" then
			for _, value in pairs(blacklist) do
				if line:findsimple(value) then
					return false
				end
			end
		elseif mode == "pattern" then
			for _, value in pairs(blacklist) do
				if line:find(value) then
					return false
				end
			end
		end

		return true
	end

	console.SuppressPrint = false
	event.AddListener("ConsolePrint", "console_filter", function(line)
		--if console.SuppressPrint then return end 
	--	console.SuppressPrint = true
		if not console.IsLineAllowed(line) then
	--		console.SuppressPrint = false
			return false
		else
			event.Call("ConsoleOutput", line)
		end
	--	console.SuppressPrint = false
	end)

end

do -- funsong
	cmd = setmetatable(
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

local cvar = console.CreateVariable("con_filter", "string", "normal")

function console.IsLineAllowed(line)
	if console.GetVariableString("con_filter") == "normal" then
		for _, value in pairs(blacklist) do
			if line:findsimple(value) then
				return false
			end
		end
	elseif console.GetVariableString("con_filter") == "pattern" then
		for _, value in pairs(blacklist) do
			if line:find(value) then
				return false
			end
		end
	end

	return true
end


event.AddListener("ConsolePrint", "console_filter", function(_, line)
	if not console.IsLineAllowed(line) then
		return false
	else
		event.Call("ConsoleOutput", GAMEMODE, line)
	end
end)

return console