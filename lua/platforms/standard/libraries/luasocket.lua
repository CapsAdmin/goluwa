--[[

Most of these functions can be called at any time. Send queues what you send until a connection is made.

Only "tcp" and "udp" is supported. Default is tcp. There isn't much of a difference between udp and tcp in this wrapper so you can easily change between the two modes.

By default the socket has a 3 second timeout. The timeout count is started/restarted whenever the mesage is "timeout" and stopped otherwise

luasocket.debug = true
	will logn debug messages about sending and receiving data
	very useful for (duh) debugging!

-- client

	CLIENT = luasocket.Client("udp" or "tcp") -- this defaults to tcp

	CLIENT:GetTimeoutDuration()

	CLIENT:IsTimingOut()
	CLIENT:IsSending()
	CLIENT:IsConnected()

	CLIENT:SetTimeout(seconds or nil)
	CLIENT:GetTimeout()

	CLIENT:SetReceiveMode("line" or "all" or bytes)
	CLIENT:GetReceiveMode()
	
	CLIENT:OnReceive(str)

	-- return false to prevent the socket from being removed
	-- if the timeout duration has exceeded the max timeout duration

	CLIENT:OnTimeout(count)

	CLIENT:OnSend(str, bytes)
	CLIENT:OnError(msg)
	CLIENT:OnClose()

	CLIENT:Connect(ip, port)
--

-- server
	SERVER = luasocket.Server("udp" or "tcp") -- this defaults to tcp

	SERVER:Host(ip, port)

	-- returning false here will close and remove the client
	-- returning true will call SetKeepAlive true on the client
	SERVER:OnClientConnected(client, ip, port)


	SERVER:OnReceive(str, client)
	SERVER:OnClientClosed(client)
	SERVER:OnClientError(client, msg)

	SERVER:GetClients()
	SERVER:HasClients() -- returns true if someone is connected, false otherwise
--

-- shared
	SHARED:Send(str, instant)
	SHARED:GetIP()
	SHARED:GetPort()

	SHARED:IsValid()
	SHARED:Remove()

	-- These have Get ones as well but they only return something if Set was called. This uses setoption.
	SHARED:SetReuseAddress(val)
	SHARED:SetNoDelay(val)
	SHARED:SetLinger(val)
	SHARED:SetKeepAlive(val)
--
]]

local luasocket = {}

if _G.luasocket and _G.luasocket.Panic then
	_G.luasocket.Panic()
end

-- external functions
local on_error = mmyy and mmyy.OnError or error
local logn = logn or MsgN or print
local table_print = PrintTable or table.print or logn
local warning = ErrorNoHalt or logn
local check = check or function() end
local cares = pcall(require,"cares") or _G.cares

function luasocket.Initialized()
	if gmod then
		_G.luasocket = luasocket

		hook.Add("Think", "socket_think", function()
			luasocket.Update()
		end)
	end
end

luasocket.socket = require("socket") or _G.socket

function luasocket.DebugPrint(...)
	if luasocket.debug then
		local tbl = {}

		for i = 1, select("#", ...) do
			tbl[i] = tostring(select(i, ...))
		end

		logn(string.format(unpack(tbl)))
	end
end

do -- helpers/usage

	function luasocket.HeaderToTable(header)
		local tbl = {}
		
		if not header then return tbl end

		for line in header:gmatch("(.-)\n") do
			local key, value = line:match("(.+):%s+(.+)\13")

			if key and value then
				tbl[key] = value
			end
		end

		return tbl
	end

	function luasocket.TableToHeader(tbl)
		local str = ""

		for key, value in pairs(tbl) do
			str = str .. tostring(key) .. ": " .. tostring(value) .. "\r\n"
		end

		return str
	end

	local function request(url, callback, method, timeout, post_data, user_agent, binary)		
		url = url:gsub("http://", "")
		callback = callback or table_print
		method = method or "GET"
		user_agent = user_agent or "goluwa"

		local host, location = url:match("(.-)/(.+)")

		if not location then
			host = url:gsub("/", "")
			location = ""
		end
		
		local socket = luasocket.Client("tcp")
		socket:SetTimeout(timeout or 0.5)
		socket:Connect(host, 80)

		socket:Send(("%s /%s HTTP/1.1\r\n"):format(method, location))
		socket:Send(("Host: %s\r\n"):format(host))
		socket:Send(("User-Agent: %s\r\n"):format(user_agent))
		socket:Send("Connection: Keep-Alive\r\n")
					
		if binary then
			socket:SetReceiveMode("all")
		end		
		
		if method == "POST" then
			socket:Send(("Content-Length: %i"):format(#post_data))
			socket:Send(post_data)
		end

		socket:Send("\r\n")

		local chunks = {}
		
		function socket:OnReceive(str)
			table.insert(chunks, str)
		end
		
		function socket:OnClose()
			local str = table.concat(chunks, "")
			local content
			local header
				
			header, content = str:match("(.-\10\13)(.+)")
			header = luasocket.HeaderToTable(header)
			
			if header["Content-Length"] then
				content = str:sub(-header["Content-Length"])
			end
			
			local ok, err = xpcall(callback, on_error, {content = content, header = header})
				
			if err then
				warning(err)
			end
		end
	end
	
	function luasocket.Get(url, callback, timeout, user_agent, binary)
		check(url, "string")
		check(callback, "function", "nil", "false")
		check(user_agent, "nil", "string")
		
		return request(url, callback, "GET", timeout, nil, user_agent, binary)
	end
	
	function luasocket.Post(url, post_data, callback, timeout, user_agent, binary)
		check(url, "string")
		check(callback, "function", "nil", "false")
		check(post_data, "table", "string")
		check(user_agent, "nil", "string")
		
		if type(post_data) == "table" then
			post_data = luasocket.TableToHeader(post_data)
		end
		
		return request(url, callback, "POST", timeout, post_data, user_agent, binary)
	end
	
	function luasocket.WebResource(url, callback)
		if url:sub(0, 4) == "http" then
			if callback then
				luasocket.Get(url, function(data) callback(data.content) end, nil, nil, true)
			else
				return {Download = function(_, callback) luasocket.Get(url, function(data) callback(data.content) end, nil, nil, true) end}
			end
		end
		
		return false
	end

	local sck = luasocket.socket.udp()
	function luasocket.SendUDPData(ip, port, str)

		if not str and type(port) == "string" then
			str = port
			port = tonumber(ip:match(".-:(.+)"))
		end

		local ok, msg = sck:sendto(str, ip, port)

		if ok then
			luasocket.DebugPrint("SendUDPData sent data to %s:%i (%s)", ip, port, str)
		else
			luasocket.DebugPrint("SendUDPData failed %q", msg)
		end

		return ok, msg
	end
end

local receive_types = {all = "*a", line = "*l"}

do -- tcp socket meta
	local NULL = {}

	NULL.IsNull = true

	local function FALSE()
		return false
	end

	function NULL:__tostring()
		return "NULL"
	end

	function NULL:__index(key)
		if key == "ClassName" then
			return "NULL"
		end

		if key == "Type" then
			return "null"
		end

		if key == "IsValid" then
			return FALSE
		end

		if type(key) == "string" and key:sub(0, 2) == "Is" then
			return FALSE
		end

		error(("tried to index %q on a NULL socket"):format(key), 2)
	end

	local sockets = {}

	function luasocket.GetSockets()
		return sockets
	end

	function luasocket.Panic()
		for key, sock in pairs(sockets) do
			if sock:IsValid() then
				sock:DebugPrintf("removed from luasocket.Panic()")
				sock:Remove()
			else
				table.remove(sockets, key)
			end
		end
	end

	function luasocket.Update()
		for key, sock in pairs(sockets) do
			if sock:IsValid() then
				local ok, err = xpcall(sock.Think, mmyy.OnError, sock)
				if not ok then
					warning(err)
					sock:Remove()
				end
			else
				sockets[key] = nil
			end

			if sock.remove_me then
				sock.socket:close()
				setmetatable(sock, NULL)
			end
		end
	end

	local function assert(res, err)
		if not res then
			error(res, 3)
		end
		return res
	end

	local function new_socket(override, META, typ)
		typ = typ or "tcp"
		typ = typ:lower()

		if typ == "udp" or typ == "tcp" then
			local self = {}

			self.socket = override or assert(luasocket.socket[typ]())
			self.socket:settimeout(0)
			self.socket_type = typ

			local obj = setmetatable(self, META)
			obj:Initialize()
			table.insert(sockets, obj)

			obj:DebugPrintf("created")

			return obj
		end
	end

	local function remove_socket(self)
		self.remove_me = true
	end

	local options =
	{
		KeepAlive = "keepalive",
		Linger = "linger",
		ReuseAddress = "ReuseAddr",
		NoDelay = "tcp-nodelay",
	}

	local function add_options(tbl)
		for func_name, key in pairs(options) do
			tbl["Set" .. func_name] = function(self, val)
				self.socket:setoption(key, val)
				self:DebugPrintf("option[%q] = %s", key, val)
				self[func_name] = val
			end

			tbl["Get" .. func_name] = function(self, val)
				return self[func_name]
			end
		end
	end

	do -- client
		local CLIENT = {}
		CLIENT.__index = CLIENT
		
		CLIENT.Type = "socket"
		CLIENT.ClassName = "client"

		add_options(CLIENT)

		function CLIENT:Initialize()
			self.Buffer = {}
			self:SetTimeout(3)
		end

		function CLIENT:__tostring()
			return string.format("client_%s[%s][%s]", self.socket_type, self:GetIP() or "none", self:GetPort() or "0")
		end

		function CLIENT:DebugPrintf(fmt, ...)
			luasocket.DebugPrint("%s - " .. fmt, self, ...)
		end

		function CLIENT:Connect(ip, port, skip_cares)
			check(ip, "string")
			check(port, "number")

			if not skip_cares and cares and cares.Resolve then
				self:DebugPrintf("using cares to resolve domain %s", ip)
				
				cares.Resolve(ip, function(_, errored, newip)
					if not errored then
						self:DebugPrintf("cares resolved domain from %s:%s", ip, newip)
						self:Connect(newip, port, true)
					else	
						self:DebugPrintf("cares errored resolving domain %s with code %s", ip, errored)
						self:Connect(ip, port, true)
					end
				end)
				return
			end
			
			self:DebugPrintf("connecting to %s:%s", ip, port)

			local ok, msg
			
			if self.socket_type == "tcp" then
				ok, msg = self.socket:connect(ip, port)
			else
				ok, msg = self.socket:setpeername(ip, port)
			end
						
			if not ok and msg and msg ~= "timeout" then
				self:DebugPrintf("connect failed: %s", msg)
				self:OnError(msg)
			else
				self.connecting = true
			end
		end

		function CLIENT:Send(str, instant)
			if self.socket_type == "tcp" then
				if instant then
					local bytes, b, c, d = self.socket:send(str)

					if bytes then
						self:DebugPrintf("sucessfully sent %q", str)

						self:OnSend(str, bytes, b,c,d)
					end
				else
					table.insert(self.Buffer, str)
				end
			else
				self.socket:send(str)
				self:DebugPrintf("sent %q", str)
			end
		end

		CLIENT.ReceiveMode = "all"

		function CLIENT:SetReceiveMode(type)
			self.ReceiveMode = type
		end

		function CLIENT:GetReceiveMode()
			return self.ReceiveMode
		end

		function CLIENT:Think()
			local sock = self.socket
			sock:settimeout(0)

			-- check connection
			if self.connecting then
				local res, msg = sock:getpeername()
				
				if res then
					self:DebugPrintf("connected to %s:%s", res, msg)

					-- ip, port = res, msg

					self.connected = true
					self.connecting = nil
					self:OnConnect(res, msg)

					self:Timeout(false)
				elseif msg == "timeout" or msg == "getpeername failed" then
					self:Timeout(true)
				else
					self:DebugPrintf("errored: %s", msg)
					self:OnError(msg)
				end
			end
			
			if self.connected then			
				-- try send
								
				if self.socket_type == "tcp" then
					for i = 1, 128 do
						local data = self.Buffer[1]
						if data then
							local bytes, b, c, d = sock:send(data)

							if bytes then
								self:DebugPrintf("sucessfully sent %q", data)

								self:OnSend(data, bytes, b,c,d)
								table.remove(self.Buffer, 1)
							elseif b ~= "Socket is not connected" then
								self:DebugPrintf("could not send %s : %s", data, b)
								break
							end
						else
							break
						end
					end
				end
				
				-- try receive
				local mode

				if self.socket_type == "udp" then
					mode = 1024
				else
					mode = receive_types[self.ReceiveMode] or self.ReceiveMode
				end

				local data, err, partial = sock:receive(mode)

				if not data and partial and partial ~= "" then
					data = partial
				end
				
				if data then
					if data:find("\n") then
						self:DebugPrintf("received (mode %s) %i bytes of data", mode, #data)
					else
						self:DebugPrintf("received (mode %s) %i bytes of data (%q)", mode, #data, data)
					end

					self:OnReceive(data)
					self:Timeout(false)

					if self.__server then
						self.__server:OnReceive(data, self)
					end

				elseif err == "timeout" or "Socket is not connected" then
					self:Timeout(true)
				elseif err == "closed" then
					self:DebugPrintf("closed")

					if not self.__server or self.__server:OnClientClosed(self) ~= false then
						self:Remove()
					end
				else
					self:DebugPrintf("errored: %s", err)
					
					if self.__server then
						self.__server:OnClientError(self3, err)
					end

					self:OnError(err)
				end
			end
		end

		do -- timeout
			function CLIENT:Timeout(bool)
				if not self.TimeoutLength then return end

				if not bool then
					self.TimeoutStart = nil
					return
				end

				local time = os.clock()

				if not self.TimeoutStart then
					self.TimeoutStart = time + self.TimeoutLength
				end

				local seconds = time - self.TimeoutStart

				if self:OnTimeout(seconds) ~= false then
					if seconds > self.TimeoutLength then
						self:DebugPrintf("timed out")
						self:Remove()
					end
				end
			end

			function CLIENT:GetTimeoutDuration()
				if not self.TimeoutStart then return 0 end

				local t = os.clock()
				return t - self.TimeoutStart
			end

			function CLIENT:IsTimingOut()
				return
			end

			function CLIENT:SetTimeout(seconds)
				self.TimeoutLength = seconds
			end

			function CLIENT:GetTimeout()
				return self.TimeoutLength or math.huge
			end
		end

		function CLIENT:Remove()
			if self.remove_me then return end
			
			self:DebugPrintf("removed")
			self:OnClose()
			
			remove_socket(self)
			
			if self.__server then
				for k, v in pairs(self.__server.Clients) do
					if v == self then
						table.remove(self.__server.Clients, k)
						break
					end
				end
			
				self.__server:OnClientClosed(self) 
			end
		end

		function CLIENT:IsConnected()
			return self.connected == true
		end

		function CLIENT:IsSending()
			return #self.Buffer > 0
		end

		function CLIENT:GetIP()
			if not self.connected then return "nil" end
			local ip, port 
			
			if self.__server then 
				ip, port = self.socket:getpeername()
			else
				ip, port = self.socket:getsockname()
			end
			
			return ip
		end

		function CLIENT:GetPort()
			if not self.connected then return "nil" end
			local ip, port 
			
			if self.__server then 
				ip, port = self.socket:getpeername()
			else
				ip, port = self.socket:getsockname()
			end
			return ip and port or nil
		end
				
		function CLIENT:GetIPPort()
			if not self.connected then return "nil" end
			local ip, port 
			
			if self.__server then 
				ip, port = self.socket:getpeername()
			else
				ip, port = self.socket:getsockname()
			end
			return ip .. ":" .. port
		end
		
		function CLIENT:GetSocketName()
			return self.socket:getpeername()
		end

		function CLIENT:IsValid()
			return true
		end

		function CLIENT:OnTimeout(count) end
		function CLIENT:OnConnect(ip, port) end
		function CLIENT:OnReceive(data) end
		function CLIENT:OnError(msg) self:Remove() end
		function CLIENT:OnSend(data, bytes, b,c,d) end
		function CLIENT:OnClose() end

		function luasocket.Client(typ)
			return new_socket(nil, CLIENT, typ)
		end

		luasocket.ClientMeta = CLIENT
	end

	do -- server
		local SERVER = {}
		SERVER.__index = SERVER

		SERVER.Type = "socket"
		SERVER.ClassName = "server"
		
		add_options(SERVER)

		function SERVER:Initialize()
			self.Clients = {}
		end

		function SERVER:__tostring()
			return string.format("server_%s[%s][%s]", self.socket_type, self:GetIP() or "nil", self:GetPort() or "nil")
		end

		function SERVER:DebugPrintf(fmt, ...)
			luasocket.DebugPrint("%s - " .. fmt, self, ...)
		end

		function SERVER:GetClients()
			return self.Clients
		end
		
		function SERVER:HasClients()
			return next(self.Clients) ~= nil
		end

		function SERVER:Host(ip, port)
			ip = ip or "*"
			port = port or 0
			
			local ok, msg

			if self.socket_type == "tcp" then
				self.socket:setoption("reuseaddr", true)
				ok, msg = self.socket:bind(ip, port)
			elseif self.socket_type == "udp" then
				ok, msg = self.socket:setsockname(ip, port)
			end
			
			if not ok and msg then
				self:DebugPrintf("bind failed: %s", msg)
				self:OnError(msg)
			else
				if self.socket_type == "tcp" then
					ok, msg = self.socket:listen()
					
					if not ok and msg then	
						self:DebugPrintf("bind failed: %s", msg)
						self:OnError(msg)
					end
				end
				self.ready = true
			end
		end

		SERVER.Bind = SERVER.Host

		function SERVER:Send(data, ip, port)
			check(ip, "string")

			if self.socket_type == "tcp" then
				for key, client in pairs(self:GetClients()) do
					if client:GetIP() == ip and (not port or (port == client:GetPort())) then
						client:Send(data)
						break
					end
				end
			elseif self.socket_type == "udp" then
				check(port, "number")
				self.socket:sendto(data, ip, port)
			end
		end

		local DUMMY = {}
		DUMMY.__index = DUMMY

		DUMMY.__tostring = function(s)
			return string.format("dummy_client_%s[%s][%s]", "udp", s.ip or "nil", s.port or "nil")
		end

		DUMMY.GetIP = function(s) return s.ip end
		DUMMY.GetPort = function(s) return s.port end
		DUMMY.IsValid = function() return true end
		DUMMY.Close = function() return end
		DUMMY.Remove = function() return end

		local function create_dummy_client(ip, port)
			return setmetatable({ip = ip, port = port}, DUMMY)
		end

		function SERVER:Think()
			if not self.ready then return end

			if self.socket_type == "udp" then
				local data, ip, port = self.socket:receivefrom()

				if ip == "timeout" then return end

				if not data then
					self:DebugPrintf("errored: %s", ip)
				else
					self:DebugPrintf("received %s from %s:%s", data, ip, port)
					
					local client = create_dummy_client(ip, port)
					local b = self:OnClientConnected(client, ip, port)
					
					if b == true or b == nil then
						self:OnReceive(data, client)
					end
					
					client.IsValid = function() return false end
				end
			elseif self.socket_type == "tcp" then
				local sock = self.socket
				sock:settimeout(0)

				local client, err = sock:accept()

				if client then

					client = new_socket(client, luasocket.ClientMeta, "tcp")
					client.connected = true
					
					self:DebugPrintf("%s connected", client)
					
					table.insert(self.Clients, client)
					client.__server = self
										
					local b = self:OnClientConnected(client, client:GetIP(), client:GetPort())

					if b == true then
						client:SetKeepAlive(true)
						client:SetTimeout()
					elseif b == false then
						client:Remove()
					end
				end
			end
		end
		
		function SERVER:SuppressSend(client)
			self.suppressed_send = client
		end
		
		function SERVER:Broadcast(...)
			for k,v in pairs(self:GetClients()) do
				if self.suppressed_send ~= v then
					v:Send(...)
				end
			end
		end

		function SERVER:KickAllClients()
			for k,v in pairs(self:GetClients()) do
				v.__server = nil
				v:Remove()
			end
		end
		
		function SERVER:Remove()
			self:DebugPrintf("removed")
			self:KickAllClients()			
			remove_socket(self)
		end

		function SERVER:IsValid()
			return true
		end

		function SERVER:GetIP()
			local ip, port = self.socket:getsockname()
			return ip
		end

		function SERVER:GetPort()
			local ip, port = self.socket:getsockname()
			return ip and port or nil
		end
		
		function SERVER:GetIPPort()
			local ip, port = self.socket:getsockname()
			return ip .. ":" .. port
		end
		
		function SERVER:GetSocketName()
			return self.socket:getsockname()
		end

		function SERVER:OnClientConnected(client, ip, port) end
		function SERVER:OnClientClosed(client) end
		function SERVER:OnReceive(data, client) end
		function SERVER:OnClientError(client, err) end
		function SERVER:OnError(msg) self:Remove() end

		function luasocket.Server(typ)
			return new_socket(nil, SERVER, typ)
		end

		luasocket.ServerMeta = SERVER
	end
end

luasocket.Initialized()
luasocket.Initialized = nil

return luasocket