local sockets = _G.sockets or {}

local bsocket = require("bsocket")

sockets.active_sockets = sockets.active_sockets or {}

runfile("lua/libraries/sockets/http.lua", sockets)

function sockets.Initialize()
	event.Timer("sockets", 1/30, 0, function() sockets.Update() end, nil, function(...) logn(...) return true end)
	event.AddListener("LuaClose", "sockets", sockets.Panic)
end

function sockets.Shutdown()
	sockets.Panic()
	event.RemoveListener("Update", "sockets")
	event.RemoveListener("LuaClose", "sockets")
end

function sockets.DebugPrint(self, ...)
	if sockets.debug or (self and self.debug) then
		local tbl = {}

		for i = 1, select("#", ...) do
			tbl[i] = tostring(select(i, ...))
		end

		logn(string.format(unpack(tbl)))
	end
end

function sockets.Update(remove_only)
	for i = #sockets.active_sockets, 1, -1 do
		local sock = sockets.active_sockets[i]

		if sock then

			if sock.remove_me then
				if sock.socket then sock.socket:close() end
				sock.socket = nil
				collectgarbage("step")
				sock:DebugPrintf("closed real socket object")
				prototype.MakeNULL(sock)
			end

			if not remove_only then
				if sock:IsValid() then
					local ok, err = system.pcall(sock.Think, sock)
					if not ok then
						logn(err)
						sock:Remove()
					end
				else
					table.remove(sockets.active_sockets, i)
				end
			end
		end
	end
end

function sockets.GetSockets()
	return sockets.active_sockets
end

function sockets.Panic()
	for _, sock in pairs(sockets.active_sockets) do
		if sock:IsValid() then
			sock:DebugPrintf("removed from sockets.Panic()")
			sock:Remove()
		end
	end

	table.clear(sockets.active_sockets)
end

local function new_socket(override, META, ip_proto, id)
	ip_proto = ip_proto or "tcp"
	ip_proto = ip_proto:lower()

	-- this removes any sockets
	sockets.Update(true)

	if id then
		for _, socket in ipairs(sockets.active_sockets) do
			if socket.uid == id then
				socket:Remove()
			end
		end
	end

	local self = META:CreateObject()

	local t
	self.socket = override or assert(bsocket.socket("inet", ip_proto == "tcp" and "stream" or ip_proto == "udp" and "dgram", ip_proto))
	self.socket:set_blocking(false)

	self.socket_type = ip_proto
	self.data_sent = 0
	self.data_received = 0

	self:Initialize()

	table.insert(sockets.active_sockets, self)

	self:DebugPrintf("created")

	self.uid = id

	return self
end

local SHARED = {}
function SHARED:Error(msg)
	self:DebugPrintf("errored!: %s", msg)

	if sockets.debug then
		debug.trace()
	end

	if self:OnError(msg) ~= false then
		self:Remove()
	end
end

do -- tcp socket meta
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
				self.socket:set_option(key, val)
				self:DebugPrintf("option[%q] = %s", key, val)
				self[func_name] = val
			end

			tbl["Get" .. func_name] = function(self)
				return self[func_name]
			end
		end
	end

	do -- client
		local CLIENT = prototype.CreateTemplate("socket_client")

		add_options(CLIENT)

		function CLIENT:Initialize()
			self.Buffer = {}
			self:SetTimeout(3)
		end

		function CLIENT:GetStatistics()
			return {
				received = utility.FormatFileSize(self.data_received),
				sent = utility.FormatFileSize(self.data_sent),
			}
		end

		function CLIENT:__tostring2()
			return string.format("[%s][%s][%s]", self.socket_type, self:GetIP() or "none", self:GetPort() or "0")
		end

		function CLIENT:DebugPrintf(fmt, ...)
			sockets.DebugPrint(self, "%s - " .. fmt, self, ...)
		end

		do
			CLIENT:GetSet("SSLParams")

			local https_default = {
				protocol = "tlsv1_2",
				verify = "none",
				mode = "client",
				options = {"all", "no_sslv2", "no_sslv3"},
			}

			function CLIENT:SetSSLParams(params)
				if params == "https" then
					params = https_default
				end

				local copy = {}

				for k,v in pairs(https_default) do
					copy[k] = params[k] or v
				end

				self.SSLParams = copy

				local SSL = desire("libressl")
				if SSL and ssl.tls_init then
					local ffi = require("ffi")
					SSL.tls_init()
					local tls = SSL.tls_client()
					local config = SSL.tls_config_new()
					SSL.tls_config_insecure_noverifycert(config)
					SSL.tls_config_insecure_noverifyname(config)
					SSL.tls_configure(tls, config)

					function self.socket:on_connect(host, serivce)
						if SSL.tls_connect_socket(tls, self.fd, host) < 0 then
							if len == -3 or len == -2 then
								return true, "blocking"
							end
							local err = SSL.tls_error(tls)
							return nil, err ~= nil and ffi.string(err) or "unknown connect error " .. tonumber(len)
						end
						return true
					end

					function self.socket:on_send(data, flags)
						local len = SSL.tls_write(tls, data, #data)
						if len < 0 then
							if len == -3 or len == -2 then
								return true, "blocking"
							end
							local err = SSL.tls_error(tls)
							return nil, err ~= nil and ffi.string(err) or "unknown write error " .. tonumber(len)
						end
						return len
					end

					function self.socket:on_receive(buffer, max_size, flags)
						local len = SSL.tls_read(tls, buffer, max_size)
						if len < 0 then
							if len == -3 or len == -2 then
								return true, "blocking"
							end
							local err = SSL.tls_error(tls)
							return nil, err ~= nil and ffi.string(err) or "unknown read error " .. tonumber(len)
						end
						return ffi.string(buffer, len)
					end
				end
			end
		end

		function CLIENT:Connect(ip, port)
			self:DebugPrintf("connecting to %s:%s", ip, port)

			local ok, msg

			if self.socket_type == "tcp" then
				ok, msg = self.socket:connect(ip, tostring(port))
			else
				ok, msg = self.socket:set_peer_name(ip, tostring(port))
			end

			if not ok and msg and 
				msg ~= "timeout" and 
				msg ~= "Operation already in progress" and 
				(WINDOWS and msg ~= "Invalid argument") and
				msg ~= "A non-blocking socket operation could not be completed immediately. (10035)"
			then
				self:DebugPrintf("connect failed: %s", msg)
				self:Error(msg)

				if WINDOWS and msg == "Invalid argument" then
					if not LUASOCKET_INVALID_ARGUMENT then
						logn("socket:connect returns Invalid argument!? luasocket on windows quirk")
						LUASOCKET_INVALID_ARGUMENT = true
					end
				end
			else
				self.connecting = true
			end

			self.ip = ip
			self.port = port
		end

		function CLIENT:Send(str, instant)
			if self.socket_type == "tcp" then
				if instant then
					local bytes, b, c, d = self.socket:send(str)

					if bytes then
						self:DebugPrintf("sucessfully sent %s", str)
						self:OnSend(packet, bytes, b,c,d)
						self.data_sent = self.data_sent + bytes
					elseif b ~= "Socket is not connected" then
						self:DebugPrintf("could not send %s of data : %s", utility.FormatFileSize(#str), b)
					end
				else
					for _, packet in pairs(str:lengthsplit(65536)) do
						table.insert(self.Buffer, packet)
					end
				end
			else
				self.socket:send(str)
				self:DebugPrintf("sent %q", str:readablehex())
				self.data_sent = self.data_sent + #str
			end

			if sockets.trace then debug.trace() end
		end

		function CLIENT:CloseWhenDoneSending(b)
			self.close_when_done = b
		end

		CLIENT.ReceiveMode = "all"

		function CLIENT:SetReceiveMode(type)
			self.ReceiveMode = type
		end

		function CLIENT:GetReceiveMode()
			return self.ReceiveMode
		end

		local receive_types = {all = "*a", line = "*l"}

		function CLIENT:Think()
			if self.TimeoutLength and system.GetFrameTime() > self.TimeoutLength / 2 then
				self:Timeout(false)
			end

			-- check connection
			if self.connecting then
				if self.socket:is_connected() then
					self:DebugPrintf("connected to %s:%s", self.socket:get_peer_name())

					if self.SSLParams and self.socket.on_connect then
						self:DebugPrintf("start handshake")
						self.socket:on_connect(self.ip)
					end

					self:OnConnect(res, msg)

					-- ip, port = res, msg
					self.connected = true
					self.connecting = nil

					self:Timeout(false)
				else
					self:Timeout(true)
				end
			end

			if self.connected then
				-- try send

				if self.socket_type == "tcp" then
					for _ = 1, 128 do
						local data = self.Buffer[1]
						if data then
							local bytes, b, c, d = self.socket:send(data)

							if bytes == true and b == "blocking" then

							elseif bytes then
								if self.debug then
									self:DebugPrintf("SEND: |%s|",  data:gsub("%s", function(c) if c:byte() < 32 or c:byte() > 126 then return "\\" .. c:byte() end end))
								end
								self:OnSend(data, bytes, b,c,d)
								table.remove(self.Buffer, 1)

								self.datas_ent = self.data_sent + bytes

								if self.__server then
									self.__server.data_sent = self.__server.data_sent + bytes
								end
							else
								if b ~= "Socket is not connected" and b ~= "wantwrite" and b ~= "context not connected" then
									self:DebugPrintf("could not send %s of data : %s", utility.FormatFileSize(#data), b)
								end
--								break
							end
						else
							if self.close_when_done then
								self:Remove()
							end
--							break
						end
					end
				end

				for _ = 1, 128 do
					local data, err = self.socket:receive()

					if data == true and err == "blocking" then

					elseif data then
						self:DebugPrintf("RECV: |%s|",  data)
						print(data, err, "!!")
						self:OnReceive(data)

						if not self:IsValid() then return end

						self:Timeout(false)

						if self.__server then
							self.__server:OnReceive(data, self)
							self.__server.data_received = self.__server.data_received + #data
						end

						self.data_received = self.data_received + #data
					elseif err then
						if
							err == "timeout" or
							err == "Socket is not connected" or
							err == "wantread" or
							err == "Resource temporarily unavailable" or
							err == "Operation now in progress" or
							err:find("not connected", nil, true) or
							err:find("blocking", nil, true)
						then
							self:Timeout(true)
						elseif err == "closed" then
							self:DebugPrintf("closed")

							if not self.__server or self.__server:OnClientClosed(self) ~= false then
								self:Remove()
							end
						else
							if self.__server then
								self.__server:OnClientError(self, err)
							end

							self:Error(err)
						end
						break
					end
				end
			end
		end

		do -- timeout
			function CLIENT:Timeout(bool)
				if not self.TimeoutLength then return end

				local time = system.GetElapsedTime()

				if not bool then
					self.TimeoutStart = time
					return
				end

				if not self.TimeoutStart then
					self.TimeoutStart = time + self.TimeoutLength
				end
				local seconds = time - self.TimeoutStart

				if self:OnTimeout(seconds) ~= false then
					if seconds > self.TimeoutLength then
						self:DebugPrintf("timed out")
						self:OnTimedOut()
						self:Remove()
					end
				end
			end

			function CLIENT:GetTimeoutDuration()
				if not self.TimeoutStart then return 0 end

				local t = system.GetElapsedTime()
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

			self.remove_me = true

			self:OnClose()

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

			if not self.socket then return "nil" end

			if self.__server then
				ip, port = self.socket:get_peer_name()
			else
				ip, port = self.socket:get_name()
			end

			return ip
		end

		function CLIENT:GetPort()
			if not self.connected then return "nil" end
			if not self.socket then return "nosock" end

			local ip, port

			if self.__server then
				ip, port = self.socket:get_peer_name()
			else
				ip, port = self.socket:get_name()
			end
			return ip and tonumber(port) or nil
		end

		function CLIENT:GetIPPort()
			if not self.connected then return "nil" end
			if not self.socket then return "nosock" end

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
			return self.remove_me == nil
		end

		function CLIENT:OnTimeout(count) end
		function CLIENT:OnTimedOut() end
		function CLIENT:OnConnect(ip, port) end
		function CLIENT:OnReceive(data) end
		function CLIENT:OnError(msg) end
		function CLIENT:OnSend(data, bytes, b,c,d) end
		function CLIENT:OnClose() end
		CLIENT.Error = SHARED.Error

		function sockets.CreateClient(type, ip, port, id)
			local self = new_socket(nil, CLIENT, type, id)
			if ip and port then
				self:Connect(ip, port)
			end
			return self
		end

		sockets.ClientMeta = CLIENT
		prototype.Register(CLIENT)
	end

	do -- server
		local SERVER = prototype.CreateTemplate("socket_server")

		add_options(SERVER)

		function SERVER:Initialize()
			self.Clients = {}
		end

		function SERVER:GetStatistics()
			return {
				received = utility.FormatFileSize(self.data_received),
				sent = utility.FormatFileSize(self.data_sent),
			}
		end

		function SERVER:__tostring2()
			return string.format("[%s][%s][%s]", self.socket_type, self:GetIP() or "nil", self:GetPort() or "nil")
		end

		function SERVER:DebugPrintf(fmt, ...)
			sockets.DebugPrint(self, "%s - " .. fmt, self, ...)
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

			for i, v in ipairs(sockets.active_sockets) do
				if v.socket_type == self.socket_type and v:GetPort() == port then
					v:Remove(true)
				end
			end


			if self.socket_type == "tcp" then
				ok, msg = self.socket:bind(ip, port)
			elseif self.socket_type == "udp" then
				ok, msg = self.socket:setsockname(ip, port)
			end

			if not ok and msg then
				if msg == "address already in use" then
					self.retry_host = {
						ip = ip,
						port = port,
						next_try = system.GetElapsedTime() + 3,
					}
					self:DebugPrintf("address already in use (%s:%s) retrying in 3 seconds", ip, port)
				else
					self:DebugPrintf("bind failed: %s", msg)
					self:Error(msg)
				end
			else
				self.retry_host = nil

				if self.socket_type == "tcp" then
					ok, msg = self.socket:listen()

					if not ok and msg then
						self:DebugPrintf("bind failed: %s", msg)
						self:Error(msg)
					end
				end
				self.ready = true
			end
		end

		SERVER.Bind = SERVER.Host

		function SERVER:Send(data, ip, port)
			if self.socket_type == "tcp" then
				for _, client in pairs(self:GetClients()) do
					if client:GetIP() == ip and (not port or (port == client:GetPort())) then
						client:Send(data)
						break
					end
				end
			elseif self.socket_type == "udp" then
				self.socket:sendto(data, ip, port)
				self.data_sent = self.data_sent + #data
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

		function SERVER:UseDummyClient(bool)
			self.use_dummy_client = bool
		end

		function SERVER:Think()

			if self.retry_host then
				if self.retry_host.next_try < system.GetElapsedTime() then
					self:Host(self.retry_host.ip, self.retry_host.port)
				end
			end

			if not self.ready then return end

			if self.socket_type == "udp" then
				local data, ip, port = self.socket:receivefrom()

				if ip == "timeout" then return end

				if not ip or not port then
					self:Error(ip)
				else
					self:DebugPrintf("received %s from %s:%s", data, ip, port)

					if self.use_dummy_client == false then
						self:OnReceive(data, ip, port)
					else
						local client = create_dummy_client(ip, port)
						local b = self:OnClientConnected(client, ip, port)

						if b == true or b == nil then
							self:OnReceive(data, client)
						end

						client.IsValid = function() return false end
					end

					self.data_received = self.data_received + #data
				end
			elseif self.socket_type == "tcp" then
				local client = self.socket:accept()

				if client then

					client = new_socket(client, sockets.ClientMeta, "tcp")
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
			for _, v in pairs(self:GetClients()) do
				if self.suppressed_send ~= v then
					v:Send(...)
				end
			end
		end

		function SERVER:KickAllClients()
			for _, v in pairs(self:GetClients()) do
				v.__server = nil
				v:Remove()
			end
		end

		function SERVER:Remove(now)
			if self.remove_me then return end
			self:DebugPrintf("removed")
			self:KickAllClients()
			self.remove_me = true

			if now then
				sockets.Update(true)
			end
		end

		function SERVER:IsValid()
			return self.remove_me == nil
		end

		function SERVER:GetIP()
			return (self.socket:getsockname())
		end

		function SERVER:GetPort()
			local _, port = self.socket:getsockname()
			return tonumber(port) or nil
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
		function SERVER:OnError(msg) end
		SERVER.Error = SHARED.Error

		function sockets.CreateServer(type, ip, port, id)
			local self = new_socket(nil, SERVER, type, id)
			if ip or port then
				self:Host(ip, port)
			end
			return self
		end

		sockets.ServerMeta = SERVER
		prototype.Register(SERVER)
	end
end

return sockets
