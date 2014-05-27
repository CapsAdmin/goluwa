event.AddListener("SteamFriendsMessage", "steam_translate", function(sender_steam_id, txt, receiver_steam_id)
	if txt:sub(1, 2) == ">>" then return end

	local ply = players.GetByUniqueID(sender_steam_id)
	
	if sender_steam_id == steam.GetClientSteamID() then
		sender_steam_id = receiver_steam_id
	end
	
	google.Translate("auto", "en", txt, function(data)
		steam.SendChatMessage(sender_steam_id, ">> " ..data.translated)
	end)	
end)