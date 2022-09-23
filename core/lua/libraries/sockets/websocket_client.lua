local sockets = ... or _G.sockets
local META = prototype.CreateTemplate("websocket_client")
local tools = require("websocket.tools")
local frame = require("websocket.frame")
local handshake = require("websocket.handshake")

function META:Connect(url, ws_protocol, ssl_params)
	if type(ws_protocol) == "number" then
		self.host = url
		self.port = ws_protocol

		if ssl_params then
			if ssl_params == "wss" then ssl_params = "https" end

			self.socket:SetupTLS()
		end
	else
		local protocol, host, port, uri = tools.parse_url(url)

		if protocol == "wss" then self.socket:SetupTLS() end

		self.host = host
		self.port = port
		self.uri = uri

		if type(ws_protocol) == "string" then
			self.protocols_tbl = {ws_protocol}
		elseif type(ws_protocol) == "table" then
			self.protocols_tbl = ws_protocol
		end
	end

	self.socket:Connect(self.host, self.port)
end

function META:Send(message, opcode)
	local data = frame.encode(message, opcode or frame.TEXT, true)

	if not self.ready then
		self.send_buffer = self.send_buffer or {}
		list.insert(self.send_buffer, data)
	else
		self.socket:Send(data)
	end
end

function META:Close(reason, code)
	local encoded = frame.encode_close(code or 1000, reason)
	self.socket:Send(frame.encode(encoded, frame.CLOSE, true))
end

function META:OnRemove()
	if self.socket:IsValid() then self.socket:Remove() end
end

function META:OnReceive() end

function META:OnError(err)
	logn(err)
end

function META:OnClose() end

local function header_to_table(header)
	local tbl = {}

	if not header then return tbl end

	for _, line in ipairs(header:split("\n")) do
		local key, value = line:match("(.+):%s+(.+)\r")

		if key and value then tbl[key:lower()] = tonumber(value) or value end
	end

	return tbl
end

function sockets.CreateWebsocketClient()
	local self = META:CreateObject()
	self.socket = sockets.TCPClient()
	self.socket.socket:set_option("keepalive", true)
	self.socket.OnConnect = function()
		self.key = tools.generate_key()
		local req = handshake.upgrade_request(
			{
				key = self.key,
				host = self.host,
				port = self.port,
				protocols = self.protocols_tbl or {""},
				origin = self.origin,
				uri = self.uri,
			}
		)
		self.socket:Send(req)
	end
	self.socket.OnClose = function(socket, why)
		--if why == "receive" then return end
		self:Remove()
	end
	local in_header = true
	self.socket.OnReceiveChunk = function(socket, str)
		if in_header then
			local header_data, rest = str:match("^(.-\n\n)(.+)")

			if header_data then
				str = rest
			else
				header_data = str
				str = nil
			end

			local header = header_to_table(header_data)
			local expected_accept = handshake.sec_websocket_accept(self.key)

			if header["sec-websocket-accept"] ~= expected_accept then
				self:OnError(
					(
						"Accept failed. Expected %s got %s"
					):format(expected_accept, header["sec-websocket-accept"])
				)
				return
			end

			self.ready = true

			if self.send_buffer then
				for k, v in ipairs(self.send_buffer) do
					self.socket:Send(v)
				end
			end

			in_header = false
		end

		if str then
			local first_opcode
			local frames = {}
			local encoded = str

			if self.last_encoded then
				encoded = self.last_encoded .. str
				self.last_encoded = nil
			end

			repeat
				local decoded, fin, opcode, rest = frame.decode(encoded)

				if decoded then
					if not first_opcode then first_opcode = opcode end

					list.insert(frames, decoded)
					encoded = rest

					if fin == true then
						local message = list.concat(frames)

						if first_opcode == frame.CLOSE or opcode == frame.CLOSE then
							local code, reason = frame.decode_close(message)
							local encoded = frame.encode_close(code)
							encoded = frame.encode(encoded, frame.CLOSE, true)
							self.socket:Send(encoded)
							self:OnClose(reason, code)
							self.socket:Remove()
							return
						else
							frames = {}
							self:OnReceive(message, opcode)
						end
					end
				elseif #encoded > 0 then
					self.last_encoded = encoded
				end			
			until not decoded
		end
	end
	return self
end

META:Register()

if RELOAD then
	local socket = sockets.CreateWebsocketClient()
	--socket:Connect("wss://demos.kaazing.com/echo")
	socket:Connect("192.168.122.1", 8765)
	local str = {}

	for i = 1, 500000 do
		str[i] = tostring(i)
	end

	--str = list.concat(str, " ") .. "THE END"
	str = "hello"
	print("sending " .. utility.FormatFileSize(#str), #str, str:sub(-100))
	socket:Send(str)

	function socket:OnReceive(message, opcode)
		print("received " .. utility.FormatFileSize(#message), #message, message:sub(-100))
	end

	LOL = socket
end