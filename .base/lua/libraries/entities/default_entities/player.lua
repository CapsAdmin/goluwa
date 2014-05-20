local META = {}

META.ClassName = "player"
META.TypeX = "player"

META.socket = NULL

class.GetSet(META, "UniqueID", "???")
class.GetSet(META, "ID", -1)

nvars.IsSet(META, "Bot", false)
nvars.GetSet(META, "Nick", e.USERNAME, "cl_nick")

function META:GetNick()
	for key, ply in pairs(players.GetAll()) do
		if ply ~= self and ply.nv.Nick == self.nv.Nick then
			return ("%s(%i)"):format(self.nv.Nick, self.ID)
		end
	end
	
	return self.nv.Nick or "PubePurse"
end

function META:__tostring()
	return string.format("player[%s][%i]", self:GetName(), self:GetID())
end

function META:GetName()	
	return self.nv and self.nv.Nick or self:GetUniqueID()
end

function META:OnRemove()	
	self.nv:Remove()
	players.active_players[self:GetUniqueID()] = nil
	if SERVER then 
		if self.socket:IsValid() then
			self.socket:Remove()
		end
	end
end	

function META:GetUniqueColor()
	local r,g,b = tostring(crypto.CRC32(self:GetUniqueID())):match(("(%d%d%d)"):rep(3))
	local c = Color(tonumber(r), tonumber(g), tonumber(b))
	c:SetLightness(1)
	return c
end

if SERVER then
	function META:Kick(reason)
		if self.socket:IsValid() then
			network.HandleTCPMessage(self.socket, network.DISCONNECT, self:GetUniqueID(), reason or "kicked")
		end
		
		if self:IsBot() then
			event.Call("PlayerLeft", self:GetName(), self:GetUniqueID(), reason, self)
			event.BroadcastCall("PlayerLeft", self:GetName(), self:GetUniqueID(), reason)
			network.Broadcast(network.DISCONNECT, self:GetUniqueID(), reason)
		
			self:Remove()
		end
	end
end

do -- ping pong	
	nvars.GetSet(META, "Ping", 0)
		
	function META:GetTimeout()
		return (self.socket:IsValid() and self.last_ping) and (os.clock() - self.last_ping) or 0
	end
	
	console.CreateVariable("sv_timeout", 10)
	
	function META:IsTimingOut() 
		return self.socket:IsValid() and self:GetTimeout() > console.GetVariable("sv_timeout", 3)
	end

	if CLIENT then
		message.AddListener("ping", function(...)
			message.Send("pong", ...)
			
			players.GetLocalPlayer().last_ping = os.clock()
		end)
	end
	
	if SERVER then			
		message.AddListener("pong", function(ply, time)
			local ms = (os.clock() - tonumber(time)) * 100
			
			ply:SetPing(ms)
			ply.last_ping = os.clock()
		end)
	end		
	
	event.CreateTimer("ping_pong_players", 1, 0, function()
		if not network.IsStarted() then return end
		
		
		if SERVER then
			for key, ply in pairs(players.GetAll()) do			
				message.Send("ping", ply, tostring(os.clock()))
				
				if ply:IsTimingOut() then			
					ply:Kick("timeout")
				end
			end
		end
		
		if CLIENT then
			local ply = players.GetLocalPlayer()
			
			if ply:IsTimingOut() then
				logn("timing out from server..")
				
				if ply:IsTimingOut() then
					network.Disconnect("timed out")
				end
			end
		end
	end)

end

do -- send lua
	if CLIENT then
		message.AddListener("sendlua", function(code, env)
			local data = easylua.RunLua(me, code, env or "server")
			if data.error then
				print(data.error)
			end
		end)
	end

	if SERVER then
		function META:SendLua(code)
			message.Send("sendlua", self, code, env)
		end
		
		function META:Cexec(str)
			self:SendLua("console.RunString('"..str.."')")
		end
	end
end

do -- networked input
	local function add_event(name, check)	
		input.SetupAccessorFunctions(META, name)
		
		if CLIENT then
			event.AddListener(name .. "Input", "player_" .. name .. "_event", function(key, press)
				local ply = players.GetLocalPlayer()
				
				if ply:IsValid() then						
					if check and not check[key] then return end
					
					input.CallOnTable(ply, name, key, press, nil, nil, true)
					message.Send("Player" .. name .. "Event", key, press)
					
					return event.Call("Player" .. name .. "Event", ply, key, press)
				end
			end, print)
		end
		
		if SERVER then
			message.AddListener("Player" .. name .. "Event", function(ply, key, press)
				if ply:IsValid() then
					if check and not check[key] then return end

					input.CallOnTable(ply, name, key, press, nil, nil, true)
				
					event.Call("Player" .. name .. "Event", ply, key, press)
				end
			end, print)
		end
	end
			
	add_event("Key")
	add_event("Char")
end

utilities.DeclareMetaTable(META.ClassName, META)
entities.Register(META)