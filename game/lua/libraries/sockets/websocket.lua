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
			self.socket:SetSSLParams(ssl_params or "https")
		end
	else
		local protocol, host, port, uri = tools.parse_url(url)

		if protocol == "wss" then
			self.socket:SetSSLParams(ssl_params or "https")
		end

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
		table.insert(self.send_buffer, data)
	else
		self.socket:Send(data)
	end
end

function META:Close(reason, code)
	local encoded = frame.encode_close(code or 1000, reason)
	self.socket:Send(frame.encode(encoded, frame.CLOSE, true))
end

function META:OnRemove()
	if self.socket:IsValid() then
		self.socket:Remove()
	end
end

function META:OnReceive()
end

function META:OnError(err)
	logn(err)
end

function META:OnClose()

end

function sockets.CreateWebsocketClient()
	local self = META:CreateObject()
	self.socket = sockets.CreateClient("tcp")
	self.socket:SetTimeout()
	self.socket:SetReceiveMode("all")
	self.socket:SetKeepAlive(true)
	self.socket:SetNoDelay(true)

	self.socket.OnConnect = function()
		self.key = tools.generate_key()
		local req = handshake.upgrade_request({
			key = self.key,
			host = self.host,
			port = self.port,
			protocols = self.protocols_tbl or {""},
			origin = self.origin,
			uri = self.uri,
		})
		self.socket:Send(req, true)
	end

	self.socket.OnClose = function()
		self:Remove()
	end

	local in_header = true

	self.socket.OnReceive = function(socket, str)
		if in_header then
			local header_data, rest = str:match("(.-\r\n\r\n)(.+)")

			if header_data then
				str = rest
			else
				header_data = str
				str = nil
			end

			local header = sockets.HeaderToTable(header_data)
			local expected_accept = handshake.sec_websocket_accept(self.key)

			if header["sec-websocket-accept"] ~= expected_accept then
				self:OnError(("Accept failed. Expected %s got %s"):format(expected_accept, header["sec-websocket-accept"]))
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

			local last_rest

			repeat
				local decoded, fin, opcode, rest = frame.decode(encoded)

				if decoded then
					if not first_opcode then
						first_opcode = opcode
					end
					table.insert(frames, decoded)
					encoded = rest
					if fin == true then
						local message = table.concat(frames)

						if first_opcode == frame.CLOSE or opcode == frame.CLOSE then
							local code, reason = frame.decode_close(message)
							local encoded = frame.encode_close(code)
							encoded = frame.encode(encoded, frame.CLOSE, true)
							self.socket:Send(encoded, true)
							self:OnClose(reason, code)
							self.socket:Remove()
							return
						else
							self:OnReceive(message, opcode)
						end
					end
				end
			until not decoded

			if #encoded > 0 then
				self.last_encoded = encoded
			end
		end
	end

	return self
end

META:Register()

if RELOAD then
	local socket = sockets.CreateWebsocketClient()
	--socket:Connect("wss://echo.websocket.org")
	socket:Connect("10.0.0.54", 27020)
	local str = {}
	for i = 1, 500000 do
		str[i] = tostring(i)
	end

	str = table.concat(str, " ") .. "THE END"
	print("sending " .. utility.FormatFileSize(#str), #str, str:sub(-100))
	socket:Send(str)

	function socket:OnReceive(message, opcode)
		print("received " .. utility.FormatFileSize(#message), #message, message:sub(-100))
	end

	LOL = socket
end