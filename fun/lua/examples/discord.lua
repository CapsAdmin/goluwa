local META = prototype.CreateTemplate("discord_bot")

function DiscordBot(token)
	local self = META:CreateObject()
	self.token = "Bot " .. token
	self:Initialize()
	return self
end

function META:Query(method, data, callback)
	local method, index = unpack(method:split(" "))

	if method == "WEBSOCKET" then
		self.socket:Send(serializer.Encode("json", data), 1)
	else
		if method == "GET" then
			callback, data = data, callback
		end

		sockets.Request({
			method = method,
			post_data = data and serializer.Encode("json", data) or nil,
			url = "https://discordapp.com/api" .. index,
			callback = function(data)
				local json = data.content:match("^.-\r\n(.+)0") or data.content
				local ok, tbl = pcall(serializer.Decode, "json", json)
				if not ok then
					print(tbl)
					print(json)
				end
				if tbl.code == 0 then
					print(tbl.message)
				end
				callback(tbl)
			end,
			user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
			header = {
				["Content-Type"] = data and "application/json" or nil,
				Authorization = self.token,
			},
		})
	end
end

function META:Initialize()
	self:Query("GET /gateway/bot", function(data)

		local bot = self
		local socket = sockets.CreateWebsocketClient()
		socket:Connect(data.url .. "/?v=6", "wss", {mode = "client", protocol = "sslv23", options = {"all"}})
		self.socket = socket

		function socket:Heartbeat()
			bot:Query("WEBSOCKET", {
				op = 1,
				d = self.last_sequence or 0,
			})
		end

		bot:Query("WEBSOCKET", {
			op = 2,
			d = {
				token = bot.token,
				properties = {
					["$os"] = jit.os,
					["$browser"] = "goluwa",
					["$device"] = "goluwa",
					["$referrer"] = "",
					["$referring_domain"] = "",
				},
				compress = false,
				large_threshold = 100,
				shard = {0,1},
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

		function socket:OnReceive(message, err, partial)
			local data = serializer.Decode("json", message)

			data.opcode = opcodes[data.op]
			data.op = nil

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

			if data.t then
				bot:OnEvent(data)
			end
		end

		function socket:OnClose(reason, code)
			logf("closing discord socket: %s (%s)\n", reason, code)
			self:Remove()
		end
	end)
end

function META:OnRemove()
	event.RemoveTimer("discord_heartbeat")
	self.socket:Remove()
end

--[[
http("GET", "/channels/260911858133762048/messages", function(messages)
	for k,v in pairs(messages) do
		print(v.author.username, v.content)
	end
end, {limit = 1,})
http("GET", "/channels/260911858133762048", table.print)

do return end
]]

META:Register()

if RELOAD then
	if LOL then LOL:Remove() end
	LOL = DiscordBot(assert(vfs.Read("discord_bot_token")))

	function LOL:OnEvent(data)
		if data.t == "READY" then
			self:Query("POST /channels/348586142423187466/messages", {
				content = "hello",
			}, table.print)

			self:Query("GET /channels/348586142423187466/messages", function(messages)
				for k,v in pairs(messages) do
					print(v.author.username, v.content)
				end
			end, {limit = 1})

			self:Query("GET /guilds/348586142423187466/members", function(data)
				table.print(data)
			end, {limit = 10})
		else
			--table.print(data)
		end
	end
end