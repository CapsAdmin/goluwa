event.AddListener("DrawHUD", "cursors", function()
	surface.Color(1,1,1,1)
	surface.SetFont("default")
	
	for _, ply in pairs(players.GetAll()) do
		if not ply:IsBot() then
			local cmd = ply:GetCurrentCommand()
			surface.SetTextPos(cmd.cursor.x, cmd.cursor.y)
			local str = ply:GetNick()
			local coh = ply:GetChatAboveHead()
			
			if #coh > 0 then
				str = str .. ": " .. coh
			end
			
			surface.DrawText(str)
		end
	end
	
	surface.SetAlphaMultiplier(1)
end)