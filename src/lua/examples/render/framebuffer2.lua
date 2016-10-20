local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2()+128)

for i = 1, 3 do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(128, 128))
	tex:SetInternalFormat("rgba8")
	tex:SetupStorage()
	tex:Clear()

	fb:SetTexture(i, tex, "read_write")

	fb:WriteThese(i)

	fb:Begin()
		render2d.SetTexture()
		if i == 1 then
			render2d.SetColor(1,0,0,0.5)
		elseif i == 2 then
			render2d.SetColor(0,1,0,0.5)
		elseif i == 3 then
			render2d.SetColor(0,0,1,0.5)
		end
		render2d.DrawRect(i * 20, 20,50,50)
	fb:End()
end

event.Timer("lol", 1, 4, function(i)
	if i == 1 then
		fb:ClearTexture(i,1,0,0,0.25)
	elseif i == 2 then
		fb:ClearTexture(i,0,1,0,0.25)
	elseif i == 3 then
		fb:ClearTexture(i,0,0,1,0.25)
	end
end)

event.AddListener("PostDrawGUI", "lol", function()
	for i = 1, 3 do
		render2d.SetTexture(fb:GetTexture(i))
		render2d.SetColor(1, 1, 1, 1)
		render2d.DrawRect(50, i*50, 128, 128)
	end
end)