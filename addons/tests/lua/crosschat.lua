crosschat = {}
local crosschat = crosschat

crosschat.servers = {}
crosschat.players = {}

function crosschat.subscribe(address)
	local host, port = address:match("^(.+):(%d+)$")

	if not port then
		host = address
		port = 37477
	end

	crosschat.servers[address] = {
		host = host,
		port = port,
		online = false
	}

	print(string.format("added crosschat server %q", address))
end

function crosschat.unsubscribe(address)
	crosschat.servers[address] = nil
end

function crosschat.update()
	for k, v in pairs(crosschat.servers) do
		if v.socket then
			local data, error = v.socket:receive()

			if error == "closed" then
				print("receive(): " .. error)
				v.online = false
				v.socket = nil
			end

			if data then
				v.online = true
				print(data)
			end
		else
			v.socket = socket.tcp()
			v.socket:settimeout(0)
			v.socket:connect(v.host, v.port)
		end
	end
end

crosschat.subscribe("88.191.102.162")
crosschat.subscribe("88.191.109.120")

event.AddListener("OnUpdate", "crosschat", crosschat.update)
