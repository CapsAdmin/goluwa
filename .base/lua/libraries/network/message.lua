message = _G.message or {}

message.Listeners = message.Listeners or {}

function message.AddListener(tag, callback)
	message.Listeners[tag] = callback
end

if CLIENT then
	function message.Send(id, ...)
		network.SendToServer(network.MESSAGE, id, ...)
	end
	
	function message.OnUserMessage(id, ...)		
		if message.Listeners[id] then
			message.Listeners[id](...)
		end
	end

	event.AddListener("OnUserMessage", "message", message.OnUserMessage, print)
end

if SERVER then
	function message.Send(id, filter, ...)		
		if typex(filter) == "player" then
			network.SendToClient(filter.socket, network.MESSAGE, id, ...)
		elseif typex(filter) == "netmsg_user_filter" then
			for _, player in pairs(filter:GetAll()) do
				network.SendToClient(player.socket, network.MESSAGE, id, ...)
			end
		else
			for key, ply in pairs(players.GetAll()) do
				network.SendToClient(ply.socket, network.MESSAGE, id, ...)
			end
		end
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnUserMessage(ply, id, ...)
		if message.Listeners[id] then
			message.Listeners[id](ply, ...)
		end
	end
	
	event.AddListener("OnUserMessage", "message", message.OnUserMessage, print)
end

do -- console extension
	message.server_commands = message.server_commands or {}
	
	local player = NULL
	
	if SERVER then
		function console.SetServerPlayer(ply)
			player = ply or NULL
		end
		
		function console.GetServerPlayer()
			return player
		end
	end

	if SERVER then
		message.AddListener("scmd", function(ply, cmd, line, ...)
			local callback = message.server_commands[cmd]
			
			if callback then
				callback(ply, line, ...)
			end
		end)
	end

	function console.AddServerCommand(command, callback)
		message.server_commands[command] = callback
		
		if CLIENT then
			console.AddCommand(command, function(line, ...)
				message.Send("scmd", command, line, ...)
			end)
		end
		
		if SERVER then
			console.AddCommand(command, function(line, ...)
				callback(player, line, ...)
			end)
		end
	end
	
	function console.RemoveServerCommand(command)
		console.RemoveCommand(command)
		message.server_commands[command] = nil
	end

end

do -- filter
	local META = utilities.CreateBaseMeta("netmsg_user_filter")

	function META:AddAll()
		for key, ply in pairs(players.GetAll()) do
			self.players[ply:GetUniqueID()] = ply
		end

		return self
	end

	function META:AddAllExcept(ply)
		self:AddAll()
		self.players[ply:GetUniqueID()] = nil

		return self
	end

	function META:Add(ply)
		self.players[ply:GetUniqueID()] = ply

		return self
	end

	function META:Remove(ply)
		self.players[ply:GetUniqueID()] = nil

		return self
	end

	function META:GetAll()
		return self.players
	end

	function message.PlayerFilter()
		return META:New({players = {}})
	end
end

do -- event extension
	if CLIENT then
		message.AddListener("evtmsg", function(...)
			event.Call(...)
		end)
	end
	
	if SERVER then
		function event.CallOnClient(event, filter, ...)
			message.Send("evtmsg", filter, event, ...)
		end
		
		function event.BroadcastCall(event, ...)
			_G.event.CallOnClient(event, nil, ...)
		end
	end
end