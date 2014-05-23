local i = 0
event.AddListener("Update", "LOL", function()
	if wait(0.25) then
		os.setenv("SteamAppId", tostring(i))
		steam.GetAuthSessionTicket()
		i = i + 1
	end
end)