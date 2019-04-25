local function draw_shape(s, r)
	s = s or 50
	r = r or 45


	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(0,5, s,s, r, s/2, s/2)

	render2d.SetColor(0, 0, 0, 1)
	render2d.DrawRect(0,-5, s,s, r, s/2, s/2)

	render2d.SetColor(0.75, 0, 0.75, 1)
	render2d.DrawRect(0,0, s,s, r, s/2, s/2)

end

function goluwa.PreDrawGUI()
	render2d.SetTexture()
	render2d.SetColor(0.75,0.75,0,1)
	render2d.DrawRect(0,0,5000,5000)

	local w, h = render2d.GetSize()

	for x = 0, 100 do
		x = x * 50
		for y = 0, 100 do
			y = y * 50
			render2d.PushMatrix(x,y, 1,1, math.deg(math.sin(x) + math.cos(y)))
				draw_shape(25)
			render2d.PopMatrix()
			if y > h then break end
		end
		if x > w then break end
	end

end