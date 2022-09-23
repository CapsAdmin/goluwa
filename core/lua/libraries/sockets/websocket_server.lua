local sockets = ... or _G.sockets
local frame = require("websocket.frame")
local META = prototype.CreateTemplate("socket", "websocket_server")
META.Base = "tcp_server"

local function header_to_table(header)
	local tbl = {}

	if not header then return tbl end

	for _, line in ipairs(header:split("\n")) do
		local key, value = line:match("(.+):%s+(.+)\r")

		if key and value then tbl[key:lower()] = tonumber(value) or value end
	end

	return tbl
end

function META:OnClientConnected(client)
	sockets.ConnectedTCP2HTTP(client)

	function client.OnReceiveHeader(client, headers)
		self:Respond(
			"101 Switching Protocols",
			{
				["Upgrade"] = "websocket",
				["Connection"] = headers["connection"],
				["Sec-WebSocket-Accept"] = crypto.Base64Encode(crypto.SHA1(headers["sec-websocket-key"] .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")),
			}
		)

		function client.OnReceiveChunk(client, str)
			local first_opcode
			local frames = {}
			local encoded = str

			if client.last_encoded then
				encoded = client.last_encoded .. str
				client.last_encoded = nil
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
							client:Send(encoded)
							client:OnClose(reason, code)
							client:Remove()
							return
						else
							frames = {}
							client:OnMessage(message, opcode)
							self:OnMessage(client, message, opcode)
						end
					end
				elseif #encoded > 0 then
					client.last_encoded = encoded
				end			
			until not decoded
		end

		function client:OnMessage(message, opcode) end

		function client:SendMessage(data, opcode)
			self:Send(frame.encode(data, opcode))
		end
	end
end

META:Register()

function sockets.WebSocketServer(socket)
	local self = META:CreateObject()
	self:Initialize(socket)
	self.Clients = {}
	return self
end

if RELOAD then
	local http_port = 1235
	local ws_port = 9998
	local ws_server = utility.RemoveOldObject(sockets.WebSocketServer(), "ws_server")
	local http_server = utility.RemoveOldObject(sockets.HTTPServer(), "http_server")
	ws_server:Host("*", ws_port)
	http_server:Host("*", http_port)

	function ws_server:OnMessage(client, msg, opcode)
		print("MESSAGE", msg, opcode)
		--event.AddListener("Update", "", function()
		client:SendMessage(body)
	--end)
	end

	function http_server:OnReceiveHeader(client, header)
		client:Respond(
			"200 OK",
			nil,
			[[
            <!DOCTYPE HTML>
            <html>
                <meta charset="utf-8"/>
                <script type = "text/javascript">
                    let ws = new WebSocket("ws://localhost:9998");

                    function listen(obj, what) {
                        let old = obj[what]
                        console.log(old, "!!")
                        obj[what] = function(...args) {
                            if (old) {
                                old.apply(this, ...args)
                            }
                            console.log.apply(this, [what, ": ", ...args])
                        }
                    }

                    ws.onopen = function() {
                        ws.send("hello")
                    }

                    listen(ws, "onopen")
                    listen(ws, "onmessage")
                    listen(ws, "onerror")
                    listen(ws, "onclose")

                    window.ws_ref =ws
                </script>
            </html>
            ]]
		)
	end
end