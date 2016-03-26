local function draw_shape(s, r)
	s = s or 50
	r = r or 45


	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(0,5, s,s, r, s/2, s/2)

	surface.SetColor(0, 0, 0, 1)
	surface.DrawRect(0,-5, s,s, r, s/2, s/2)

	surface.SetColor(0.75, 0, 0.75, 1)
	surface.DrawRect(0,0, s,s, r, s/2, s/2)

end

event.AddListener("Draw2D", "illusion", function()
	surface.SetWhiteTexture()
	surface.SetColor(0.75,0.75,0,1)
	surface.DrawRect(0,0,5000,5000)

	local w, h = surface.GetSize()

	for x = 0, 100 do
		x = x * 50
		for y = 0, 100 do
			y = y * 50
			surface.PushMatrix(x,y, 1,1, math.deg(math.sin(x) + math.cos(y)))
				draw_shape(25)
			surface.PopMatrix()
			if y > h then break end
		end
		if x > w then break end
	end

end)