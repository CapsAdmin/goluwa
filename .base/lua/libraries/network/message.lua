local message = _G.message or {}

message.Listeners = message.Listeners or {}

function message.AddListener(id, callback)
	message.Listeners[id] = callback
end

function message.RemoveListener(id)
	message.Listeners[id] = callback
end

if CLIENT then
	function message.Send(id, ...)
		network.SendMessageToServer(network.MESSAGE, id, ...)
	end
	
	function message.OnMessageReceived(id, ...)		
		if message.Listeners[id] then
			message.Listeners[id](...)
		end
	end

	event.AddListener("NetworkMessageReceived", "message", message.OnMessageReceived, {on_error = system.OnError})
end

if SERVER then
	function message.Send(id, filter, ...)		
		if typex(filter) == "client" then
			network.SendMessageToClient(filter.socket, network.MESSAGE, id, ...)
		elseif typex(filter) == "client_filter" then
			for _, client in pairs(filter:GetAll()) do
				network.SendMessageToClient(client.socket, network.MESSAGE, id, ...)
			end
		else
			for key, client in pairs(clients.GetAll()) do
				network.SendMessageToClient(client.socket, network.MESSAGE, id, ...)
			end
		end
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnMessageReceived(client, id, ...)
		if message.Listeners[id] then
			message.Listeners[id](client, ...)
		end
	end
	
	event.AddListener("NetworkMessageReceived", "message", message.OnMessageReceived, {on_error = system.OnError})
end

do -- console extension
	message.server_commands = message.server_commands or {}
	
	local client = NULL
	
	function console.SetClient(client)
		client = client or NULL
	end
	
	function console.GetClient()
		return client
	end
	
	if SERVER then
		message.AddListener("scmd", function(client, cmd, line, ...)
			local callback = message.server_commands[cmd]
			
			if callback then
				callback(client, line, ...)
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
				callback(client, line, ...)
			end)
		end
	end
	
	function console.RemoveServerCommand(command)
		console.RemoveCommand(command)
		message.server_commands[command] = nil
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

return message