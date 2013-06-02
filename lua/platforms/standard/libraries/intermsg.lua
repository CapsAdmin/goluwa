local intermsg = _G.intermsg or {}

local event_call = hook and hook.Run or event.Call

intermsg.client_sockets = intermsg.client_sockets or {udp = {}, tcp = {}}
intermsg.server_socket = intermsg.server_socket or {udp = NULL, tcp = NULL}

function intermsg.Panic()
	if intermsg.server_socket.udp:IsValid() then
		intermsg.server_socket.udp:Remove()
	end

	if intermsg.server_socket.tcp:IsValid() then
		intermsg.server_socket.tcp:Remove()
	end

	for typ, sockets in pairs(intermsg.client_sockets) do
		for ip_part, sck in pairs(sockets) do
			if sck:IsValid() then
				sck:Remove()
			end
		end
	end

	intermsg.client_sockets = {udp = {}, tcp = {}}
	intermsg.server_socket = {udp = NULL, tcp = NULL}
end

function intermsg.Send(ip, port, str, typ)
	typ = typ and "udp" or "tcp"

	local sck = intermsg.client_sockets[typ][ip..port] or NULL
	
	if not sck:IsValid() then
		sck = luasocket.Client(typ)

		sck:SetTimeout()
		sck:Connect(ip, port)
	end

	sck:Send(str .. "\n")

	intermsg.client_sockets[typ][ip..port] = sck
end

function intermsg.Host(ip, port, typ)
	typ = typ and "udp" or "tcp"

	local sck = intermsg.server_socket[typ] or NULL

	if sck:IsValid() then sck:Remove() end

	sck = luasocket.Server(typ)
	sck:Host(ip, port)

	function sck:OnClientConnected(client, ip, port)
		local b = event_call("IntermsgAcceptClient", ip, port, client)
		
		if client.SetReceiveMode then
			client:SetReceiveMode("line")
		end
		
		if b ~= nil then
			return b
		end
		
		return true
	end

	function sck:OnReceive(str, client)
		local b = event_call("IntermsgReceiveMessage", client:GetIP(), client:GetPort(), str, client)

		if b ~= nil then
			return b
		end
	end

	intermsg.server_socket[typ] = sck
end

intermsg.Panic()

if gmod then
	_G.intermsg = intermsg
end

return intermsg