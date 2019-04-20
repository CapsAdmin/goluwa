local server_id = "260866188962168832"
local channel_id = "568745482407641099"

local ffi = require("ffi")
local CHANNELS = 2
local SAMPLE_RATE = 48000 -- Hz
local FRAME_DURATION = 20 -- ms
local COMPLEXITY = 5

local MIN_BITRATE = 8000 -- bps
local MAX_BITRATE = 128000 -- bps
local MIN_COMPLEXITY = 0
local MAX_COMPLEXITY = 10

local MAX_SEQUENCE = 0xFFFF
local MAX_TIMESTAMP = 0xFFFFFFFF

local PADDING = string.rep('\0', 12)

local sodium = require("sodium")
local opus = require("opus")

local encoder = opus.Encoder(SAMPLE_RATE, CHANNELS)

encoder:set(opus.SET_COMPLEXITY_REQUEST, COMPLEXITY)
encoder:set(opus.SET_BITRATE_REQUEST, 64000)

local bit_rshift = bit.rshift
local bit_lshift = bit.lshift
local bit_bor = bit.bor
local bit_band = bit.band

local function swap_endian(num, size)
	local result = 0
	for shift = 0, (size * 8) - 8, 8 do
		result = bit_bor(bit_lshift(result, 8), bit_band(bit_rshift(num, shift), 0xff))
	end
	return result
end

local function start_noise(self)
	local frame_size = SAMPLE_RATE * FRAME_DURATION / 1000
	local pcm_len = frame_size * CHANNELS
	local elapsed = 0
	local start = system.GetTime()

	self.sample = 0
	self.time = 0



	local mic = audio.CreateAudioCapture()
	mic:Start()

	event.AddListener("Update", "noise_voice", function()

		local pcm, pcm_len = audio.ReadLoopbackOutput(frame_size*2)

		local data, len = encoder:encode(pcm, pcm_len, pcm_len * 2)

		if not data then
			print('could not encode audio data')
			event.RemoveListener("Update", "noise_voice")
			return
		end

		local s, t = self.sample, self.time

		local buf = utility.CreateBuffer()
		buf:WriteByte(0x80)
		buf:WriteByte(0x78)
		buf:WriteInt16_T(swap_endian(s, 2))
		buf:WriteInt32_T(swap_endian(t, 4))
		buf:WriteInt32_T(swap_endian(self.ssrc, 4))
		local header = buf:GetString()

		s = s + 1
		t = t + pcm_len

		self.sample = s > MAX_SEQUENCE and 0 or s
		self.time = t > MAX_TIMESTAMP and 0 or t

		local encrypted, encrypted_len = sodium.encrypt(data, len, header .. PADDING, self.key)

		if not encrypted then
			print('could not encrypt audio data')
			event.RemoveListener("Update", "noise_voice")
			return
		end

		local packet = header .. ffi.string(encrypted, encrypted_len)
		self.udp:Send(packet, self.ip, self.port)

	--	elapsed = elapsed + FRAME_DURATION/1000
	--	local delay = elapsed - (system.GetTime() - start)
	--	event.Delay(delay, encode)
	end)
	--encode()
end

local META = prototype.CreateTemplate("discord_bot")

function DiscordBot(token)
	local self = META:CreateObject()
	self.token = "Bot " .. token
	self:Initialize()

	self.api = http.CreateAPI("https://discordapp.com/api/", {
		Authorization = self.token,
		["Content-Type"] = "application/json",
	})

	return self
end




local multipart_boundary = "Goluwa" .. os.time()
local multipart = string.format('multipart/form-data; boundary=%s', boundary)

function META:Query(method, data, callback, files)
	local input_method = method
	local method, index = unpack(method:split(" "))

	if method == "WEBSOCKET" then
		self.socket:Send(serializer.Encode("json", data), 1)
	else
		if method == "GET" then
			callback, data = data, callback
		end

		local input_data = data

		local function finished(data)
			if data.code ~= 200 then
				table.print(input_data)
				print(input_method, input_data, callback, files)
				print(data.body)
				return
			end
			local json = data.body:match("^.-\r\n(.+)0") or data.body
			local ok, tbl = pcall(serializer.Decode, "json", json)

			if not ok then
				print(tbl)
				print(json)
			end

			if tbl.code == 0 then
				table.print(input_data)
				print(input_method, tbl.message)
				return
			end

			if callback then
				callback(tbl)
			end
		end

		if files then
			local tbl = {}

			table.insert(tbl, {
				name = "payload_json",
				type = "application/json",
				data = serializer.Encode("json", data),
			})

			for i, v in ipairs(files) do
				table.insert(tbl, {
					name = "file" .. i,
					type = "application/octet-stream",
					filename = v.name,
					data = v.data,
				})
			end

			sockets.Request({
				files = tbl,
				method = method,
				url = "https://discordapp.com/api" .. index,
				callback = finished,
				user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
				header = {
					Authorization = self.token,
				},
			})
		else
			if method == "GET" then
				local query = ""

				if data then
					query = "?"
					for k, v in pairs(data) do
						query = query .. k .. "=" .. v .. "&"
					end
					if query:endswith("&") then
						query = query:sub(0,-2)
					end
					print(method, "https://discordapp.com/api" .. index .. query)
				end
				sockets.Request({
					method = method,
					url = "https://discordapp.com/api" .. index .. query,
					callback = finished,
					user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
					header = {
						["Content-Type"] = data and "application/json" or nil,
						Authorization = self.token,
					},
				})
			else
				sockets.Request({
					method = method,
					post_data = data and serializer.Encode("json", data) or nil,
					url = "https://discordapp.com/api" .. index,
					callback = finished,
					user_agent = "DiscordBot (https://github.com/CapsAdmin/goluwa, 0)",
					header = {
						["Content-Type"] = data and "application/json" or nil,
						Authorization = self.token,
					},
				})
			end
		end
	end
end

function META:Initialize()
	local socket = sockets.CreateWebsocketClient()
	self.socket = socket
	self:Query("GET /gateway/bot", function(data)

		local bot = self
		socket:Connect(data.url .. "/?v=6", "wss")

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

			if data.opcode == "Identify" then
				table.print(data)
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
	if not LOL then
		--LOL:Remove()
		LOL = DiscordBot(assert(vfs.Read("temp/discord_bot_token")))
	end

	function LOL:OnEvent(data)
		if data.t == "VOICE_SERVER_UPDATE" then
			self.voice_server = data
		elseif data.t == "VOICE_STATE_UPDATE" then
			self.voice_state = data
		end

		if self.voice_server and self.voice_state then
			if not self.voice_socket then
				local socket = sockets.CreateWebsocketClient()
				self.voice_socket = socket

				local voice_server = self.voice_server
				local voice_state = self.voice_state

				local host, port = unpack(self.voice_server.d.endpoint:split(":"))
				socket:Connect("wss://" .. host .. "/?v=3")
				socket:Send(serializer.Encode("json", {
					op = 0,
					d = {
						server_id = voice_server.d.guild_id,
						user_id = voice_state.d.user_id,
						session_id = voice_state.d.session_id,
						token = voice_server.d.token,
					}
				}), 1)

				local opcodes = {
					[0] = "Identify", --	client	begin a voice websocket connection
					[1] = "Select Protocol", --	client	select the voice protocol
					[2] = "Ready", --	server	complete the websocket handshake
					[3] = "Heartbeat", --	client	keep the websocket connection alive
					[4] = "Session Description", --	server	describe the session
					[5] = "Speaking", --	client and server	indicate which users are speaking
					[6] = "Heartbeat ACK", --	server	sent immediately following a received client heartbeat
					[7] = "Resume", --	client	resume a connection
					[8] = "Hello", --	server	the continuous interval in milliseconds after which the client should send a heartbeat
					[9] = "Resumed", --	server	acknowledge Resume
					[13] = "Client Disconnect", --	server	a client has disconnected from the voice channel
				}

				function socket:Heartbeat()
					self:Send(serializer.Encode("json", {
						op = 3,
						d = math.ceil(1+os.clock()),
					}), 1)
				end
				function socket:OnReceive(message, err, partial)
					local data = serializer.Decode("json", message)

					data.opcode = opcodes[data.op]
					data.op = nil

					if data.opcode == "Hello" then
						self:Heartbeat()
						event.Timer("discord_heartbeat_voice", (data.d.heartbeat_interval * 0.75)/1000, function()
							if self:IsValid() then
								self:Heartbeat()
							end
						end)
					end

					if data.opcode == "Dispatch" then
						self.last_sequence = data.s
					end

					if data.opcode == "Ready" then
						self.ssrc = data.d.ssrc
						self.key = "?"
						self.ip = data.d.ip
						self.port = data.d.port

						local udp = sockets.UDPServer()

						udp:SetAddress(data.d.ip, data.d.port)

						function udp.OnReceiveChunk(_, chunk, address)
							local buf = utility.CreateBuffer(chunk)
							buf:Advance(4)
							local ip = buf:ReadString()
							buf:SetPosition(buf:GetSize()-2)
							local port = buf:ReadUInt16_T()

							self:Send(serializer.Encode("json", {
								op = 1,
								d = {
									protocol = "udp",
									data = {
										address = ip,
										port = port,
										mode = "xsalsa20_poly1305"
									}
								},
							}), 1)

							--self.ip = ip
							--self.port = port

							print(address:get_ip(), address:get_port())

							--udp:Remove()
						end

						udp:Send(string.rep("\0", 70))

						local udp = sockets.UDPClient()
						udp:SetAddress(data.d.ip, data.d.port)
						self.udp = udp
					end

					if data.opcode == "Session Description" then

						self:Send(serializer.Encode("json", {
							op = 5,
							d = {
								speaking = true,
								delay = 0,
								ssrc = data.d.ssrc,
							},
						}), 1)

						self.key = sodium.key(data.d.secret_key)
						start_noise(self)

						--[[event.Delay(4, function()
							self:Send(serializer.Encode("json", {
								op = 5,
								d = {
									speaking = false,
									delay = 0,
									ssrc = data.d.ssrc,
								},
							}), 1)
						end)]]
					end

					table.print(data)
				end
			end
		end

		if data.t == "READY" then
			--[[self.api.POST("channels/260911858133762048/messages", {
				body = {
					content = "hello"
				}
			}):Then(table.print)

			self.api.GET(http.query("channels/260911858133762048/messages", {limit = 10})):Then(function(messages)
				table.print(messages)
				for k,v in pairs(messages) do
					print(v.author.username, v.content)
				end
			end)
			]]

			self:Query("WEBSOCKET", {
				op = 4,
				d = {
					guild_id = server_id,
					channel_id = channel_id,
					self_mute = false,
					self_deaf = false
				}
			})

			--[[self:Query("GET /guilds/"..server_id.."/members", function(data)
				table.print(data)
			end, {limit = 10})]]
		else
			if data.t == "MESSAGE_CREATE" then
				chatsounds.Say(data.d.content)
			elseif data.t == "MESSAGE_UPDATE" then
				chatsounds.Say(data.d.content)
			elseif data.t ~= "PRESENCE_UPDATE" then
				table.print(data)
			end

			if data.t == "MESSAGE_CREATE" and data.d.author.id == "208633661787078657" then
				local str = data.d.content:match("^!l (.+)")
				if str then
					local func, err = loadstring(str)
					if func then
						local ok, err = pcall(func)
						if not ok then
							print(err)
						end
					end
				end

				if data.d.content:startswith("goluwa") then
					local ffi = require("ffi")
					local freeimage = require("freeimage")

					--[[
					-- setting avatar

					self:Query("PATCH /users/@me", {
						--username = "goluwa " .. os.clock(),
						--avatar = "data:image/png;base64," .. crypto.Base64Encode(ffi.string(freeimage.BufferToPNG(freeimage.LoadImage(vfs.Read("/home/caps/sfYru.jpg"))))),
						avatar = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAVUlEQVR42mNgGAXYwSOB/ySJo4PMDRb/STYcGeg58/zHZzheC9BtACl2KVL5j2w4PgvgBqyB2kJYAw7biNaE7ncMjUheArkqH8k7JLmIZO+QpWFoAgAY9DgM7ldwswAAAABJRU5ErkJggg==",
					}, table.print)
					]]



					-- anything over 31 kb will not send for some reason
					local w,h = render.GetWidth(), render.GetHeight()
					local pixels = ffi.new("uint8_t[?]", (w*h*4))
					require("opengl").ReadPixels(0,0,w,h,"GL_BGRA", "GL_UNSIGNED_BYTE", pixels)

					local image = {
						buffer = pixels,
						width = w,
						height = h,
						format = "rgba",
					}

					local png_data = freeimage.ImageToBuffer(image, "png")

					vfs.Write("lol.png", png_data)
					vfs.Write("lol.raw", ffi.string(pixels, w*h*4))

					self:Query("POST /channels/"..data.d.channel_id.."/messages", {
						content = "sending " .. utility.FormatFileSize(#png_data) .. " image\n" .. serializer.Encode("luadata", image),
					})

					self:Query("POST /channels/"..data.d.channel_id.."/messages", {
						file = {
							image = {
								url = "attachment://test.png",
								width = image.width,
								height = image.height,
							},
						}
					}, table.print, {
						{name = "test.png", data = png_data},
					})
				end
			end
			--table.print(data)
		end
	end

	--LOL:Query("GET /users/260465579125768192", table.print)
end