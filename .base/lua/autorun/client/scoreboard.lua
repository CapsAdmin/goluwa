event.AddListener("DrawHUD", "scoreboard", function()
	if not input.IsKeyDown("tab") then return end
	
	surface.SetColor(1,1,1,1)
	surface.SetFont("default")
	
	local i = 0
	local w, h = surface.GetScreenSize()
	for _, client in pairs(clients.GetAll()) do
		if not client:IsBot() then
			surface.SetTextPosition(w/2, h/2 + i * 20 + 5)
			surface.DrawText(client:GetNick())
			i = i + 1
		end
	end
end)