console.CreateVariable("sv_timeout", 30)	

local META = (...) or metatable.Get("client")

nvars.GetSet(META, "Ping", 0)
	
function META:GetTimeout()
	if not self.socket:IsValid() then
		return 0
	end
	
	return self.last_ping and (os.clock() - self.last_ping)
end

function META:IsTimingOut() 
	if not self.socket:IsValid() then
		return false
	end

	return self:GetTimeout() > console.GetVariable("sv_timeout")
end

if CLIENT then
	message.AddListener("ping", function(...)
		message.Send("pong", ...)
		
		clients.GetLocalClient().last_ping = os.clock()
	end)
end

if SERVER then			
	message.AddListener("pong", function(client, time)
		local ms = (os.clock() - tonumber(time)) * 100
		
		client:SetPing(ms)
		client.last_ping = os.clock()
	end)
end		

event.CreateTimer("ping_pong_clients", 1, 0, function()
	if not network.IsStarted() then return end
	
	if SERVER then
		for key, client in pairs(clients.GetAll()) do			
			message.Send("ping", client, tostring(os.clock()))
			
			if client:IsTimingOut() then			
				client:Kick("timeout")
			end
		end
	end
	
	if CLIENT then
		local client = clients.GetLocalClient()
		
		if client:IsTimingOut() then
			logn("timing out from server..")
			
			if client:IsTimingOut() then
				network.Disconnect("timed out")
			end
		end
	end
end)