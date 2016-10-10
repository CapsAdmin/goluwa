do
	local player = gmod.env.player

	function player.GetAll()
		local out = {}
		local i = 1

		for _, ent in pairs(gmod.objects.Player) do
			if ent:IsValid() then
				table.insert(out, ent)
			end
		end

		return out
	end

	function player.GetHumans()
		local out = {}
		local i = 1

		for _, ent in pairs(gmod.objects.Player) do
			if not ent.__obj:IsBot() then
				if ent:IsValid() then
					table.insert(out, ent)
				end
			end
		end

		return out
	end

	function player.GetBots()
		local out = {}
		local i = 1

		for _, ent in pairs(gmod.objects.Player) do
			if ent.__obj:IsBot() then
				table.insert(out, ent)
			end
		end

		return out
	end

	player.GetHumans = player.GetAll
	function player.GetBots() return {} end
end

do
	function gmod.env.player.CreateNextBot(name)
		local client = clients.CreateBot()
		client:SetNick(name)
		return gmod.WrapObject(cllient, "Player")
	end

	function gmod.env.LocalPlayer()
		gmod.local_player = gmod.local_player or gmod.WrapObject(clients.GetLocalClient(), "Player")
		return gmod.local_player
	end

	local META = gmod.GetMetaTable("Player")

	function META:GetAimVector()
		return gmod.env.EyeVector()
	end

	function META:GetViewEntity()
		return NULL
	end

	function META:Armor()
		return 50
	end

	function META:Team()
		return 0
	end

	function META:Frags()
		return 0
	end

	function META:Deaths()
		return 0
	end

	function META:Ping()
		return 0
	end

	function META:IsMuted()
		return false
	end

	function META:IsBot()
		return false
	end

	function META:SteamID()
		return "STEAM_0:1:" .. self:UniqueID()
	end

	function META:SteamID64()
		return "76561197978977007"
	end

	function META:Nick()
		return self.__obj:GetNick()
	end

	function META:UniqueID()
		return crypto.CRC32(("%p"):format(self.__obj))
	end

	function META:GetActiveWeapon()
		if not self.__obj.gmod_weapon then
			self.__obj.gmod_weapon = gmod.CreateWeapon()
		end
		return gmod.WrapObject(self.__obj.gmod_weapon, "Weapon")
	end

	function META:IsPlayer()
		return true
	end

	function META:UserID()
		return math.abs(tonumber(self:UniqueID())%333) -- todo
	end

	function META:GetFriendStatus()
		return "none"
	end

	function META:GetAttachedRagdoll()
		return _G.NULL
	end

	function META:SetClassID(id)
		self.__obj.gmod_classid = id
	end

	function META:GetClassID()
		return self.__obj.gmod_classid or 0
	end

	function META:IsDrivingEntity(ent)
		return false
	end

	function META:GetVehicle()
		return NULL
	end

	function META:InVehicle()
		return false
	end

	function META:Alive()
		return true
	end

	--if SERVER then
		function META:IPAddress()
			return "192.168.1.101:27005"
		end
	--end

	function META:IsSpeaking()
		return false
	end

	function META:GetInfoNum(key, def)
		return def or 0
	end

	function META:KeyDown(key)
		return gmod.env.input.IsKeyDown(key)
	end
end

do
	gmod.AddEvent("ClientEntered", function(client)
		local ply = gmod.WrapObject(client, "Player")
		gmod.env.hook.Run("player_connect", {
			name = ply:Nick(),
			networkid = ply:SteamID(),
			address = ply:IPAddress(),
			userid = ply:UserID(),
			bot = 0, -- ply:IsBot(),
			index = ply:EntIndex(),
		})

		gmod.env.gamemode.Call("PlayerConnect", ply:Nick(), ply:IPAddress())

		event.Delay(0.5, function()
			gmod.env.hook.Run("player_spawn", {
				userid = ply:UserID(),
			})

			event.Delay(0, function()
				gmod.env.hook.Run("player_activate", {
					userid = ply:UserID(),
				})

				event.Delay(0, function()
					gmod.env.gamemode.Call("OnEntityCreated", ply)
					gmod.env.gamemode.Call("NetworkEntityCreated", ply)
					gmod.env.gamemode.Call("PlayerInitialSpawn", ply)
					gmod.env.gamemode.Call("PlayerSpawn", ply)
				end, nil, client)
			end, nil, client)
		end, nil, client)
	end)

	gmod.AddEvent("ClientLeft", function(client, reason)
		local ply = gmod.WrapObject(client, "Player")

		gmod.env.gamemode.Call("EntityRemoved", ply)
		gmod.env.gamemode.Call("PlayerDisconnected", ply)

		gmod.env.hook.Run("player_disconnect", {
			name = ply:Nick(),
			networkid = ply:SteamID(),
			userid = ply:UserID(),
			bot = ply:IsBot(),
			reason = reason,
		})
	end)

	gmod.AddEvent("ClientChat", function(client, msg)
		local ply = gmod.WrapObject(client, "Player")
		gmod.env.gamemode.Call("OnPlayerChat", ply, msg, false, not ply:Alive())
	end)

	if RELOAD then
		for k,v in pairs(gmod.env.player.GetAll()) do
			event.Call("ClientLeft", v.__obj, "reloading")
		end

		for k,v in pairs(gmod.env.player.GetAll()) do
			event.Call("ClientEntered", v.__obj)
		end
	end
end