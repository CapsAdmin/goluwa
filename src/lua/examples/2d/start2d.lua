local tex = render.CreateTexture("2d")
--tex:SetInternalFormat("rgb32f")
--tex:SetMinFilter("nearest")

event.Timer("updatefb", 0.1, function()
	local t = system.GetElapsedTime()

	tex:BeginWrite()
	render2d.PushMatrix()
		render2d.Translate(math.sin(t) * 100, math.cos(t) * 100)
		render2d.Rotate(t)

		render2d.SetTexture()
		local x, y = gfx.GetMousePosition()
		render2d.DrawRect(x,y,5,5, 0, 2.5, 2.5)

		--render.SetPresetBlendMode("additive")

		for _ = 1, 10 do
			render2d.SetColor(math.randomf(), math.randomf(), math.randomf(), 0.2)
			render2d.DrawRect(math.random(tex:GetSize().x), math.random(tex:GetSize().y), 100, 100, math.random()*math.pi)
		end

		--render.SetPresetBlendMode("alpha")
	render2d.PopMatrix()
	tex:EndWrite()
end)

event.AddListener("PreDrawGUI", "lol", function()
	local t = system.GetElapsedTime()

	render2d.SetTexture()
	render2d.SetColor(0, 0, 1, 1)
	render2d.DrawRect(0, 0, 100, 100)

	render2d.PushMatrix(50, 50)
		render2d.SetTexture()
		render2d.SetColor(1, 0, 1, 1)
		render2d.DrawRect(0, 0, tex:GetSize().x, tex:GetSize().y)

		render2d.PushMatrix(256, 256)
			render2d.SetScissor(0, 0, 100, 100)
				render2d.Rotate(math.rad(45))
				render2d.SetTexture()
				render2d.SetColor(0, 1, 0, 1)
				render2d.DrawRect(0, 0, 256, 256)
			render2d.SetScissor()
		render2d.PopMatrix()
	render2d.PopMatrix()

	render2d.SetTexture(tex)
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(50, 50, tex:GetSize().x, tex:GetSize().y)

	render2d.SetTexture(tex)
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(tex:GetSize().x, tex:GetSize().y, 50, 50, t, 25, 25)
end)