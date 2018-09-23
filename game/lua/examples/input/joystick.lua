function goluwa.PreDrawGUI()
	local data = window.GetJoystickState(0)

	gfx.SetFont()
	render2d.SetColor(1,1,1,1)

	if data then
		local x, y = 0, 0
		gfx.DrawText(data.name)
		y = y + 20

		for k, v in pairs(data.axes) do
			v = math.round(v, 4)
			gfx.SetTextPosition(x, y)
			gfx.DrawText(k .. " = " .. v)
			y = y + 20
		end

		for k, v in pairs(data.buttons) do
			gfx.SetTextPosition(x, y)
			gfx.DrawText(k .. " = " .. v)
			y = y + 20
		end
	else
		gfx.DrawText("no joystick present :(")
	end
end