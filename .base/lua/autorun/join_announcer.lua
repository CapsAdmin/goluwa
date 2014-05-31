event.AddListener("PlayerSpawned", "join_announcer", function(ply)
	if chathud then
		chathud.AddText(Color(0,1,0), ply:GetName(), Color(1,1,1), " spawned!")
	end
	
	logf("%s spawned!\n", ply:GetName())
end)

event.AddListener("PlayerLeft", "join_announcer", function(name, uid, reason, ply)
	if chathud then
		chathud.AddText(Color(1,0,0), ply, Color(1,1,1), " left! (", reason ,")")
	end
	
	logf("%s left! (%s)\n", name, reason)
end)