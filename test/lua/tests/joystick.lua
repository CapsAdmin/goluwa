event.AddListener("Draw2D", "joystick", function()
	local data = window.GetJoystickState(0)

	surface.SetFont("default")
	surface.SetColor(1,1,1,1)
	
	if data then
		local x, y = 0, 0
		surface.DrawText(data.name)
		y = y + 20
		
		for k, v in pairs(data.axes) do	
			v = math.round(v, 4)
			surface.SetTextPosition(x, y)
			surface.DrawText(k .. " = " .. v)
			y = y + 20
		end
		
		for k, v in pairs(data.buttons) do
			surface.SetTextPosition(x, y)
			surface.DrawText(k .. " = " .. v)
			y = y + 20
		end
	else
		surface.DrawText("no joystick present :(")
	end
end)