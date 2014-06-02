event.AddListener("DrawHUD", "cursors", function()
	surface.Color(1,1,1,1)
	surface.SetFont("default")
	
	for _, ply in pairs(players.GetAll()) do
		if not ply:IsBot() then
			local cmd = ply:GetCurrentCommand()
			surface.SetTextPos(cmd.cursor.x, cmd.cursor.y)
			surface.DrawText(ply:GetNick())
		end
	end
	
	surface.SetAlphaMultiplier(1)
end)