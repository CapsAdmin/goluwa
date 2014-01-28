event.AddListener("PlayerSpawned", "join_announcer", function(ply)
	if chathud then
		chathud.AddText(ply, " spawned!")
	end
end)