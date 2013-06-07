message = message or {}

message.Hooks = message.Hooks or {}

function message.Hook(tag, callback)
	message.Hooks[tag] = callback
end

if CLIENT then
	function message.Send(id, ...)
		network.SendToServer(e.USER_MESSAGE, id, ...)
	end
	
	function message.OnUserMessage(id, ...)		
		if message.Hooks[id] then
			message.Hooks[id](...)
		end
	end

	event.AddListener("OnUserMessage", "message", message.OnUserMessage, print)
end

if SERVER then
	function message.Send(id, filter, ...)		
		if typex(filter) == "user" then
			network.SendToClient(filter.socket, e.USER_MESSAGE, id, ...)
		elseif typex(filter) == "netmsg_user_filter" then
			for _, user in pairs(filter:GetPlayers()) do
				network.SendToClient(usr.socket, e.USER_MESSAGE, id, ...)
			end
		else
			for key, usr in pairs(users.GetAll()) do
				network.SendToClient(usr.socket, e.USER_MESSAGE, id, ...)
			end
		end
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnUserMessage(usr, id, ...)						
		if message.Hooks[id] then
			message.Hooks[id](usr, ...)
		end
	end
	
	event.AddListener("OnUserMessage", "message", message.OnUserMessage, print)
end