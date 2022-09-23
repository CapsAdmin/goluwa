if not steam.IsSteamClientAvailible() then
	logn("steam friends extension not available")
	return
end

local subject

function goluwa.SteamFriendsMessage(sender_steam_id, txt, receiver_steam_id)
	if txt:sub(1, 2) == ">>" then return end

	local ply = clients.GetByUniqueID(sender_steam_id)

	if sender_steam_id == steam.GetClientSteamID() then
		sender_steam_id = receiver_steam_id
	end

	subject = sender_steam_id

	timer.Delay(0.1, function()
		subject = nil
	end)

	if ply:IsValid() then
		if SERVER then
			chat.PlayerSay(ply, txt)
		elseif txt:sub(1, 1) == "!" then
			commands.RunString(txt:sub(2), nil, nil, true)
		end
	end
end

function goluwa.ReplPrint(line)
	if subject then steam.SendChatMessage(subject, ">> " .. line) end
end

for i, steam_id in pairs(steam.GetFriends()) do
	local ply = clients.Create(steam_id, true)
	ply:SetNick("(BOT)" .. steam.GetNickFromSteamID(ply:GetUniqueID()))
end

local ply = clients.Create(steam.GetClientSteamID(), true)
ply:SetNick(steam.GetNickFromSteamID(ply:GetUniqueID()))