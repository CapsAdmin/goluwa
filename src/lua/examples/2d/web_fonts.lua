local fonts = {
	surface.CreateFont({
		path = "aladin",
		size = 54,
	}),
	surface.CreateFont({
		path = "angeline vintage",
		size = 30,
	}),
	surface.CreateFont({
		path = "roboto bold",
		size = 60,
	}),
	surface.CreateFont({
		path = "roboto italic",
		size = 60,
	}),
	surface.CreateFont({
		path = "Ruslan Display",
		size = 60,
	}),
	surface.CreateFont({
		path = "arial",
		size = 60,
	}),
	surface.CreateFont({
		path = "courier new",
		size = 40,
	}),
	surface.CreateFont({
		path = "tahoma",
		size = 40,
	}),
	surface.CreateFont({
		path = "helvetica",
		size = 40,
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

event.AddListener("PreDrawGUI", "lol", function()
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
		surface.DrawRect(30, 30 + y, size.x, size.y)

		y = y + size.y + 10
	end
end)