local render2d = ... or _G.render2d

function render2d.DrawRect(x,y, w,h, a, ox,oy)
	render2d.PushMatrix()
		if x and y then
			render2d.Translate(x, y)
		end

		if a then
			render2d.Rotate(a)
		end

		if ox then
			render2d.Translate(-ox, -oy)
		end

		if w and h then
			render2d.Scale(w, h)
		end

		render2d.BindShader()
		render2d.rectangle:Draw()
	render2d.PopMatrix()
end

do
	--[[{
		{pos = {0, 0}, uv = {xbl, ybl}, color = color_bottom_left},
		{pos = {0, 1}, uv = {xtl, ytl}, color = color_top_left},
		{pos = {1, 1}, uv = {xtr, ytr}, color = color_top_right},

		{pos = {1, 1}, uv = {xtr, ytr}, color = color_top_right},
		{pos = {1, 0}, uv = {xbr, ybr}, color = mesh_data[1].color},
		{pos = {0, 0}, uv = {xbl, ybl}, color = color_bottom_left},
	})]]

	-- sdasdasd

	local last_xtl = 0
	local last_ytl = 0
	local last_xtr = 1
	local last_ytr = 0

	local last_xbl = 0
	local last_ybl = 1
	local last_xbr = 1
	local last_ybr = 1

	local last_color_bottom_left = Color(1,1,1,1)
	local last_color_top_left = Color(1,1,1,1)
	local last_color_top_right = Color(1,1,1,1)
	local last_color_bottom_right = Color(1,1,1,1)

	local function update_vbo()

		if
			last_xtl ~= render2d.rectangle.Vertices[0].uv[0] or
			last_ytl ~= render2d.rectangle.Vertices[0].uv[1] or
			last_xtr ~= render2d.rectangle.Vertices[4].uv[0] or
			last_ytr ~= render2d.rectangle.Vertices[4].uv[1] or

			last_xbl ~= render2d.rectangle.Vertices[1].uv[0] or
			last_ybl ~= render2d.rectangle.Vertices[0].uv[1] or
			last_xbr ~= render2d.rectangle.Vertices[3].uv[0] or
			last_ybr ~= render2d.rectangle.Vertices[3].uv[1] or

			last_color_bottom_left ~= render2d.rectangle.Vertices[1].color or
			last_color_top_left ~= render2d.rectangle.Vertices[0].color or
			last_color_top_right ~= render2d.rectangle.Vertices[2].color or
			last_color_bottom_right ~= render2d.rectangle.Vertices[3].color
		then

			render2d.rectangle:UpdateBuffer()

			last_xtl = render2d.rectangle.Vertices[0].uv[0]
			last_ytl = render2d.rectangle.Vertices[0].uv[1]
			last_xtr = render2d.rectangle.Vertices[4].uv[0]
			last_ytr = render2d.rectangle.Vertices[4].uv[1]

			last_xbl = render2d.rectangle.Vertices[1].uv[0]
			last_ybl = render2d.rectangle.Vertices[0].uv[1]
			last_xbr = render2d.rectangle.Vertices[3].uv[0]
			last_ybr = render2d.rectangle.Vertices[3].uv[1]

			last_color_bottom_left = render2d.rectangle.Vertices[1].color
			last_color_top_left = render2d.rectangle.Vertices[0].color
			last_color_top_right = render2d.rectangle.Vertices[2].color
			last_color_bottom_right = render2d.rectangle.Vertices[3].color
		end
	end

	do
		local X, Y, W, H, SX, SY

		function render2d.SetRectUV(x,y, w,h, sx,sy)
			if not x then
				render2d.rectangle.Vertices[1].uv[0] = 0
				render2d.rectangle.Vertices[0].uv[1] = 0
				render2d.rectangle.Vertices[1].uv[1] = 1
				render2d.rectangle.Vertices[2].uv[0] = 1
			else
				sx = sx or 1
				sy = sy or 1

				y = -y - h

				render2d.rectangle.Vertices[1].uv[0] = x / sx
				render2d.rectangle.Vertices[0].uv[1] = y / sy
				render2d.rectangle.Vertices[1].uv[1] = (y + h) / sy
				render2d.rectangle.Vertices[2].uv[0] = (x + w) / sx
			end

			render2d.rectangle.Vertices[0].uv[0] = render2d.rectangle.Vertices[1].uv[0]
			render2d.rectangle.Vertices[2].uv[1] = render2d.rectangle.Vertices[0].uv[1]
			render2d.rectangle.Vertices[4].uv = render2d.rectangle.Vertices[2].uv
			render2d.rectangle.Vertices[3].uv[0] = render2d.rectangle.Vertices[2].uv[0]
			render2d.rectangle.Vertices[3].uv[1] = render2d.rectangle.Vertices[1].uv[1]
			render2d.rectangle.Vertices[5].uv = render2d.rectangle.Vertices[1].uv

			update_vbo()

			X = x
			Y = y
			W = w
			H = h
			SX = sx
			SY = sy
		end

		function render2d.GetRectUV()
			return X, Y, W, H, SX, SY
		end

		function render2d.SetRectUV2(u1,v1, u2,v2)
			render2d.rectangle.Vertices[1].uv[0] = u1
			render2d.rectangle.Vertices[0].uv[1] = v1
			render2d.rectangle.Vertices[1].uv[1] = u2
			render2d.rectangle.Vertices[2].uv[0] = v2

			render2d.rectangle.Vertices[0].uv[0] = render2d.rectangle.Vertices[1].uv[0]
			render2d.rectangle.Vertices[2].uv[1] = render2d.rectangle.Vertices[0].uv[1]
			render2d.rectangle.Vertices[4].uv = render2d.rectangle.Vertices[2].uv
			render2d.rectangle.Vertices[3].uv[0] = render2d.rectangle.Vertices[2].uv[0]
			render2d.rectangle.Vertices[3].uv[1] = render2d.rectangle.Vertices[1].uv[1]
			render2d.rectangle.Vertices[5].uv = render2d.rectangle.Vertices[1].uv

			update_vbo()
		end
	end

	function render2d.SetRectColors(cbl, ctl, ctr, cbr)
		if not cbl then
			for i = 1, 6 do
				render2d.rectangle.Vertices[i].color = {1,1,1,1}
			end
		else
			render2d.rectangle.Vertices[1].color = {cbl:Unpack()}
			render2d.rectangle.Vertices[0].color = {ctl:Unpack()}
			render2d.rectangle.Vertices[2].color = {ctr:Unpack()}
			render2d.rectangle.Vertices[4].color = render2d.rectangle.Vertices[2].color
			render2d.rectangle.Vertices[3].color = {cbr:Unpack()}
			render2d.rectangle.Vertices[5].color = render2d.rectangle.Vertices[0]
		end

		update_vbo()
	end
end