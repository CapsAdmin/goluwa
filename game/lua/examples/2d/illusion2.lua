local function draw_shape(s, r, t)
	s = s or 50
	r = r or 45
	local a = (math.sin(t) + 1) / 2
	local b = (math.sin(-t) + 1) / 2
	a = a + 0.5
	b = b + 0.5
	render2d.SetColor(a, a, a, 1)
	render2d.DrawRect(2, 0, s, s, r, s / 2, s / 2)
	render2d.SetColor(b, b, b, 1)
	render2d.DrawRect(-2, 0, s, s, r, s / 2, s / 2)
end

function goluwa.PreDrawGUI()
	render2d.SetTexture()
	render2d.SetColor(0.75, 0.75, 0.75, 1)
	render2d.DrawRect(0, 0, 5000, 5000)
	local w, h = render2d.GetSize()
	local t = system.GetElapsedTime() * 4

	for x = 0, 100 do
		x = x * 45

		for y = 0, 100 do
			y = y * 45
			render2d.PushMatrix(x, y, 1, 1)
			draw_shape(30, nil, t + x * y)
			render2d.PopMatrix()

			if y > h then break end
		end

		if x > w then break end
	end
end