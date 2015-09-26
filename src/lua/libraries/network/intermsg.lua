local intermsg = _G.intermsg or {}

intermsg.client_sockets = intermsg.client_sockets or {udp = {}, tcp = {}}
intermsg.server_sockets = intermsg.server_sockets or {udp = {}, tcp = {}}

function intermsg.Panic()
	for typ, sockets in pairs(intermsg.client_sockets) do
		for ip_part, sck in pairs(sockets) do
			if sck:IsValid() then
				sck:Remove()
			end
		end
	end

	for typ, sockets in pairs(intermsg.server_sockets) do
		for ip_part, sck in pairs(sockets) do
			if sck:IsValid() then
				sck:Remove()
			end
		end
	end

	intermsg.client_sockets = {udp = {}, tcp = {}}
	intermsg.server_sockets = {udp = {}, tcp = {}}
end

function intermsg.Send(ip, port, str, typ)
	typ = typ and "udp" or "tcp"

	local sck = intermsg.client_sockets[typ][ip..port] or NULL

	if not sck:IsValid() then
		sck = sockets.CreateClient(typ)

		sck:SetTimeout()
		sck:Connect(ip, port, true)
	end

	sck:Send(str)

	intermsg.client_sockets[typ][ip..port] = sck
end

function intermsg.CloseClient(ip, port, typ)
	typ = typ and "udp" or "tcp"
	local sck = intermsg.client_sockets[typ][ip..port] or NULL

	if sck:IsValid() then
		sck:Remove()
	end
end

function intermsg.StartServer(ip, port, callback, typ)
	typ = typ and "udp" or "tcp"

	local sck = intermsg.server_sockets[typ][ip..port] or NULL

	if sck:IsValid() then sck:Remove() end

	sck = sockets.CreateServer(typ)
	sck:Host(ip, port)

	function sck:OnClientConnected(client, ip, port)
		local b = callback("connect", ip, port, client, self)

		if client.SetReceiveMode then
			client:SetReceiveMode("all")
		end

		if b ~= nil then
			return b
		end

		return true
	end

	function sck:OnReceive(str, client)
		local b = callback("message", client:GetIP(), client:GetPort(), str, client, self)

		if b ~= nil then
			return b
		end
	end

	intermsg.server_sockets[typ][ip..port] = sck
end

function intermsg.StopServer(ip, port, typ)
	typ = typ and "udp" or "tcp"

	local sck = intermsg.server_sockets[typ][ip..port] or NULL

	if sck:IsValid() then
		sck:Remove()
	end
end

return intermsg