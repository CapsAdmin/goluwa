local fonts = {
	fonts.CreateFont({
		path = "aladin",
		size = 54,
	}),
	fonts.CreateFont({
		path = "angeline vintage",
		size = 30,
	}),
	fonts.CreateFont({
		path = "roboto bold",
		size = 60,
	}),
	fonts.CreateFont({
		path = "roboto italic",
		size = 60,
	}),
	fonts.CreateFont({
		path = "Ruslan Display",
		size = 60,
	}),
	fonts.CreateFont({
		path = "arial",
		size = 60,
	}),
	fonts.CreateFont({
		path = "courier new",
		size = 40,
	}),
	fonts.CreateFont({
		path = "tahoma",
		size = 40,
	}),
	fonts.CreateFont({
		path = "helvetica",
		size = 40,
	}),
	--[[fonts.CreateFont({
		path = "fonts/resource_imagefont1.png",
		glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"",
	}),
	fonts.CreateFont({
		path = "fonts/boldfont.png",
		glyphs = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!'-:*@<>+/_$&?",
	}),]]
}

event.AddListener("PreDrawGUI", "lol", function()
	local y = 0
	for _, font in ipairs(fonts) do
		local str = font:GetName()
		local size = Vec2(font:GetTextSize(str))
		render2d.SetColor(1,1,1,1)
		gfx.SetFont(font)
		gfx.SetTextPosition(30, 30 + y)
		gfx.DrawText(str)

		render2d.SetTexture()
		render2d.SetColor(1,0,0,0.25)
		render2d.DrawRect(30, 30 + y, size.x, size.y)

		y = y + size.y + 10
	end
end)