local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2()+1024)

do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(1024, 1024))
	tex:SetInternalFormat("rgba8")
	tex:SetupStorage()
	tex:Clear()

	fb:SetTexture(1, tex, "read_write")
end

do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(1024, 1024))
	tex:SetInternalFormat("rgba8")
	tex:SetupStorage()
	tex:Clear()

	fb:SetTexture(2, tex, "read_write")
end

do
	fb:WriteThese("2")

	fb:Begin()
		render2d.SetColor(1,1,1,1)
		gfx.DrawText("YOU SHOULD SEE THIS", 150, 80)
	fb:End()
end

do
	fb:WriteThese("1")

	fb:Begin()
		render2d.SetColor(1,1,1,1)
		gfx.DrawText("YOU SHOULD NOT SEE THIS", 250, 50)
	fb:End()

	fb:WriteThese("all")

	fb:ClearTexture(1)
end

do -- write a red square only to attachment 2
	fb:WriteThese("2")

	fb:Begin()
		render2d.SetTexture()
		render2d.SetColor(1,0,0,1)
		render2d.DrawRect(30,30,50,50)
		gfx.DrawText("attachment 2", 0, 80)
	fb:End()
end

do	-- write a pink square only to attachment 1
	fb:WriteThese("1")

	fb:Begin()
		render2d.SetTexture()
		render2d.SetColor(1,0,1,1)
		render2d.DrawRect(30,30,50,50)
		gfx.DrawText("attachment 1", 0, 80)
	fb:End()
end

--fb:WriteThese("stencil")

do -- write a rotated green rectangle to attachment 1 and 2
	fb:WriteThese("1|2")

	fb:Begin()
		render2d.SetTexture()
		render2d.SetColor(0,1,0,0.5)
		render2d.DrawRect(20,20,50,50, 50)
		gfx.DrawText("attachment 1 and 2", 0, 100)
	fb:End()
end

event.AddListener("PostDrawGUI", "lol", function()
	for i = 1, 2 do
		render2d.SetTexture(fb:GetTexture(i))
		render2d.SetColor(1, 1, 1, 1)
		render2d.DrawRect(50, i*100, 1024, 1024)
	end
end)