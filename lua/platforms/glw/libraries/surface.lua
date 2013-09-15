surface = surface or {}

function surface.Initialize()
	surface.rectmesh = render.Create2DVBO({
		{pos = Vec2(0, 0), uv = Vec2(1, 1), color = Color(1,1,1,1)},
		{pos = Vec2(0, 1), uv = Vec2(1, 0), color = Color(1,1,1,1)},
		{pos = Vec2(1, 1), uv = Vec2(0, 0), color = Color(1,1,1,1)},
		{pos = Vec2(1, 1), uv = Vec2(0, 0), color = Color(1,1,1,1)},
		{pos = Vec2(1, 0), uv = Vec2(0, 1), color = Color(1,1,1,1)},
		{pos = Vec2(0, 0), uv = Vec2(1, 1), color = Color(1,1,1,1)},
	})
	
	surface.white_texture = Texture(64,64)
	surface.white_texture:Fill(function() return 255, 255, 255, 255 end)
end

function surface.Start()	
	render.Start2D()
end

do -- orientation
	function surface.Translate(x, y)
		gl.Translatef(x, y, 0)
	end
	
	function surface.Rotate(a)
		gl.Rotatef(a, 0, 0, 1)
	end
	
	function surface.Scale(w, h)
		gl.Scalef(w, h, 0)
	end
		
	function surface.PushMatrix(x,y, w,h, a)
		gl.PushMatrix()

		if x and y then surface.Translate(x, y, 0) end
		if w and h then surface.Scale(w, h, 1) end
		if a then surface.Rotate(a) end
	end
	
	function surface.PopMatrix()
		gl.PopMatrix() 
	end
end

function surface.Color(r,g,b,a)
	render.r = r
	render.g = g
	render.b = b
	render.a = a
end

function surface.SetWhiteTexture()
	surface.white_texture:Bind()
end

function surface.DrawRect(x,y, w,h, a)	
	gl.PushMatrix()		
		surface.Translate(x,y)
	
		if a then
			surface.Rotate(a)
			surface.Translate(-w*0.5,-h*0.5)
		end	
		
		surface.Scale(w,h)
	
		render.Draw2DVBO(surface.rectmesh)
	gl.PopMatrix()
end


function surface.DrawLine(x1,y1, x2,y2, w, skip_tex)
	
	w = w or 1
	
	if not skip_tex then 
		surface.SetWhiteTexture() 
	end
	
	local dx,dy = x1-x2, y1-y2
	local ang = math.atan2(dx, dy)
	local dst = math.sqrt((dx * dx) + (dy * dy))
	
	x1 = x1 - dx * 0.5
	y1 = y1 - dy * 0.5
	
	surface.DrawRect(x1, y1, w, dst, -math.deg(ang))
end

function surface.StartClipping(x, y, w, h)
	gl.Scissor(x, y, w, h)
	gl.Enable(e.GL_SCISSOR_TEST)
end

function surface.EndClipping()
	gl.Disable(e.GL_SCISSOR_TEST)
end

return surface