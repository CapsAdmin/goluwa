local message = _G.message or {}

-- "-1" is a reserved id
local packet_id = -1

message.listeners = message.listeners or {}

function message.AddListener(id, callback)
	message.listeners[id] = callback
end

function message.RemoveListener(id)
	message.listeners[id] = callback
end

if CLIENT then
	function message.Send(id, ...)
		local buffer = Buffer()
		
		buffer:WriteString(id)
		buffer:WriteTable({...}, typex)
				
		packet.Send(packet_id, buffer, "reliable")
	end
	
	function message.OnMessageReceived(buffer)
		local id = buffer:ReadString()
		local args = buffer:TheEnd() and {} or buffer:ReadTable()

		if message.listeners[id] then
			message.listeners[id](unpack(args))
		end
	end

	packet.AddListener(packet_id, message.OnMessageReceived)
end

if SERVER then
	function message.Send(id, filter, ...)		
		local buffer = Buffer()
		
		buffer:WriteString(id)
		buffer:WriteTable({...}, typex)
		
		packet.Send(packet_id, buffer, filter, "reliable")
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnMessageReceived(buffer, client)
		local id = buffer:ReadString()
		local args = buffer:TheEnd() and {} or buffer:ReadTable()

		if message.listeners[id] then
			message.listeners[id](client, unpack(args))
		end
	end
	
	packet.AddListener(packet_id, message.OnMessageReceived)
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
		
		function event.CallShared(event, ...)
			_G.event.Call(event, ...)
			_G.event.BroadcastCall(event, ...)
		end
	end
end

packet.ExtendBuffer(
	"Null", 
	function(buffer, client) 
		buffer:WriteByte(0)
	end,
	function(buffer) 
		buffer:ReadByte()
		return NULL
	end
)

return message