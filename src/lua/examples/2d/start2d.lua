local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2() + 256)
local tex = render.CreateTexture("2d")
tex:SetInternalFormat("rgb32f")
tex:SetMinFilter("nearest")

fb:SetTexture(1, tex)

event.Timer("updatefb", 0.1, function()
	local t = system.GetElapsedTime()

	fb:Begin()
	surface.PushMatrix()
		surface.Translate(math.sin(t) * 100, math.cos(t) * 100)
		surface.Rotate(t)

		surface.SetWhiteTexture()
		local x, y = surface.GetMousePosition()

		x = x - 50
		y = y - 50

		local x, y = surface.ScreenToWorld(x, y)
		surface.DrawRect(x,y,5,5, 0, 2.5, 2.5)

		render.SetBlendMode("additive")

		for _ = 1, 10 do
			surface.SetColor(math.randomf(), math.randomf(), math.randomf(), 0.2)
			surface.DrawRect(math.random(tex:GetSize().x), math.random(tex:GetSize().y), 100, 100, math.random()*math.pi)
		end

		render.SetBlendMode("alpha")
	surface.PopMatrix()
	fb:End()
end)

event.AddListener("Draw2D", "lol", function()
	local t = system.GetElapsedTime()

	surface.SetWhiteTexture()
	surface.SetColor(0, 0, 1, 1)
	surface.DrawRect(0, 0, 100, 100)

	surface.PushMatrix(50, 50)
		surface.SetWhiteTexture()
		surface.SetColor(1, 0, 1, 1)
		surface.DrawRect(0, 0, tex:GetSize().x, tex:GetSize().y)

		surface.PushMatrix(256, 256)
			surface.SetScissor(0, 0, 100, 100)
				surface.Rotate(math.rad(45))
				surface.SetWhiteTexture()
				surface.SetColor(0, 1, 0, 1)
				surface.DrawRect(0, 0, 256, 256)
			surface.SetScissor()
		surface.PopMatrix()
	surface.PopMatrix()

	surface.SetTexture(tex)
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(50, 50, tex:GetSize().x, tex:GetSize().y)

	surface.SetTexture(tex)
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(tex:GetSize().x, tex:GetSize().y, 50, 50, t, 25, 25)
end)