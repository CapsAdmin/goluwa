local fonts = {
	surface.CreateFont({
		path = "aladin",
		size = 54,
	}),
	surface.CreateFont({
		path = "angeline vintage",
		size = 54,
	}),
	--[[surface.CreateFont({
		path = "fonts/resource_imagefont1.png",
		glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"",
	}),
	surface.CreateFont({
		path = "fonts/boldfont.png",
		glyphs = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!'-:*@<>+/_$&?",
	}),]]
}

event.AddListener("Draw2D", "lol", function()
	local y = 0
	for _, font in ipairs(fonts) do
		local str = font:GetName()
		local size = Vec2(font:GetTextSize(str))
		surface.SetColor(1,1,1,1)
		surface.SetFont(font)
		surface.SetTextPosition(30, 30 + y)
		surface.DrawText(str)

		surface.SetWhiteTexture()
		surface.SetColor(1,0,0,0.25)
		surface.DrawRect(17, 30, size.x, size.y)

		y = y + size.y + 10
	end
end)