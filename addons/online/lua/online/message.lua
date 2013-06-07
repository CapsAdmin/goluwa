message = message or {}

message.Listeners = message.Listeners or {}

function message.AddListener(tag, callback)
	message.Listeners[tag] = callback
end

if CLIENT then
	function message.Send(id, ...)
		network.SendToServer(e.USER_MESSAGE, id, ...)
	end
	
	function message.OnPlayerMessage(id, ...)		
		if message.Listeners[id] then
			message.Listeners[id](...)
		end
	end

	event.AddListener("OnPlayerMessage", "message", message.OnPlayerMessage, print)
end

if SERVER then
	function message.Send(id, filter, ...)		
		if typex(filter) == "player" then
			network.SendToClient(filter.socket, e.USER_MESSAGE, id, ...)
		elseif typex(filter) == "netmsg_user_filter" then
			for _, player in pairs(filter:GetAll()) do
				network.SendToClient(player.socket, e.USER_MESSAGE, id, ...)
			end
		else
			for key, ply in pairs(users.GetAll()) do
				network.SendToClient(ply.socket, e.USER_MESSAGE, id, ...)
			end
		end
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnPlayerMessage(ply, id, ...)
		if message.Listeners[id] then
			message.Listeners[id](ply, ...)
		end
	end
	
	event.AddListener("OnPlayerMessage", "message", message.OnPlayerMessage, print)
end

do -- filter
	local META = {}
	META.__index = META

	META.users = {}
	META.Type = "netmsg_user_filter"

	function META:AddAll()
		for key, ply in pairs(users.GetAll()) do
			self.users[ply:GetUniqueID()] = ply
		end

		return self
	end

	function META:AddAllExcept(ply)
		self:AddAll()
		self.users[ply:GetUniqueID()] = nil

		return self
	end

	function META:Add(ply)
		self.users[ply:GetUniqueID()] = ply

		return self
	end

	function META:Remove(ply)
		self.users[ply:GetUniqueID()] = nil

		return self
	end

	function META:GetAll()
		return self.users
	end

	function message.PlayerFilter()
		return setmetatable({}, META)
	end
end