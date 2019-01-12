local sockets = ... or _G.sockets
local bsocket = require("bsocket")

local META = prototype.CreateTemplate("websocket_server")

local tools = require("websocket.tools")
local frame = require("websocket.frame")
local handshake = require("websocket.handshake")

function META:Bind(host, port)
	if host == "*" then
		host = nil
	end

	for _, info in ipairs(assert(bsocket.get_address_info({
        host = host,
        service = tostring(port),
        family = self.socket.family,
        type = self.socket.socket_type,
        protocol = self.socket.protocol,
        flags = {"passive"}, -- fill in ip
	}))) do
		if info.family == self.socket.family then
			assert(self.socket:bind(info))
			assert(self.socket:listen())
			break
		end
	end

	local clients = {}

	event.Thinker(function()
		local client, err = self.socket:accept()
		if client then
			print(client, " wants to connect..")
			assert(client:set_blocking(false))
			client.state = "connecting"
			table.insert(clients, client)
		end

		for _, client in ipairs(clients) do
			if client.state == "connecting" then
				local data = assert(client:receive2())

				if data ~= true then
					local response, protocol = handshake.accept_upgrade(data, {""})
					if not response then
						print(client, " refused")
						client:send(protocol)
						return
					end

					client:send(response)

					client.decoding = true
					client.buffer = ""
					client.state = "connected"

					print(client, " connected")
					print(response)
					print(#data)
					local theend, rest = data:match("(\r\n\r\n)(.*)")

					print(#theend, rest and #rest)
				end
			end

			if client.state == "connected" then
				local data = assert(client:receive2())

				if data ~= bsocket.TIMEOUT then
					print("received data")
					local first_opcode
					local frames = {}

					local encoded = data

					if self.last_encoded then
						encoded = self.last_encoded .. data
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
									self.socket:send(encoded)
									self:OnClose(reason, code)
									self.socket:close()
									return
								else
									self:OnReceive(client, message, opcode)
								end
							end
						end
					until not decoded

					if #encoded > 0 then
						self.last_encoded = encoded
					end
				end
			end
		end
	end)
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

function sockets.CreateWebsocketServer(protocols)
	protocols = protocols or {}

	local self = META:CreateObject()

	local socket = assert(bsocket.socket("inet", "stream", "tcp"))
	assert(socket:set_blocking(false))
    socket:set_option("reuseaddr", true)
    socket:set_option("sndbuf", 65536)
    socket:set_option("rcvbuf", 65536)
	--socket:set_option("nodelay", 1)

	self.socket = socket

	return self
end

META:Register()

if RELOAD then
	if not WEBSOCKET_SERVER then
		local socket = sockets.CreateWebsocketServer()
		socket:Bind(nil, 8080)
		function socket:OnReceive(client, data)
			print(client, " sent ", data)
			--vfs.Write("wsock.wav", data)
		end
		WEBSOCKET_SERVER = socket
	end

	--local socket = sockets.CreateWebsocketClient()
	--socket:Connect("127.0.0.1", 8080)
	--socket:Send(vfs.Read("/home/caps/Downloads/254366__harrybates01__heartbeat-fast.wav"))

	local bsocket = require("bsocket")

	do -- server
		local server = assert(bsocket.bind(nil, 5001))
		server:set_blocking(false)

		server:set_option("reuseaddr", 1)
		server:set_option("sndbuf", 65536)
		server:set_option("rcvbuf", 65536)

		if jit.os == "OSX" then
			server:set_option("nodelay", 1)
		end

		assert(server:listen())

		system.OpenURL("http://127.0.0.1:5001")

		local body = [[<html><body><script>
			var ws = new WebSocket("ws://127.0.0.1:8080")
			ws.onopen = function() {
				ws.send("hello!!")
			}

			ws.onmessage = function (evt) {
				var received_msg = evt.data
				console.log(received_msg)
			}
		</script></body></html>]]

		local header =
		"[HTTP/1.1 200 OK\r\n"..
		"Server: masrv/0.1.0\r\n"..
		"Date: Thu, 28 Mar 2013 22:16:09 GMT\r\n"..
		"Content-Type: text/html\r\n"..
		"Connection: Keep-Alive\r\n"..
		"Content-Length: "..#body.."\r\n"..
		"Last-Modified: Wed, 21 Sep 2011 14:34:51 GMT\r\n"..
		"Accept-Ranges: bytes\r\n" ..
		"\r\n"

		local content = header .. body

		event.AddListener("Update", "test", function()
			local client, err = server:accept()
			if client then
				assert(client:set_blocking(false))
				assert(client:send(content))

				print("client connected ", client)

				local str, err = client:receive()

				if str then
					print(str)
					client:close()
				elseif
					err ~= "Resource temporarily unavailable" and
					err ~= "A non-blocking socket operation could not be completed immediately. (10035)"
				then
					print(err)
					client:close()
				end
			elseif
				err ~= "Resource temporarily unavailable" and
				err ~= "A non-blocking socket operation could not be completed immediately. (10035)"
			then
				error(err)
			end
		end)
	end
end