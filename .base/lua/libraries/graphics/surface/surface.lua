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

local gl = require("lj-opengl")

function surface.Start3D(pos, ang, scale)	
	local w, h = render.GetHeight(), render.GetHeight()
	
	pos = pos or Vec3(0, 0, 0)
	ang = ang or Ang3(0, 0, 0)
	scale = scale or Vec3(4, 4 * (w / h), 1)
		
	
	-- this is the amount the gui will translate upwards for each
	-- call to surface.PushMatrix
	surface.scale_3d = scale.z / (w + h) -- dunno
	surface.in_3d = true
	
	-- tell the 2d shader to use the 3d matrix instead
	surface.mesh_2d_shader.pvm_matrix = render.GetPVWMatrix3D

	render.PushWorldMatrix(pos, ang, Vec3(scale.x / w, scale.y / h, 1))
end

function surface.End3D()
	render.PopWorldMatrix()
	
	surface.mesh_2d_shader.pvm_matrix = render.GetPVWMatrix2D
	surface.in_3d = false
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
		
	function surface.PushMatrix(x,y, w,h, a, dont_multiply)
		render.PushWorldMatrix(nil, nil, nil, dont_multiply)

		if x and y then surface.Translate(x, y) end
		if w and h then surface.Scale(w, h) end
		if a then surface.Rotate(a) end
		
		if surface.in_3d then
			surface.push_count_3d = (surface.push_count_3d or -1) + 1
			render.Translate(0, 0, surface.push_count_3d * (surface.scale_3d or 1))
		end
	end
	
	function surface.PopMatrix()
		if surface.in_3d then
			surface.push_count_3d = (surface.push_count_3d or -1) - 1
		end
	
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
			last_xtl ~= surface.rect_mesh.vertices[1].uv.A or
			last_ytl ~= surface.rect_mesh.vertices[1].uv.B or
			last_xtr ~= surface.rect_mesh.vertices[3].uv.A or
			last_ytr ~= surface.rect_mesh.vertices[3].uv.B or
			
			last_xbl ~= surface.rect_mesh.vertices[0].uv.A or
			last_ybl ~= surface.rect_mesh.vertices[1].uv.B or
			last_xbr ~= surface.rect_mesh.vertices[4].uv.A or
			last_ybr ~= surface.rect_mesh.vertices[4].uv.B or
			
			last_color_bottom_left ~= surface.rect_mesh.vertices[0].color or
			last_color_top_left ~= surface.rect_mesh.vertices[1].color or
			last_color_top_right ~= surface.rect_mesh.vertices[2].color or
			last_color_bottom_right ~= surface.rect_mesh.vertices[4].color
		then
		
			surface.rect_mesh:UpdateBuffer()
			
			last_xtl = surface.rect_mesh.vertices[1].uv.A
			last_ytl = surface.rect_mesh.vertices[1].uv.B
			last_xtr = surface.rect_mesh.vertices[3].uv.A
			last_ytr = surface.rect_mesh.vertices[3].uv.B
			           
			last_xbl = surface.rect_mesh.vertices[0].uv.A
			last_ybl = surface.rect_mesh.vertices[1].uv.B
			last_xbr = surface.rect_mesh.vertices[4].uv.A
			last_ybr = surface.rect_mesh.vertices[4].uv.B
			
			last_color_bottom_left = surface.rect_mesh.vertices[0].color
			last_color_top_left = surface.rect_mesh.vertices[1].color
			last_color_top_right = surface.rect_mesh.vertices[2].color
			last_color_bottom_right = surface.rect_mesh.vertices[4].color	
		end		
	end

	function surface.SetRectUV(x,y, w,h, sx,sy)
		if not x then
			surface.rect_mesh.vertices[0].uv.A = 0
			surface.rect_mesh.vertices[0].uv.B = 1
			
			surface.rect_mesh.vertices[1].uv.A = 0
			surface.rect_mesh.vertices[1].uv.B = 0
			
			surface.rect_mesh.vertices[2].uv.A = 1
			surface.rect_mesh.vertices[2].uv.B = 0
			
			--
			
			surface.rect_mesh.vertices[3].uv = surface.rect_mesh.vertices[2].uv
			
			surface.rect_mesh.vertices[4].uv.A = 1
			surface.rect_mesh.vertices[4].uv.B = 1
			
			surface.rect_mesh.vertices[5].uv = surface.rect_mesh.vertices[0].uv	
		else			
			sx = sx or 1
			sy = sy or 1
			
			y = -y - h
			
			surface.rect_mesh.vertices[0].uv.A = x / sx
			surface.rect_mesh.vertices[0].uv.B = (y + h) / sy
			
			surface.rect_mesh.vertices[1].uv.A = x / sx
			surface.rect_mesh.vertices[1].uv.B = y / sy
			
			surface.rect_mesh.vertices[2].uv.A = (x + w) / sx
			surface.rect_mesh.vertices[2].uv.B = y / sy
			
			--
			
			surface.rect_mesh.vertices[3].uv = surface.rect_mesh.vertices[2].uv
			
			surface.rect_mesh.vertices[4].uv.A = (x + w) / sx
			surface.rect_mesh.vertices[4].uv.B = (y + h) / sy
			
			surface.rect_mesh.vertices[5].uv = surface.rect_mesh.vertices[0].uv	
		end
		
		update_vbo()
	end

	local white_t = {1,1,1,1}

	function surface.SetRectColors(cbl, ctl, ctr, cbr)			
		if not cbl then
			for i = 1, 6 do
				surface.rect_mesh.vertices[i].color = white_t
			end
		else
			surface.rect_mesh.vertices[0].color = {cbl:Unpack()}
			surface.rect_mesh.vertices[1].color = {ctl:Unpack()}
			surface.rect_mesh.vertices[2].color = {ctr:Unpack()}
			surface.rect_mesh.vertices[3].color = surface.rect_mesh.vertices[2].color
			surface.rect_mesh.vertices[4].color = {cbr:Unpack()}
			surface.rect_mesh.vertices[5].color = surface.rect_mesh.vertices[1]
		end
		
		update_vbo()
	end
end

function surface.DrawRect(x,y, w,h, a, ox,oy)	
	surface.PushMatrix()			
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
	surface.PopMatrix()
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

--[[
	1 2 3
	4 5 6
	7 8 9
]]

function surface.DrawNinePatch(x, y, w, h, patch_size, corner_size, u_offset, v_offset)
	u_offset = u_offset or 0
	v_offset = v_offset or 0
	
	local skin = surface.GetTexture()
		
	-- 1
	surface.SetRectUV(u_offset, v_offset, corner_size, corner_size, skin.w, skin.h)
	surface.DrawRect(x, y, corner_size, corner_size)
	
	-- 2
	surface.SetRectUV(u_offset + corner_size, v_offset, patch_size - corner_size*2, corner_size, skin.w, skin.h)
	surface.DrawRect(x + corner_size, y, w - corner_size*2, corner_size)
	
	-- 3
	surface.SetRectUV(u_offset + patch_size - corner_size, v_offset, corner_size, corner_size, skin.w, skin.h)
	surface.DrawRect(x + w - corner_size, y, corner_size, corner_size)
	
	-- 4
	surface.SetRectUV(u_offset, v_offset + corner_size, corner_size, patch_size - corner_size*2, skin.w, skin.h)
	surface.DrawRect(x, y + corner_size, corner_size, h - corner_size*2)
	
	-- 5
	surface.SetRectUV(u_offset + corner_size, v_offset + corner_size, patch_size - corner_size*2, patch_size - corner_size*2, skin.w, skin.h)
	surface.DrawRect(x + corner_size, y + corner_size, w - corner_size*2, h - corner_size*2)
	
	-- 6
	surface.SetRectUV(u_offset + patch_size - corner_size, v_offset + corner_size, corner_size, patch_size - corner_size*2, skin.w, skin.h)
	surface.DrawRect(x + w - corner_size, y + corner_size, corner_size, h - corner_size*2)
	
	-- 7
	surface.SetRectUV(u_offset, v_offset + patch_size - corner_size, corner_size, corner_size, skin.w, skin.h)
	surface.DrawRect(x, y + h - corner_size, corner_size, corner_size)
	
	-- 8
	surface.SetRectUV(u_offset + corner_size, v_offset + patch_size - corner_size, patch_size - corner_size*2, corner_size, skin.w, skin.h)
	surface.DrawRect(x + corner_size, y + h - corner_size, w - corner_size*2, corner_size)
	
	-- 9
	surface.SetRectUV(u_offset + patch_size - corner_size, v_offset + patch_size - corner_size, corner_size, corner_size, skin.w, skin.h)
	surface.DrawRect(x + w - corner_size, y + h - corner_size, corner_size, corner_size)
	
	surface.SetRectUV(0,0,1,1)
end

function surface.StartClipping(x, y, w, h)
	x, y = surface.WorldToLocal(-x, -y)
	render.SetScissor(-x, -y, w, h)
end

function surface.EndClipping()
	render.SetScissor()
end

local gl = require("lj-opengl")

function surface.StartClipping2(x, y, w, h)
	gl.Enable(gl.e.GL_STENCIL_TEST)
	
	gl.StencilFunc(gl.e.GL_ALWAYS, 1, 0xFF) -- Set any stencil to 1
	gl.StencilOp(gl.e.GL_KEEP, gl.e.GL_KEEP, gl.e.GL_REPLACE)
	gl.StencilMask(0xFF) -- Write to stencil buffer
	gl.DepthMask(gl.e.GL_FALSE) -- Don't write to depth buffer
	gl.Clear(gl.e.GL_STENCIL_BUFFER_BIT) -- Clear stencil buffer (0 by default)
	
	surface.DrawRect(x, y, w, h)
	
	gl.StencilFunc(gl.e.GL_EQUAL, 1, 0xFF) -- Pass test if stencil value is 1
    gl.StencilMask(0x00) -- Don't write anything to stencil buffer
    gl.DepthMask(gl.e.GL_TRUE) -- Write to depth buffer	
end


function surface.EndClipping2()
	gl.Disable(gl.e.GL_STENCIL_TEST)
end

function surface.GetMousePos()
	return window.GetMousePos():Unpack()
end

function surface.WorldToLocal(x, y)
	if surface.in_3d then
		y = -y
		local x, y = (render.matrices.world * render.matrices.view_3d):TransformVector(Vec3(x, y, 0)):Unpack()
		return x, y
	else	
		local x, y = (render.matrices.world * render.matrices.view_2d):TransformVector(Vec3(x, y, 0)):Unpack()
		return x, y
	end
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
