local META = {}

META.ClassName = "player"
META.TypeX = "player"

class.GetSet(META, "UniqueID", "???")
class.GetSet(META, "ID", -1)

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
	return self.nv and self.nv.Nick or SERVER and self.socket:GetIPPort() or CLIENT and self:GetUniqueID()
end

function META:OnRemove(reason)	
	players.active_players[self:GetUniqueID()] = nil
	if SERVER and self.socket then
		self.socket:Remove()
	end
end	

if SERVER then
	function META:Kick(reason)
		network.HandleEvent(self.socket, e.USER_DISCONNECT, self.socket:GetIPPort(), reason)
	end
end

do -- ping pong	
	nvars.GetSet(META, "Ping", 0)
		
	function META:GetTimeout()
		return self.last_ping and (os.clock() - self.last_ping) or 0
	end
	
	console.CreateVariable("sv_timeout", 10)
	
	function META:IsTimingOut()
		return self:GetTimeout() > console.GetVariable("sv_timeout", 3)
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
	
	timer.Create("ping_pong_players", 1, 0, function()
		if not network.IsStarted() then return end
					
		for key, ply in pairs(players.GetAll()) do			
			if ply.socket then
				message.Send("ping", ply, tostring(os.clock()))
				
				if ply:IsTimingOut() then
				
					if SERVER then
						ply:Kick("timeout")
					end
					
					if CLIENT then
						logn("timed out..")
						
						if ply:IsTimingOut() then
							network.Disconnect()
						end
					end
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
			event.AddListener("On" .. name .. "Input", "player_" .. name .. "_event", function(key, press)
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

entities.Register(META)