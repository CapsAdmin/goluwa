Most of these functions can be called at any time. Send queues what you send until a connection is made.

Only "tcp" and "udp" is supported. Default is tcp. There isn't much of a difference between udp and tcp in this wrapper so you can easily change between the two modes.

By default the socket has a 3 second timeout. The timeout count is started/restarted whenever the mesage is "timeout" and stopped otherwise

luasocket.debug = true
	will logn debug messages about sending and receiving data
	very useful for (duh) debugging!

-- client

	CLIENT = luasocket.CreateClient("udp" or "tcp") -- this defaults to tcp

	CLIENT:GetTimeoutDuration()

	CLIENT:IsTimingOut()
	CLIENT:IsSending()
	CLIENT:IsConnected()

	CLIENT:SetTimeout(seconds or nil)
	CLIENT:GetTimeout()

	CLIENT:SetReceiveMode("line" or "all" or bytes)
	CLIENT:GetReceiveMode()
	
	CLIENT:OnReceive(str)

	-- return false to prevent the socket from being removed
	-- if the timeout duration has exceeded the max timeout duration

	CLIENT:OnTimeout(count)

	CLIENT:OnSend(str, bytes)
	CLIENT:OnError(msg)
	CLIENT:OnClose()

	CLIENT:Connect(ip, port)
--

-- server
	SERVER = luasocket.CreateServer("udp" or "tcp") -- this defaults to tcp

	SERVER:Host(ip, port)

	-- returning false here will close and remove the client
	-- returning true will call SetKeepAlive true on the client
	SERVER:OnClientConnected(client, ip, port)


	SERVER:OnReceive(str, client)
	SERVER:OnClientClosed(client)
	SERVER:OnClientError(client, msg)

	SERVER:GetClients()
	SERVER:HasClients() -- returns true if someone is connected, false otherwise
--

-- shared
	SHARED:Send(str, instant)
	SHARED:GetIP()
	SHARED:GetPort()

	SHARED:IsValid()
	SHARED:Remove()

	-- These have Get ones as well but they only return something if Set was called. This uses setoption.
	SHARED:SetReuseAddress(val)
	SHARED:SetNoDelay(val)
	SHARED:SetLinger(val)
	SHARED:SetKeepAlive(val)
--