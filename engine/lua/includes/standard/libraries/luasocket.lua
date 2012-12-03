include("luasocket/ltn12.lua")
include("luasocket/socket.lua")
include("luasocket/mime.lua")

include("luasocket/socket/url.lua")
include("luasocket/socket/http.lua")
include("luasocket/socket/tp.lua")
include("luasocket/socket/smtp.lua")
include("luasocket/socket/ftp.lua")

luasocket = {}

luasocket.ltn12 = require("mime")
luasocket.socket = require("socket")
luasocket.mime = require("mime")
luasocket.url = require("socket.url")
luasocket.http = require("socket.http")
luasocket.tp = require("socket.tp")
luasocket.smtp = require("socket.smtp")
luasocket.ftp = require("socket.ftp")

http = {}

function http.HeaderToTable(header)
	local tbl = {}

	for key, line in pairs(header:Explode("\n")) do
		if #line ~= 0 then
			local key, value = line:match("(.+):%s+(.+)")
			if key and value then
				tbl[key] = value
			end
		end
	end

	return tbl
end

function http.TableToHeader(tbl)
	local str = ""

	for key, value in pairs(tbl) do
		str = str .. tostring(key) .. ": " .. tostring(value) .. "\n"
	end

	return str
end

function http.Get(url, callback, header)
	check(url, "string")
	check(header, "string", "nil")
	check(callback, "function", "nil", "false")

	url = url:gsub("http://", "")
	callback = callback or table.print

	local host, get = url:match("(.-)/(.+)")

	if not get then
		host = url:gsub("/", "")
		get = ""
	end	

	local socket = luasocket.Client("tcp")
	socket:Connect(host, 80)
	
	socket:Send(F("GET /%s HTTP/1.1\r\n", get))
	socket:Send(F("Host: %s\r\n", host))
	socket:Send("User-Agent: oohh\r\n")
	socket:Send("\r\n")
	socket:SetMaxTimeouts(5000)
	
	local header = ""
	local content = ""
	local status
	local isheader = true

	function socket:OnReceive(line)
		if not status then
			status = line
		end

		if isheader then
			if #line == 0 then
				isheader = false
			else
				header = header  .. line .. "\n"
			end
		else
			content = content .. line .. "\n"
		end
	end
	
	function socket:OnClose()
		local ok, err = pcall(callback, {content = content, header = http.HeaderToTable(header), status = status})
		if err then
			print(err)
		end
	end
end

do -- tcp socket meta
	local sockets = {}

	events.AddListener("LuaClose", "socket_close", function()
		for key, sock in pairs(sockets) do
			if sock:IsValid() then
				sock:Remove()
			else
				table.remove(sockets, key)
			end
		end
	end)

	timer.Create("socket_think", 0, 0, function()
		for key, sock in pairs(sockets) do
			if sock:IsValid() then
				sock:Think()
			else
				table.remove(sockets, key)
			end
		end
	end)

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

			return obj
		end
	end

	local function remove_socket(self)
		self.socket:close()
		for key, sock in pairs(sockets) do
			if sock == self then
				table.remove(sockets, key)
				break
			end
		end
		timer.Simple(0.1, function() MakeNULL(self) end)
	end

	do -- client
		local CLIENT = {}
		CLIENT.__index = CLIENT

		function CLIENT:Initialize()
			self.Buffer = {}
		end

		function CLIENT:__tostring()
			return string.format("client_%s[%s][%s]", self.socket_type, self:GetIP() or "none", self:GetPort() or "0")
		end

		function CLIENT:DebugPrintf(fmt, ...)
			if luasocket.debug then
				nospam_printf("%s - " .. fmt, self, ...)
			end
		end

		function CLIENT:Connect(ip, port)
			check(ip, "string")
			check(port, "number")

			self.socket:settimeout(0)
			if self.socket_type == "tcp" then
				self.socket:connect(ip, port)
			else
				self.socket:setpeername(ip, port)
			end
			self.socket:settimeout(0)

			self.connecting = true
		end

		function CLIENT:Send(str, instant)
			if self.socket_type == "tcp" then
				if instant then
					local bytes,b,c,d = self.socket:send(str)

					if bytes then
						if self.OnSend then
							self:OnSend(data, bytes, b,c,d)
						end
						self:DebugPrintf("sucessfully sent %q", data)
					end
				else
					table.insert(self.Buffer, str)
				end
			else
				self.socket:send(str)
			end
		end

		function CLIENT:Think()
			local sock = self.socket
			sock:settimeout(0)

			if self.connecting then
				local res, err = sock:getpeername()
				if res then
					-- ip, port = res, err

					self.connected = true
					self.connecting = nil
					if self.OnConnect then
						self:OnConnect(res, err)
					end

					self:DebugPrintf("connected to %s:%s", res, err)

					self.Timeouts = 0
				elseif err == "timeout" or err == "getpeername failed" then
					self:Timeout()
				else
					if self.OnError then
						self:OnError(err)
					end
					self.connecting = nil
					self:DebugPrintf("errored: %s", err)
				end
			end

			if self.socket_type == "tcp" and self.connected then
				while true do
					local data = self.Buffer[1]
					if data then
						local bytes,b,c,d = sock:send(data)

						if bytes then
							if self.OnSend then
								self:OnSend(data, bytes, b,c,d)
							end
							self:DebugPrintf("sucessfully sent %q", data)
							table.remove(self.Buffer, 1)
						end
					else
						break
					end
				end

				local data, err, partial = sock:receive("*l")
				if not data and partial ~= "" then
					data = partial
				end

				--self:DebugPrintf("receive: %s, %s, %s, %i", data or "", err or "", partial or "", self.Timeouts)
				
				if data then
					if self.OnReceive then
						self:OnReceive(data)
					end
					self:DebugPrintf("received %q", data)
					self.Timeouts = 0
				elseif err == "timeout" then
					self:Timeout()
				elseif err == "Socket is not connected" then
					--self.connected = false
					--self.connecting = true
				elseif err == "closed" then
					self:DebugPrintf("wants to close", client)
					if self.OnClose then
						self:OnClose()
					end
					self:Remove()
				elseif self.OnError then
					self:OnError(err)
					self:DebugPrintf("errored: %s", err)
				end
			end
		end

		CLIENT.MaxTimeouts = 100
		CLIENT.Timeouts = 0

		function CLIENT:Timeout()
			if not self.OnTimeout or self:OnTimeout(self.Timeouts) ~= false then
				self.Timeouts = self.Timeouts + 1
				if self.Timeouts > self.MaxTimeouts then
					if self.OnClose then
						self:OnClose()
					end
					
					self:Remove()
				end
			end
		end

		function CLIENT:SetMaxTimeouts(num)
			self.MaxTimeouts = num
		end

		function CLIENT:Remove()
			remove_socket(self)
		end

		function CLIENT:OnClose()
			self:Remove()
		end

		function CLIENT:IsConnected()
			return self.connected == true
		end

		function CLIENT:IsSending()
			return #self.Buffer > 0
		end

		function CLIENT:GetIP()
			local ip, port = self.socket:getpeername()
			return ip
		end

		function CLIENT:GetPort()
			local ip, port = self.socket:getpeername()
			return ip and port or nil
		end

		function CLIENT:IsValid()
			return true
		end

		function luasocket.Client(typ)
			return new_socket(nil, CLIENT, typ)
		end

		luasocket.ClientMeta = CLIENT
	end

	do -- server
		local SERVER = {}
		SERVER.__index = SERVER

		function SERVER:Initialize()
			self.Clients = {}
		end

		function SERVER:__tostring()
			return string.format("server_%s[%s][%s]", self.socket_type, self:GetIP() or "nil", self:GetPort() or "nil")
		end

		function SERVER:DebugPrintf(fmt, ...)
			if luasocket.debug then
				printf("%s - " .. fmt, self, ...)
			end
		end

		function SERVER:GetClients()
			local copy = {}
			for key, client in pairs(self.Clients) do
				if client.IsValid and client:IsValid() then
					table.insert(copy, client)
				else
					table.remove(self.Clients, key)
				end
			end
			return copy
		end

		function SERVER:Host(ip, port)
			ip = ip or "*"
			port = port or 0

			if self.socket_type == "tcp" then
				self.socket:settimeout(0)
				self.socket:setoption("reuseaddr", true)
				self.socket:bind(ip, port)
				self.socket:listen()
				self.socket:settimeout(0)
				self.ready = true
			elseif self.socket_type == "udp" then
				self.socket:settimeout(0)
				self.socket:setsockname(ip, port)
				self.socket:settimeout(0)
				self.ready = true
			end
		end

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

		SERVER.Bind = SERVER.Host

		function SERVER:Think()
			if not self.ready then return end

			if self.socket_type == "udp" then
				local data, ip, port = self.socket:receivefrom()

				if data then
					if self.OnReceive then
						self:OnReceive(data, ip, port)
					end

					self:DebugPrintf("received %s from %s:%s", data, ip, port)
				elseif ip ~= "timeout" then
					self:DebugPrintf("%s errored: ", client, err)
				end
			elseif self.socket_type == "tcp" then
				local sock = self.socket
				sock:settimeout(0)

				local ls_client, err = sock:accept()

				if ls_client then
					local client = new_socket(ls_client, luasocket.ClientMeta, "tcp")
					client.connected = true
					table.insert(self.Clients, client)

					if self.OnClientConnected then
						if self:OnClientConnected(client, client:GetIP(), client:GetPort()) == false then
							client:Remove()
						end
					end
					self:DebugPrintf("%s connected", client)
				end

				for _, client in pairs(self:GetClients()) do
					local data, err, partial = client.socket:receive()
					if data then

						if self.OnReceive then
							self:OnReceive(data, client)
						end

						if client.OnSend then
							client:OnSend(data)
						end

						self:DebugPrintf("received %s from %s", data, client)

					elseif err == "closed" then
						self:DebugPrintf("%s wants to close", client)
						if not self.OnClientClose or self:OnClientClose(client) ~= false then
							if client.OnClose then
								client:OnClose()
							end
							
							client:Remove()
						end
					elseif err == "timeout" then
						--client:Timeout() -- hmm
					else
						if self.OnClientError then
							self:OnClientError(client, err)
						end
						if client.OnError then
							client:OnError(err)
						end
						self:DebugPrintf("%s errored: ", client, err)
					end
				end
			end
		end

		function SERVER:Remove()
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

		function luasocket.Server(typ)
			return new_socket(nil, SERVER, typ)
		end

		luasocket.ServerMeta = SERVER
	end

	do return end

	timer.Simple(1, function()
		print("go")

		do -- UDP
			local server = luasocket.Server("udp")
			server:Host("10.0.0.1", 888)

			function server:OnReceive(data, ip, port)
				server:Send("hi", ip, port)
			end

			local client = luasocket.Client("udp")
				client:Connect("10.0.0.1", 888)
				client:Send("hello")
				client:Send("hello")
				client:Send("hello")
				client:Send("hello")
		end

		do -- TCP
			local server = luasocket.Server("tcp")
				server:Host("10.0.0.1", 555)

				function server:OnReceieve(data, client)
					self:Send("hi", client:GetIP())
				end

			local client = luasocket.Client("tcp")
				client:Connect("10.0.0.1", 555)
				client:Send("hello\n")
				client:Send("hello\n")
				client:Send("hello\n")
				client:Send("hello\n")
		end
	end)

end
