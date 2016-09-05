local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2()+1024)

do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(1024, 1024))
	tex:SetInternalFormat("rgba8")
	tex:Clear()

	fb:SetTexture(1, tex, "read_write")
end

do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(1024, 1024))
	tex:SetInternalFormat("rgba8")
	tex:Clear()

	fb:SetTexture(2, tex, "read_write")
end

do
	fb:WriteThese("2")

	fb:Begin()
		surface.SetColor(1,1,1,1)
		surface.DrawText("YOU SHOULD SEE THIS", 150, 80)
	fb:End()
end

do
	fb:WriteThese("1")

	fb:Begin()
		surface.SetColor(1,1,1,1)
		surface.DrawText("YOU SHOULD NOT SEE THIS", 250, 50)
	fb:End()

	fb:WriteThese("all")

	fb:Clear(1)
end

do -- write a red square only to attachment 2
	fb:WriteThese("2")

	fb:Begin()
		surface.SetWhiteTexture()
		surface.SetColor(1,0,0,1)
		surface.DrawRect(30,30,50,50)
	fb:End()
end

do	-- write a pink square only to attachment 1
	fb:WriteThese("1")

	fb:Begin()
		surface.SetWhiteTexture()
		surface.SetColor(1,0,1,1)
		surface.DrawRect(100,30,50,50)
	fb:End()
end

--fb:WriteThese("stencil")

do -- write a rotated green rectangle to attachment 1 and 2
	fb:WriteThese("1|2")

	fb:Begin()
		surface.SetWhiteTexture()
		surface.SetColor(0,1,0,0.5)
		surface.DrawRect(20,20,50,50, 50)
	fb:End()
end

local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2()+128)

for i = 1, 3 do
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2(128, 128))
	tex:SetInternalFormat("rgba8")
	tex:Clear()

	fb:SetTexture(i, tex, "read_write")

	fb:WriteThese(tostring(i))

	fb:Begin()
		surface.SetWhiteTexture()
		if i == 1 then
			surface.SetColor(1,0,0,0.5)
		elseif i == 2 then
			surface.SetColor(0,1,0,0.5)
		elseif i == 3 then
			surface.SetColor(0,0,1,0.5)
		end
		surface.DrawRect(i * 20, 20,50,50, 50)
	fb:End()
end

event.Timer("lol", 1, 4, function(i)
	if i == 1 then
		fb:Clear(i,1,0,0,0.25)
	elseif i == 2 then
		fb:Clear(i,0,1,0,0.25)
	elseif i == 3 then
		fb:Clear(i,0,0,1,0.25)
	end
end)


event.AddListener("PostDrawGUI", "lol", function()
	for i = 1, 3 do
		surface.SetTexture(fb:GetTexture(i))
		surface.SetColor(1, 1, 1, 1)
		surface.DrawRect(i*50, i*50, 128, 128)
	end
end)