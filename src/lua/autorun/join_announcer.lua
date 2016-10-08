event.AddListener("ClientEntered", "join_announcer", function(client)
	if CLIENT then
		-- ClientEntered is the earliest moment we know about entering the server
		-- it might not have synchronized variables such as nickname yet
		event.Delay(0.1, function()
			chathud.AddText(Color(0,1,0,1), client, Color(1,1,1,1), " spawned!")
		end)
	end

	if SERVER then
		logf("%s (%s) spawned!\n", client:GetNick(), client:GetUniqueID())
	end
end)

event.AddListener("ClientLeft", "join_announcer", function(client, reason)
	if CLIENT then
		chathud.AddText(Color(1,0,0,1), client, Color(1,1,1,1), " left! (", reason ,")")
	end

	if SERVER then
		logf("%s left! (%s)\n", client:GetNick(), reason)
	end
end)