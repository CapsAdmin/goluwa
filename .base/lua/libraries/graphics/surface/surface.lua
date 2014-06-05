local surface = _G.surface or {}


include("mesh2d.lua", surface)
include("markup/markup.lua", surface)

function surface.Initialize()		
	surface.rect_mesh = surface.CreateMesh() -- mesh defaults to rect, see mesh2d.lua
		
	surface.SetWhiteTexture()				 
	surface.InitializeFonts()
	
	surface.ready = true
end

if surface.ready then
	surface.Initialize()
end

function surface.IsReady()
	return surface.ready == true
end

function surface.GetScreenSize()
	return render.camera.w, render.camera.h
end

function surface.Start(...)	
	render.Start2D(...)
end

function surface.End(...)	
	render.End2D(...)
end

local X, Y = 0, 0
local W, H = 0, 0
local R,G,B,A,A2 = 1,1,1,1,1

include("fonts.lua", surface)

do -- orientation
	function surface.Translate(x, y)	
		render.Translate(math.ceil(tonumber(x)), math.ceil(tonumber(y)), 0)
	end
	
	function surface.Rotate(a)		
		render.Rotate(a, 0, 0, 1)
	end
	
	function surface.Scale(w, h)
		render.Scale(w, h or w, 1)
	end
		
	function surface.PushMatrix(x,y, w,h, a)
		render.PushWorldMatrix()

		if x and y then surface.Translate(x, y) end
		if w and h then surface.Scale(w, h) end
		if a then surface.Rotate(a) end
	end
	
	function surface.PopMatrix()
		render.PopWorldMatrix() 
	end
end

local COLOR = Color()
local oldr, oldg, oldb, olda

function surface.SetColor(r, g, b, a)
	oldr, oldg, oldb, olda = R,G,B,A
	
	if not g then
		a = r.a
		b = r.b
		g = r.g
		r = r.r
	end
	
	R = r
	G = g
	B = b
	
	if a then
		A = a
	end
	
	COLOR.r = R
	COLOR.g = G
	COLOR.b = B
	COLOR.a = A
	
	surface.mesh_2d_shader.global_color = COLOR
	
	return oldr, oldg, oldb, olda
end

function surface.GetColor(obj)
	if obj then
		return COLOR
	end
	
	return R, G, B, A
end


function surface.SetAlpha(a)
	olda = A
	
	A = a
	COLOR.a = a
	
	surface.mesh_2d_shader.global_color = COLOR
	
	return olda
end

function surface.GetAlpha()
	return A
end

function surface.SetAlphaMultiplier(a)
	A2 = a
	surface.fontmesh.alpha_multiplier = A2
	surface.mesh_2d_shader.alpha_multiplier = A2
end

function surface.SetTexture(tex)
	tex = tex or render.GetWhiteTexture()
	
	surface.bound_texture = tex
end

function surface.SetWhiteTexture()
	surface.bound_texture = render.GetWhiteTexture() 
end

function surface.GetTexture()
	return surface.bound_texture or render.GetWhiteTexture()
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
			last_xtl ~= surface.rect_mesh.buffer[1].uv.A or
			last_ytl ~= surface.rect_mesh.buffer[1].uv.B or
			last_xtr ~= surface.rect_mesh.buffer[3].uv.A or
			last_ytr ~= surface.rect_mesh.buffer[3].uv.B or
			
			last_xbl ~= surface.rect_mesh.buffer[0].uv.A or
			last_ybl ~= surface.rect_mesh.buffer[1].uv.B or
			last_xbr ~= surface.rect_mesh.buffer[4].uv.A or
			last_ybr ~= surface.rect_mesh.buffer[4].uv.B or
			
			last_color_bottom_left ~= surface.rect_mesh.buffer[0].color or
			last_color_top_left ~= surface.rect_mesh.buffer[1].color or
			last_color_top_right ~= surface.rect_mesh.buffer[2].color or
			last_color_bottom_right ~= surface.rect_mesh.buffer[4].color
		then
		
			surface.rect_mesh:UpdateBuffer()
			
			last_xtl = surface.rect_mesh.buffer[1].uv.A
			last_ytl = surface.rect_mesh.buffer[1].uv.B
			last_xtr = surface.rect_mesh.buffer[3].uv.A
			last_ytr = surface.rect_mesh.buffer[3].uv.B
			           
			last_xbl = surface.rect_mesh.buffer[0].uv.A
			last_ybl = surface.rect_mesh.buffer[1].uv.B
			last_xbr = surface.rect_mesh.buffer[4].uv.A
			last_ybr = surface.rect_mesh.buffer[4].uv.B
			
			last_color_bottom_left = surface.rect_mesh.buffer[0].color
			last_color_top_left = surface.rect_mesh.buffer[1].color
			last_color_top_right = surface.rect_mesh.buffer[2].color
			last_color_bottom_right = surface.rect_mesh.buffer[4].color	
		end		
	end

	function surface.SetRectUV(x,y, w,h, sx,sy)
		if not x then
			surface.rect_mesh.buffer[0].uv.A = 0
			surface.rect_mesh.buffer[0].uv.B = 1
			
			surface.rect_mesh.buffer[1].uv.A = 0
			surface.rect_mesh.buffer[1].uv.B = 0
			
			surface.rect_mesh.buffer[2].uv.A = 1
			surface.rect_mesh.buffer[2].uv.B = 0
			
			--
			
			surface.rect_mesh.buffer[3].uv = surface.rect_mesh.buffer[2].uv
			
			surface.rect_mesh.buffer[4].uv.A = 1
			surface.rect_mesh.buffer[4].uv.B = 1
			
			surface.rect_mesh.buffer[5].uv = surface.rect_mesh.buffer[0].uv	
		else			
			sx = sx or 1
			sy = sy or 1
			
			surface.rect_mesh.buffer[0].uv.A = x / sx
			surface.rect_mesh.buffer[0].uv.B = (y + h) / sy
			
			surface.rect_mesh.buffer[1].uv.A = x / sx
			surface.rect_mesh.buffer[1].uv.B = y / sy
			
			surface.rect_mesh.buffer[2].uv.A = (x + w) / sx
			surface.rect_mesh.buffer[2].uv.B = y / sy
			
			--
			
			surface.rect_mesh.buffer[3].uv = surface.rect_mesh.buffer[2].uv
			
			surface.rect_mesh.buffer[4].uv.A = (x + w) / sx
			surface.rect_mesh.buffer[4].uv.B = (y + h)
			
			surface.rect_mesh.buffer[5].uv = surface.rect_mesh.buffer[0].uv	
		end
	end

	local white_t = {1,1,1,1}

	function surface.SetRectColors(cbl, ctl, ctr, cbr)			
		if not cbl then
			for i = 1, 6 do
				surface.rect_mesh.buffer[i].color = white_t
			end
		else
			surface.rect_mesh.buffer[0].color = {cbl:Unpack()}
			surface.rect_mesh.buffer[1].color = {ctl:Unpack()}
			surface.rect_mesh.buffer[2].color = {ctr:Unpack()}
			surface.rect_mesh.buffer[3].color = surface.rect_mesh.buffer[2].color
			surface.rect_mesh.buffer[4].color = {cbr:Unpack()}
			surface.rect_mesh.buffer[5].color = surface.rect_mesh.buffer[1]
		end
		
		update_vbo()
	end
end

function surface.DrawRect(x,y, w,h, a, ox,oy)	
	render.PushWorldMatrix()			
		surface.Translate(x, y)
		
		if a then
			surface.Rotate(a)
		end
		
		if ox then
			surface.Translate(-ox, -oy)
		end
				
		surface.Scale(w, h)
		
		surface.mesh_2d_shader.tex = surface.bound_texture
		surface.mesh_2d_shader:Bind()
		surface.rect_mesh:Draw()
	render.PopWorldMatrix()
end

function surface.DrawLine(x1,y1, x2,y2, w, skip_tex, ...)
	
	w = w or 1
	
	if not skip_tex then 
		surface.SetWhiteTexture() 
	end
	
	local dx,dy = x2-x1, y2-y1
	local ang = math.atan2(dx, dy)
	local dst = math.sqrt((dx * dx) + (dy * dy))
		
	surface.DrawRect(x1, y1, w, dst, -math.deg(ang), ...)
end

function surface.StartClipping(x, y, w, h)
	render.SetScissor(x, y, w, h)
end

function surface.EndClipping()
	render.SetScissor()
end

function surface.GetMousePos()
	local x, y = window.GetMousePos():Unpack()
	return x, y
end

local last_x = 0
local last_y = 0
local last_diff = 0

function surface.GetMouseVel()
	local x, y = surface.GetMousePos()
	
	local vx = x - last_x
	local vy = y - last_y
	
	local time = timer.GetSystemTime()
	
	if last_diff < time then
		last_x = x
		last_y = y
		last_diff = time + 0.1
	end
	
	return vx, vy
end

include("poly.lua", surface)

do -- points
	local gl = require("lj-opengl")
	
	local SIZE = 1
	local STYLE = "smooth"

	function surface.SetPointStyle(style)
		if style == "smooth" then
			gl.Enable(gl.e.GL_POINT_SMOOTH)
		else
			gl.Disable(gl.e.GL_POINT_SMOOTH)
		end
		
		STYLE = style
	end
	
	function surface.GetPointStyle()
		return STYLE
	end
	
	function surface.SetPointSize(size)
		gl.PointSize(size)
		SIZE = size
	end
	
	function surface.GetPointSize()
		return SIZE
	end
	
	function surface.DrawPoint(x, y)
		gl.Disable(gl.e.GL_TEXTURE_2D)
		gl.Begin(gl.e.GL_POINTS)
			gl.Vertex2f(x, y)
		gl.End()
	end
end

event.AddListener("RenderContextInitialized", nil, surface.Initialize)

if RELOAD then
	surface.Initialize()
end

return surface
