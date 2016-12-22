local base = "https://discordapp.com/api"
local token = vfs.Read("discord_bot_token")

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
			Authorization = "Bot " .. token,
		},
	})
end

okay("/gateway/bot", function(data)
	local socket = sockets.CreateWebsocketClient()
	socket.socket.debug = true
	socket.socket:SetTimeout()
	socket:Connect(data.url .. "/?v=6")

	socket:Send(serializer.Encode("json", {
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
	}))
	socket:Send(serializer.Encode("json", {
		op = 1,
		d = os.time(),
	}))

	function socket:OnReceive(message, opcode)
		local data = serializer.Decode("json", message)

		print(opcode)
		table.print(data)

		if data.op ==  10 then

			event.Timer("discord_heartbeat", data.d.heartbeat_interval/1000, function()
				if self:IsValid() then
					self:Send(serializer.Encode("json", {
						op = 1,
						d = os.time(),
					}))
				end
			end)
		end
	end

	function socket:OnClose(reason, code)
		print(reason, code)
	end
end)