event.AddListener("ClientEntered", "join_announcer", function(client)
	if chathud then
		chathud.AddText(Color(0,1,0), client:GetName(), Color(1,1,1), " spawned!")
	end

	logf("%s spawned!\n", client:GetName())
end)

event.AddListener("ClientLeft", "join_announcer", function(name, uid, reason, client)
	if chathud then
		chathud.AddText(Color(1,0,0), client, Color(1,1,1), " left! (", reason ,")")
	end

	logf("%s left! (%s)\n", name, reason)
end)