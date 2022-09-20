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
		local buffer = packet.CreateBuffer()
		buffer:WriteString(id)
		buffer:WriteTable({...}, typex)
		packet.Send(packet_id, buffer, "reliable")
	end

	function message.OnMessageReceived(buffer)
		local id = buffer:ReadString()
		local args = buffer:TheEnd() and {} or buffer:ReadTable()

		for _, v in pairs(args) do
			if type(v) == "table" and type(v.IsValid) == "function" then
				if not v:IsValid() then
					llog("%q message from server contains NULL value", id)
					table.print(args)
					return
				end
			end
		end

		if message.listeners[id] then message.listeners[id](unpack(args)) end
	end

	packet.AddListener(packet_id, message.OnMessageReceived)
end

if SERVER then
	function message.Send(id, filter, ...)
		local buffer = packet.CreateBuffer()
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

	function commands.SetClient(client)
		commands.current_client = client or NULL
	end

	function commands.GetClient()
		return commands.current_client
	end

	if SERVER then
		message.AddListener("scmd", function(client, cmd, ...)
			local callback = message.server_commands[cmd]

			if callback then callback(client, ...) end
		end)
	end

	function commands.AddServerCommand(command, callback)
		message.server_commands[command] = callback

		if CLIENT then
			commands.Add(command, function(...)
				message.Send("scmd", command, ...)
			end)
		end

		if SERVER then
			commands.Add(command, function(...)
				callback(client, ...)
			end)
		end
	end

	function commands.RemoveServerCommand(command)
		commands.Remove(command)
		message.server_commands[command] = nil
	end
end

do -- event extension
	if CLIENT then
		message.AddListener("evtmsg", function(...)
			for i = 1, select("#", ...) do
				local v = select(i, ...)

				if type(v) == "table" and type(v.IsValid) == "function" then
					if not v:IsValid() then
						llog("event.CallShared: event message from server contains NULL value")

						for i = 1, select("#", ...) do
							local v = select(i, ...)
							print(i, v)
						end

						return true
					end
				end
			end

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

packet.ExtendBuffer("Null", function(buffer, client)
	buffer:WriteByte(0)
end, function(buffer)
	buffer:ReadByte()
	return NULL
end)

if CLIENT then
	function network.PrintOnServer(str)
		message.Send("network_print_on_server", str)
	end
end

if SERVER then
	message.AddListener("network_print_on_server", function(client, str)
		logf("%s: %s\n", client, str)
	end)
end

return message