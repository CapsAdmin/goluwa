chatsounds.Initialize()

console.AddCommand("l", function(line)
	local ok, err = loadstring(line)
	if not ok then logn(err) end
	ok, err = pcall(ok)
	if not ok then logn(err) end
end)

console.AddCommand("print", function(line)
	local ok, err = loadstring(("logn(%s)"):format(line))
	if not ok then logn(err) end
	ok, err = pcall(ok)
	if not ok then logn(err) end
end)

local subject
local prefix = "[!|/|%.]" 

event.AddListener("SteamFriendsMessage", "steam_friends", function(steam_id, txt, receiver_steam_id)
	if txt:sub(1, 2) == ">>" then return end
	
	if steam_id == steam.GetClientSteamID() then
		steam_id = receiver_steam_id
	end
	
	chatsounds.Say(nil, txt)
	
	if txt:sub(1, 1):find(prefix) then
		local cmd = txt:match(prefix.."(.-) ") or txt:match(prefix.."(.+)") or ""
		local line = txt:match(prefix..".- (.+)") or ""

		cmd = cmd:lower()

		if console.GetCommands()[cmd] then
			subject = steam_id
			console.RunString(cmd .. " " .. line)
			timer.Delay(0.1, function() subject = nil end)
		end
	end
end)

event.AddListener("ConsolePrint", "steam_friends", function(line)
	if subject then
		steam.SendChatMessage(subject, ">> " .. line)
	end
end)