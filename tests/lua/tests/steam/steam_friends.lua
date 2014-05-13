local subject

event.AddListener("SteamFriendsMessage", "steam_friends", function(sender_steam_id, txt, receiver_steam_id)
	if txt:sub(1, 2) == ">>" then return end

	local ply = players.GetByUniqueID(sender_steam_id)
	
	if sender_steam_id == steam.GetClientSteamID() then
		sender_steam_id = receiver_steam_id
	end
	
	subject = sender_steam_id
	timer.Delay(0.1, function() subject = nil end)
	
	if ply:IsValid() then
		if SERVER then
			chat.PlayerSay(ply, txt)
		elseif txt:sub(1, 1) == "!" then
			console.RunString(txt:sub(2))
		end
	end
end)

event.AddListener("ConsolePrint", "steam_friends", function(line)
	if subject then
		steam.SendChatMessage(subject, ">> " .. line)
	end
end)

for i, steam_id in pairs(steam.GetFriends()) do
	local ply = players.Create(steam_id, true)
	ply:SetNick("(BOT)" .. steam.GetNickFromSteamID(ply:GetUniqueID()))
end

local ply = players.Create(steam.GetClientSteamID(), true)
ply:SetNick(steam.GetNickFromSteamID(ply:GetUniqueID()))