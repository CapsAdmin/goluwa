players = players or {}
players.active_players = players.active_players or {}

function players.GetAll()
	local out = {}
	for key, ply in pairs(players.active_players) do
		if ply:IsValid() then
			table.insert(out, ply)
		else
			players.active_players[key] = nil
		end
	end
	return out
end

function players.GetByUniqueID(id)
	return players.active_players[id] or NULL
end

function players.GetLocalPlayer()
	return players.local_player or NULL
end
	
function players.BroadcastLua(str)
	for key, ply in pairs(players.GetAll()) do
		ply:SendLua(str)
	end
end
	
		
function players.Create(uniqueid)
	local self = players.active_players[uniqueid] or NULL

	if self:IsValid() then
		return self
	end
	
	local self = Entity("player")
		
	self:SetUniqueID(uniqueid)
	
	players.active_players[self.UniqueID] = self
			
	-- add a networked table to the player
	self.nv = nvars.CreateObject(uniqueid)
		
	return self
end

_G.Player = players.Create

network.AddEncodeDecodeType("player", function(var, encode)
	if encode then
		local var = var:GetUniqueID()
		return var
	else
		local var = players.GetByUniqueID(var)
		if var:IsValid() then
			return var
		end
	end
end) 
