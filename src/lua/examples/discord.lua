local base = "https://discordapp.com/api"
local token = "Bot " .. vfs.Read("discord_bot_token")

local function okay(what, callback)
	sockets.Request({
		method = "GET",
		url = base .. what,
		callback = function(data) callback(serializer.Decode("json", data.content)) end,
		user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
		ssl_parameters = {
			protocol = "tlsv1_2",
		},
		header = {
			Authorization = token,
		},
	})
end

okay("/gateway/bot", function(data)
	if DISCORD_SOCKET then DISCORD_SOCKET:Remove() end

	local socket = sockets.CreateWebsocketClient()
	socket.socket.debug = true
	socket:Connect(data.url .. "/?v=6")

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