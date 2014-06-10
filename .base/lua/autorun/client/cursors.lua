event.AddListener("DrawHUD", "cursors", function()

	if not menu.IsVisible() then return end
	
	surface.SetColor(1,1,1,1)
	surface.SetFont("default")
	
	for _, ply in pairs(players.GetAll()) do
		if not ply:IsBot() then
			local cmd = ply:GetCurrentCommand()
			surface.SetTextPos(cmd.smooth_cursor.x, cmd.smooth_cursor.y)
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

include("libraries/ecs.lua")

event.AddListener("Update", "spooky", function()
	if not ecs then return end
	
	for i, ply in pairs(players.GetAll()) do
		ply.ghost = ply.ghost or NULL
		
		if not ply.ghost:IsValid() then
			ply.ghost = ecs.CreateEntity("shape")
			ply.ghost:SetModelPath("models/face.obj")
			ply.ghost:SetSize(10)
		end
		local cmd = ply:GetCurrentCommand()
		ply.ghost:SetPosition(cmd.camera.smooth_pos)
		ply.ghost:SetAngles(cmd.camera.ang)
		ply.ghost:SetScale(Vec3(1,(-(cmd.camera.smooth_fov / 90) + 2) ^ 4,1))
	end
end)
