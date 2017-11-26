do
	local player = gine.env.player

	function player.GetAll()
		local out = {}
		local i = 1

		for _, ent in pairs(gine.objects.Player) do
			if ent:IsValid() then
				table.insert(out, ent)
			end
		end

		return out
	end

	function player.GetCount()
		return #player.GetAll()
	end

	function player.GetHumans()
		local out = {}
		local i = 1

		for _, ent in pairs(gine.objects.Player) do
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

		for _, ent in pairs(gine.objects.Player) do
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
	function gine.env.player.CreateNextBot(name)
		local client = clients.CreateBot()
		client:SetNick(name)
		return gine.WrapObject(cllient, "Player")
	end

	function gine.env.LocalPlayer()
		gine.local_player = gine.local_player or gine.WrapObject(clients.GetLocalClient(), "Player")
		return gine.local_player
	end

	function gine.env.Player()
		return gine.env.LocalPlayer()
	end

	local META = gine.GetMetaTable("Player")

	function META:Crouching()

	end

	function META:GetAimVector()
		if CLIENT then
			return gine.env.EyeVector()
		end

		return gine.env.Vector()
	end

	function META:GetViewEntity()
		return NULL
	end

	function META:VoiceVolume()
		return math.random()
	end

	function META:SetArmor(num)
		self.__obj.gine_armor = num
	end

	function META:Armor()
		return self.__obj.gine_armor or 0
	end

	function META:SetTeam(id)
		self.__obj.gine_team = id
	end

	function META:Team()
		return self.__obj.gine_team or gine.env.TEAM_SPECTATOR
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

	function META:IsListenServerHost()
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

	function META:ShouldDrawLocalPlayer()
		return false
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
		self.__obj.gine_classid = id
	end

	function META:GetClassID()
		return self.__obj.gine_classid or 0
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

	function META:KeyDown(key)
		return gine.env.input.IsKeyDown(key)
	end

	function META:SetNoCollideWithTeammates(b) end
	function META:SetAvoidPlayers(b) end

	function META:GetViewModel()
		self.__obj.viewmodel = self.__obj.viewmodel or gine.env.ents.Create("predicted_viewmodel")
		return self.__obj.viewmodel
	end

	function META:UnSpectate()

	end

	function META:SetPlayerColor()

	end

	gine.GetSet(META, "Hands", NULL)

	gine.GetSet(META, "WalkSpeed", 200)
	gine.GetSet(META, "RunSpeed", 400)
	gine.GetSet(META, "CrouchedWalkSpeed", 0.3)
	gine.GetSet(META, "UnDuckSpeed", 0.1)
	gine.GetSet(META, "JumpPower", 200)
	gine.GetSet(META, "DuckSpeed", 0.1)
	gine.GetSet(META, "FOV", 90)
end

do
	gine.AddEvent("ClientEntered", function(client)
		local ply = gine.WrapObject(client, "Player")
		gine.env.hook.Run("player_connect", {
			name = ply:Nick(),
			networkid = ply:SteamID(),
			address = ply:IPAddress(),
			userid = ply:UserID(),
			bot = 0, -- ply:IsBot(),
			index = ply:EntIndex(),
		})

		gine.env.gamemode.Call("PlayerConnect", ply:Nick(), ply:IPAddress())

		event.Delay(0.5, function()
			gine.env.hook.Run("player_spawn", {
				userid = ply:UserID(),
			})

			event.Delay(0, function()
				gine.env.hook.Run("player_activate", {
					userid = ply:UserID(),
				})

				event.Delay(0, function()
					gine.env.gamemode.Call("OnEntityCreated", ply)
					gine.env.gamemode.Call("NetworkEntityCreated", ply)
					gine.env.gamemode.Call("PlayerInitialSpawn", ply)
					gine.env.gamemode.Call("PlayerSpawn", ply)
				end, nil, client)
			end, nil, client)
		end, nil, client)
	end)

	gine.AddEvent("ClientLeft", function(client, reason)
		local ply = gine.WrapObject(client, "Player")

		gine.env.gamemode.Call("EntityRemoved", ply)
		gine.env.gamemode.Call("PlayerDisconnected", ply)

		gine.env.hook.Run("player_disconnect", {
			name = ply:Nick(),
			networkid = ply:SteamID(),
			userid = ply:UserID(),
			bot = ply:IsBot(),
			reason = reason,
		})
	end)

	gine.AddEvent("ClientChat", function(client, msg)
		local ply = gine.WrapObject(client, "Player")
		gine.env.gamemode.Call("OnPlayerChat", ply, msg, false, not ply:Alive())
	end)

	if RELOAD then
		for k,v in pairs(gine.env.player.GetAll()) do
			event.Call("ClientLeft", v.__obj, "reloading")
		end

		for k,v in pairs(gine.env.player.GetAll()) do
			event.Call("ClientEntered", v.__obj)
		end
	end
end
