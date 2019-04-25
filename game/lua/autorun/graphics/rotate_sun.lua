local time = 0

event.Timer("sun_rotate", 1/30, function()
	if input.IsKeyDown("n") or input.IsKeyDown("m") then
		local world = entities.world
		if world:IsValid() then
			local ang = world:GetSunAngles()
			ang.x = time
			world:SetSunAngles(ang)
		end
		if input.IsKeyDown("n") then
			time = time + 1/30
		else
			time = time - 1/30
		end
	end
end)