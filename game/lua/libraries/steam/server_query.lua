local steam = ... or _G.steam

-- https://developer.valvesoftware.com/wiki/Server_queries

local queries = {
	info = {
		request = {
			{"byte", 0x54},
			{"string", "Source Engine Query"},
		},
		response = {
			{"byte", "Header", assert = 0x49}, -- Always equal to 'I' (0x49.)
			{"byte", "Protocol"}, -- Protocol version used by the server.
			{"string", "Name"}, -- Name of the server.
			{"string", "Map"}, -- Map the server has currently loaded.
			{"string", "Folder"}, -- Name of the folder containing the game files.
			{"string", "Game"}, -- Full name of the game.
			{"short", "ID"}, -- Steam Application ID of game.
			{"byte", "Clients"}, -- Number of clients on the server.
			{"byte", "MaxClients"}, -- Maximum number of clients the server reports it can hold.
			{"byte", "Bots"}, -- Number of bots on the server.
			{"char", "ServerType", translate = {d = "dedicated server", l = "non-dedicated server", p = "SourceTV relay (proxy)"}}, -- Indicates the type of server
			{"char", "Environment", translate = {l = "Linux", w = "Windows", m = "Mac", o = "Mac"}}, -- Indicates the operating system of the server
			{"boolean", "Visibility"}, -- Indicates whether the server requires a password
			{"boolean", "VAC"}, -- Specifies whether the server uses VAC

			-- the ship
			{"byte", "Mode", match = {ID = 2400}, translate =  {[0] = "Hunt", [1] = "Elimination", [2] = "Duel", [3] = "Deathmatch", [4] = "VIP Team", [5] = "Team Ellimination"}},
			{"byte", "Witnesses", match = {ID = 2400}, }, -- The number of witnesses necessary to have a player arrested.
			{"byte", "Duration", match = {ID = 2400}}, -- Time (in seconds) before a player is arrested while being witnessed

			{"string", "Version"}, -- Version of the game installed on the server.
			{"byte", "ExtraDataFlag"}, -- If present, this specifies which additional data fields will be included.

			{"short", "Port", match = {ExtraDataFlag = function(num) return bit.band(num, 0x80) end}}, -- The server's game port number.
			{"long", "SteamID", match = {ExtraDataFlag = function(num) return bit.band(num, 0x10) end}}, -- Server's SteamID.

			{"short", "Port", match = {ExtraDataFlag = function(num) return bit.band(num, 0x40) end}}, -- Spectator port number for SourceTV.
			{"string", "Name", match = {ExtraDataFlag = function(num) return bit.band(num, 0x20) end}}, -- Name of the spectator server for SourceTV.

			{"long", "Name", match = {ExtraDataFlag = function(num) return bit.band(num, 0x01) end}}, -- The server's 64-bit GameID. If this is present, a more accurate AppID is present in the low 24 bits. The earlier AppID could have been truncated as it was forced into 16-bit storage.
		}
	},
	clients = {
		challenge = true,
		request = {
			{"byte", 0x55},
			{"long", 0xFFFFFFFF},
		},
		response = {
			{"byte", "Header", assert = 0x44}, -- Always equal to 'D' (0x44.)
			{"byte", "Clients", {
				{"byte", "Index"}, -- Index of player chunk starting from 0.
				{"string", "Name"}, -- Name of the player.
				{"long", "Score"}, -- Client's score (usually "frags" or "kills".)
				{"float", "Duration"}, -- Time (in seconds) player has been connected to the server.
			}}, -- Number of clients whose information was gathered.
		}
	},
	rules = {
		challenge = true,
		request = {
			{"byte", 0x56},
			{"long", 0xFFFFFFFF},
		},
		response = {
			{"byte", "Header", assert = 0x45}, -- Always equal to 'E' (0x45.)
			{"short", "Rules", {
				{"string", "Name"},  -- Name of the rule
				{"string", "Value"},  -- Value of the rule.
			}}, -- Number of rules in the response.
		}
	},
	ping = {
		request = {
			{"byte", 0x69},
		},
		response = {
			{"byte", "Heading", assert = 0x6A}, -- Always equal to 'j' (0x6A)
			{"string", "Payload"}, -- '00000000000000'
		}
	},
}

local split_query = {
	response = {
		{"long", "ID"}, -- Same as the Goldsource server meaning. However, if the most significant bit is 1, then the response was compressed with bzip2 before being cut and sent. Refer to compression procedure below.
		{"byte", "Total"}, -- The total number of packets in the response.
		{"byte", "Number"}, -- The number of the packet. Starts at 0.
		{"short", "Size"}, -- (Orange Box Engine and above only.) Maximum size of packet before packet switching occurs. The default value is 1248 bytes (0x04E0), but the server administrator can decrease this. For older engine versions: the maximum and minimum size of the packet was unchangeable. AppIDs which are known not to contain this field: 215, 17550, 17700, and 240 when protocol = 7.
	}
}

local function query_server(ip, port, query, callback)
	callback = callback or table.print

	if not SOCKETS then return callback(nil, "sockets not avaible") end

	local socket = sockets.CreateClient("udp", ip, port)

	socket.debug = steam.debug

	-- more like on socket created
	function socket:OnConnect()
		local buffer = packet.CreateBuffer()
		buffer:WriteLong(0xFFFFFFFF)
		buffer:WriteStructure(query.request)

		if steam.debug then
			llog("sending %s to %s %i", buffer:GetDebugString(), ip, port)
		end

		socket:Send(buffer:GetString())
	end

	function socket:OnReceive(str)
		local buffer = packet.CreateBuffer(str)

		if steam.debug then
			llog("received %s to %s %i", buffer:GetDebugString(), ip, port)
		end

		local header = buffer:ReadLong()

		-- packet is split up
		if header == -2 then
			local info = buffer:ReadStructure(split_query.response)

			if not self.buffer_chunks then
				self.buffer_size = buffer:ReadLong()
				self.buffer_crc32_sum = buffer:ReadLong()

				self.buffer_chunks = {}
			end

			self.buffer_chunks[info.Number + 1] = buffer:ReadRest()

			if table.count(self.buffer_chunks) - 1 == info.Total then
				callback(packet.CreateBuffer(table.concat(self.buffer_chunks)):ReadStructure(query.response))
			end
		elseif header == -1 then
			if query.challenge and not self.challenge then
				local type = buffer:ReadByte()

				if type == 0x41 then
					local challenge = buffer:ReadLong()

					local buffer = packet.CreateBuffer()
					buffer:WriteLong(0xFFFFFFFF)
					buffer:WriteByte(query.request[1][2])
					buffer:WriteLong(challenge)

					if steam.debug then
						llog("sending challenge %s to %s %i", buffer:GetDebugString(), ip, port)
					end

					self:Send(buffer:GetString())

					self.challenge = challenge
				end
			else
				callback(buffer:ReadStructure(query.response))
			end
		else
			error("received unknown header " .. header)
		end
	end
end

function steam.GetServerInfo(ip, port, callback)
	query_server(ip, port, queries.info, callback)
end

function steam.GetServerClients(ip, port, callback)
	query_server(ip, port, queries.clients, callback)
end

function steam.GetServerRules(ip, port, callback)
	query_server(ip, port, queries.rules, callback)
end

function steam.GetServerPing(ip, port, callback)
	callback = callback or logn
	local start = system.GetElapsedTime()
	query_server(ip, port, queries.ping, function()
		callback(system.GetElapsedTime() - start)
	end)
end