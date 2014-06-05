event.AddListener("DrawHUD", "scoreboard", function()
	if not input.IsKeyDown("tab") then return end
	
	surface.SetColor(1,1,1,1)
	surface.SetFont("default")
	
	local i = 0
	local w, h = surface.GetScreenSize()
	for _, ply in pairs(players.GetAll()) do
		if not ply:IsBot() then
			surface.SetTextPos(w/2, h/2 + i * 20 + 5)
			surface.DrawText(ply:GetNick())
			i = i + 1
		end
	end
end)