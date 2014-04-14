if not SERVER and not CLIENT then
	goluwa.StartLuaInstance("start_server", "host", "open steam_friends")

	timer.Delay(0.25, function()
		console.RunString("start_client")
		console.RunString("connect localhost 1234")
	end)
end

if SERVER then
	local subject
	
	event.AddListener("SteamFriendsMessage", "steam_friends", function(sender_steam_id, txt, receiver_steam_id)
		if txt:sub(1, 2) == ">>" then return end
	
		local ply = players.GetByUniqueID(sender_steam_id)
		
		if sender_steam_id == steam.GetClientSteamID() then
			for k,v in pairs(players.GetAll()) do
				if not v:IsBot() then
					ply = v
					sender_steam_id = receiver_steam_id
					break
				end
			end
		end
		
		subject = sender_steam_id
		timer.Delay(0.1, function() subject = nil end)
		
		if ply:IsValid() then
			chat.PlayerSay(ply, txt)
		end
	end)

	event.AddListener("ConsolePrint", "steam_friends", function(line)
		if subject then
			steam.SendChatMessage(subject, ">> " .. line)
		end
	end)
	
	for i, steam_id in pairs(steam.GetFriends()) do
		local ply = players.Create(steam_id, true)
		ply:SetNick(steam.GetNickFromSteamID(steam_id))
	end
end 