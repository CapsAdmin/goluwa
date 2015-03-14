local friend = steam.FindFriend("Immortalyes")

local last_console_message

event.AddListener("ConsolePrint", "steam_console", function()
	event.Delay(0.1, function()
		local str = console.GetCurrentText()
		friend:ReplyToMessage(str) 
		last_console_message = str
	end)
end)

event.CreateTimer("steam_console", 0.1, 0, function()
	local msg = friend:GetLastChatMessage()
	
	if msg ~= last_console_message and last_console_message then
		console.RunString(msg, nil, nil, true)
	end
end)