local message = _G.message or {}

message.serializer_types = message.serializer_types or {}

local packet_id = -1

local function encode(...)
	local out = {}
	
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		
		local t = typex(v)
		local func = message.serializer_types[t]
		
		if func then			
			out[i] = {"msgpo", t, func(v, true)}
		else
			out[i] = v
		end
	end
	
	return serializer.Encode("msgpack", out)
end

local function decode(args)
	args = serializer.Decode("msgpack", args)
	
	for k, v in pairs(args) do
		if type(v) == "table" then
			if v[1] == "msgpo" and message.serializer_types[v[2]] then
				if v[3] then
					args[k] = message.serializer_types[v[2]](v[3], false)
				else
					args[k] = nil
				end
			end
		end
	end
	
	return unpack(args)
end

function message.AddEncodeDecodeType(type, callback)
	message.serializer_types[type] = callback
end

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
		buffer:WriteString2(encode(...))
				
		packet.Send(packet_id, buffer)
	end
	
	function message.OnMessageReceived(buffer)
		local id = buffer:ReadString()
				
		if message.listeners[id] then
			message.listeners[id](decode(buffer:ReadString2()))
		end
	end

	packet.AddListener(packet_id, message.OnMessageReceived)
end

if SERVER then
	function message.Send(id, filter, ...)		
		local buffer = Buffer()
		
		buffer:WriteString(id)
		buffer:WriteString2(encode(...))
		
		packet.Send(packet_id, buffer, filter)
	end
	
	function message.Broadcast(id, ...)
		return message.Send(id, nil, ...)
	end
	
	function message.OnMessageReceived(buffer, client)
		local id = buffer:ReadString()
				
		if message.listeners[id] then
			message.listeners[id](client, decode(buffer:ReadString2()))
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

message.AddEncodeDecodeType("null", function(var, encode) 
	if encode then
		return 0
	else
		return NULL
	end
end)

return message