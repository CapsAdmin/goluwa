local gradient = render.CreateTextureFromPath("https://s-media-cache-ak0.pinimg.com/736x/2a/e1/7e/2ae17eee05d683190d132c1faeef0680.jpg")
gradient:SetWrapS("repeat")
gradient:SetWrapT("repeat")
gradient:SetWrapR("repeat")

local fonts = {
	fonts.CreateFont({
		path = "aladin",
		size = 100,
		shadow = {
			order = 1,
			dir = 4,
			color = Color(1,0.5,0.25,1)/2,
		},
		gradient = {
			order = 2,
			texture = gradient,
		},
		padding = 40,
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
		padding = 50,
		shadow = {
			order = 1,
			dir = 0,
			color = Color(0,0,0.25,1),
			blur_radius = 0.75,
			blur_passes = 10,
			alpha_pow = 75,
		},
	}),
	fonts.CreateFont({
		path = "arial",
		size = 60,
		padding = 50,
		shadow = {
			order = 1,
			dir = 0,
			color = Color(1,0,0.25,1),
			blur_radius = 3,
			blur_passes = 5,
		},
	}),
	fonts.CreateFont({
		path = "courier new",
		size = 40,
	}),
	fonts.CreateFont({
		path = "tahoma",
		size = 40,
		padding = 50,
		shadow = {
			order = 1,
			dir = Vec2(3,3),
			color = Color(0,0,0.25,1),
			blur_radius = 0.1,
			blur_passes = 10,
			alpha_pow = 75,
		},
	}),
	fonts.CreateFont({
		path = "helvetica",
		size = 100,
		padding = 50,
		shadow = {
			order = 1,
			dir = 20,
			dir_passes = 40,
			dir_falloff = 3,
			color = Color(0,0,0,1),
		},
	}),
	fonts.CreateFont({
		path = "barrio",
		size = 40,
		padding = 40,
		shadow = {
			order = 1,
			dir = Vec2(0,0)+5,
			color = Color(1,0.75,1,1),
			blur_radius = 0.1,
			blur_passes = 10,
			alpha_pow = 3,
			dir_passes = 40,
			dir_falloff = 3,
		},
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

function goluwa.PreDrawGUI()
	render2d.SetTexture(render.GetWhiteTexture())
	render2d.SetColor(0.5,0.5,0.5,1)
	render2d.DrawRect(0,0,render2d.GetSize())

	local y = 0
	for _, font in ipairs(fonts) do
		local str = "A quick brown fox jumps over the lazy dog. - " .. font:GetName()
		local size = Vec2(font:GetTextSize(str))
		render2d.SetColor(1,1,1,1)
		gfx.SetFont(font)
		gfx.SetTextPosition(30, 30 + y)
		gfx.DrawText(str)

		render2d.SetTexture()
		render2d.SetColor(1,0,0,0.25)
		--render2d.DrawRect(30, 30 + y, size.x, size.y)

		y = y + size.y + 10
	end
end