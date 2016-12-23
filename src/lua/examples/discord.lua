local base = "https://discordapp.com/api"
local token = "Bot " .. vfs.Read("discord_bot_token")

local function http(method, what, callback, data)
	sockets.Request({
		method = method,
		post_data = data and serializer.Encode("json", data) or nil,
		url = base .. what,
		callback = function(data)
			local json = data.content:match("^.-\r\n(.+)0") or data.content

			callback(serializer.Decode("json", json))
		end,
		user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
		ssl_parameters = {
			protocol = "tlsv1_2",
		},
		header = {
			["Content-Type"] = data and "application/json" or nil,
			Authorization = token,
		},
	})
end
--[[
http("GET", "/channels/260911858133762048/messages", function(messages)
	for k,v in pairs(messages) do
		print(v.author.username, v.content)
	end
end, {limit = 1,})
http("GET", "/channels/260911858133762048", table.print)
http("POST", "/channels/260911858133762048/messages", table.print, {
	content = "test",
	tts = true,
})]]
--do return end
http("GET", "/gateway/bot", function(data)
	if DISCORD_SOCKET then DISCORD_SOCKET:Remove() end

	local socket = sockets.CreateWebsocketClient()
	socket:Connect(data.url .. "/?v=6", "wss", {mode = "client", protocol = "sslv23", options = {"all"}})

	function socket:SendJSON(tbl)
		self:Send(serializer.Encode("json", tbl), 1)
	end

	function socket:Heartbeat()
		socket:SendJSON({
			op = 1,
			d = self.last_sequence or 0,
		})
	end

	socket:SendJSON({
		op = 2,
		d = {
			token = token,
			properties = {
				["$os"] = jit.os,
				["$browser"] = "goluwa",
				["$device"] = "goluwa",
				["$referrer"] = "",
				["$referring_domain"] = "",
			},
			compress = false,
			large_threshold = 100,
			shard = {1,10},
		},
	})

	local opcodes = {
		[0] = "Dispatch", -- dispatches an event
		[1] = "Heartbeat", -- used for ping checking
		[2] = "Identify", -- used for client handshake
		[3] = "Status Update", -- used to update the client status
		[4] = "Voice State Update", -- used to join/move/leave voice channels
		[5] = "Voice Server Ping", -- used for voice ping checking
		[6] = "Resume", -- used to resume a closed connection
		[7] = "Reconnect", -- used to tell clients to reconnect to the gateway
		[8] = "Request Guild Members", -- used to request guild members
		[9] = "Invalid Session", -- used to notify client they have an invalid session id
		[10] = "Hello", -- sent immediately after connecting, contains heartbeat and server debug information
		[11] = "Heartback ACK", -- sent immediately following a client heartbeat that was received
	}

	function socket:OnReceive(message)
		local data = serializer.Decode("json", message)
		data.opcode = opcodes[data.op]
		data.op = nil

		table.print(data)

		if data.opcode == "Dispatch" then
			self.last_sequence = data.s
		end

		if data.opcode == "Hello" then
			self:Heartbeat()
			event.Timer("discord_heartbeat", data.d.heartbeat_interval/1000, function()
				if self:IsValid() then
					self:Heartbeat()
				end
			end)
		end
	end

	function socket:OnClose(reason, code)
		logf("closing discord socket: %s (%s)\n", reason, code)
		event.RemoveTimer("discord_heartbeat")
	end

	DISCORD_SOCKET = socket
end)