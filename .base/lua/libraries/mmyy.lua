local mmyy = _G.mmyy or {}

-- this should be used for xpcall
local suppress = false
local last_openfunc = 0
function mmyy.OnError(msg, ...)
	msg = msg or "no error"
	if suppress then logn("supressed error: ", msg, ...) return end
	suppress = true
	if LINUX and msg == "interrupted!\n" then return end
	
	if event.Call("OnLuaError", msg) == false then return end
	
	if msg:find("stack overflow") then
		logn(msg)
		table.print(debug.getinfo(3))
		return
	end
	
	logn("STACK TRACE:")
	logn("{")
	
	local base_folder = e.ROOT_FOLDER:gsub("%p", "%%%1")
	local data = {}
		
	for level = 3, 100 do
		local info = debug.getinfo(level)
		if info then
			if info.currentline >= 0 then			
				local args = {}
				
				for arg = 1, info.nparams do
					local key, val = debug.getlocal(level, arg)
					if type(val) == "table" then
						val = tostring(val)
					else
						val = luadata.ToString(val)
						if val and #val > 200 then
							val = val:sub(0, 200) .. "...."
						end
					end
					table.insert(args, ("%s = %s"):format(key, val))
				end
				
				info.arg_line = table.concat(args, ", ")
				
				local source = info.short_src or ""
				source = source:gsub(base_folder, ""):trim()
				info.source = source
				info.name = info.name or "unknown"
				
				table.insert(data, info)
			end
		else
			break
		end
    end
	
	local function resize_field(tbl, field)
		local length = 0
		
		for _, info in pairs(tbl) do
			local str = tostring(info[field])
			if str then
				if #str > length then
					length = #str
				end
				info[field] = str
			end
		end
		
		for _, info in pairs(tbl) do
			local str = info[field]
			if str then				
				local diff = length - #str
				
				if diff > 0 then
					info[field] = str .. (" "):rep(diff)
				end
			end
		end
	end
	
	table.insert(data, {currentline = "LINE:", source = "SOURCE:", name = "FUNCTION:", arg_line = " ARGUMENTS "})
	
	resize_field(data, "currentline")
	resize_field(data, "source")
	resize_field(data, "name")
	
	for _, info in npairs(data) do
		logf("  %s   %s   %s(%s)", info.currentline, info.source, info.name, info.arg_line)
	end

	logn("}")
	local source, _msg = msg:match("(.+): (.+)")
	
	
	if source then
		source = source:trim()
		
		-- this should be replaced with some sort of configuration
		-- gl.lua never shows anything useful but the level above does..			
		if source:find("ffi_bind") then
			func = debug.getinfo(4).func
		else
			func = debug.getinfo(2).func
		end
			
		if last_openfunc < os.clock() then
			debug.openfunction(func)
			last_openfunc = os.clock() + 3
		else
			logf("supressed os.execute(%q)", path)
		end
		
		logn(source)
		logn(_msg:trim())
	else
		logn(msg)
	end
	
	logn("")
	
	suppress = false
end

if mmyy.lua_environment_sockets then
	for key, val in pairs(mmyy.lua_environment_sockets) do
		utilities.SafeRemove(val)
	end
end

mmyy.lua_environment_sockets = {}

function mmyy.CreateLuaEnvironment(title, globals, id)	
	check(globals, "table", "nil")
	id = id or title
	
	local socket = mmyy.lua_environment_sockets[id] or NULL
	
	if socket:IsValid() then 
		socket:Send("exit")
		socket:Remove()
	end
	
	local socket = luasocket.Server()
	socket:Host("*", 0)
					
	mmyy.lua_environment_sockets[id] = socket
	
	local arg = ""
		
	globals = globals or {}
	
	globals.PLATFORM = _G.PLATFORM or globals.PLATFORM
	globals.PORT = socket:GetPort()
	globals.CREATED_ENV = true
	globals.TITLE = tostring(title)

	for key, val in pairs(globals) do
		arg = arg .. key .. "=" .. luadata.ToString(val) .. ";"
	end	
	
	arg = arg:gsub([["]], [[']])	
	arg = ([[-e %sloadfile('%sinit.lua')()]]):format(arg, e.ROOT_FOLDER .. "lua/")
		
	if WINDOWS then
		os.execute([[start "" "luajit" "]] .. arg .. [["]])
	elseif LINUX then
		os.execute([[luajit "]] .. arg .. [[" &]])
	end
	
	local env = {}
	
	function env:OnReceive(line)
		local func, msg = loadstring(line)
		if func then
			local ok, msg = xpcall(func, mmyy.OnError) 
			if not ok then
				logn("runtime error:", client, msg)
			end
		else
			logn("compile error:", client, msg)
		end
	end
	
	local queue = {}
		
	function env:Send(line)
		if not socket:HasClients() then
			table.insert(queue, line)
		else
			socket:Broadcast(line, true)
		end
	end
	
	function env:Remove()
		self:Send("os.exit()")
		socket:Remove()
	end
	
	socket.OnClientConnected = function(self, client)	
		for k,v in pairs(queue) do
			socket:Broadcast(v, true)
		end
		
		queue = {}
		
		return true 
	end
		
	socket.OnReceive = function(self, line)
		env:OnReceive(line)
	end
		
	env.socket = socket
	
	return env
end

function mmyy.CreateConsole(title)
	if CONSOLE then return logn("tried to create a console in a console!!!") end
	local env = mmyy.CreateLuaEnvironment(title, {CONSOLE = true})
	
	env:Send([[
		local __stop__
		
		local function clear() 
			logn(("\n"):rep(1000)) -- lol
		end
				
		local function exit()
			__stop__ = true
			os.exit()
		end
		
		clear()
		
		ENV_SOCKET.OnClose = function() exit() end

		event.AddListener("OnConsoleEnvReceive", TITLE, function()
			::again::
			
			local str = io.read()
			
			if str == "exit" then
				exit()
			elseif str == "clear" then
				clear()
			end

			if str and #str:trim() > 0 then
				ENV_SOCKET:Send(str, true)
			else
				goto again
			end
		end)
		
		event.AddListener("ShutDown", TITLE, function()
			ENV_SOCKET:Remove()
		end)
	]])	
		
	event.AddListener("OnPrint", title .. "_console_output", function(...)
		local line = tostring_args(...)
		env:Send(string.format("logn(%q)", line))
	end)
	
		
	function env:Remove()
		self:Send("os.exit()")
		utilities.SafeRemove(self.socket)
		event.RemoveListener("OnPrint", title .. "_console_output")
	end
	
	
	return env
end

return mmyy
