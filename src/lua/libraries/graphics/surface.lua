local render2d = _G.render2d or {}

local gl = desire("libopengl")
local render = render

local SHADER = {
	name = "mesh_2d",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
			{color = "vec4"},
		},
		source = [[
			out highp vec4 frag_color;

			void main()
			{
				vec4 tex_color = texture(lua[tex = "sampler2D"], uv);
				vec4 override = lua[color_override = Color(0,0,0,0)];

				if (override.r > 0) tex_color.r = override.r;
				if (override.g > 0) tex_color.g = override.g;
				if (override.b > 0) tex_color.b = override.b;
				if (override.a > 0) tex_color.a = override.a;

				frag_color = tex_color * color * lua[global_color = Color(1,1,1,1)];
				frag_color.a = frag_color.a * lua[alpha_multiplier = 1];

				vec3 hsv_mult = lua[hsv_mult = Vec3(1,1,1)];

				if (hsv_mult != vec3(1,1,1))
				{
					frag_color.rgb = hsv2rgb(rgb2hsv(frag_color.rgb) * hsv_mult);
				}
			}
		]]
	}
}

local RECT = {
	{pos = {0, 1, 0}, uv = {0, 0}, color = {1,1,1,1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1,1,1,1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {1, 0, 0}, uv = {1, 1}, color = {1,1,1,1}},
	{pos = {1, 1, 0}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {0, 0, 0}, uv = {0, 1}, color = {1,1,1,1}},
}

function render2d.CreateMesh(vertices, indices)
	vertices = vertices or RECT
	return render.CreateVertexBuffer(render2d.shader, vertices, indices)
end

render2d.shader = render2d.shader or NULL

function render2d.Initialize()
	local shader = render.CreateShader(SHADER)
	render2d.shader = shader

	render2d.rectangle = render2d.CreateMesh()
	render2d.rectangle:SetDrawHint("static")

	render2d.SetTexture()

	render2d.ready = true
end

function render2d.IsReady()
	return render2d.ready == true
end

function render2d.GetSize()
	return camera.camera_2d.Viewport.w, camera.camera_2d.Viewport.h
end

do -- render world matrix helpers
	local ceil =math.ceil
	function render2d.Translate(x, y, z)
		camera.camera_2d:TranslateWorld(ceil(x), ceil(y), z or 0)
	end

	function render2d.Translatef(x, y, z)
		camera.camera_2d:TranslateWorld(x, y, z or 0)
	end

	function render2d.Rotate(a)
		camera.camera_2d:RotateWorld(a, 0, 0, 1)
	end

	function render2d.Scale(w, h, z)
		camera.camera_2d:ScaleWorld(w, h or w, z or 1)
	end

	function render2d.Shear(x, y)
		camera.camera_2d:ShearWorld(x, y, 0)
	end

	function render2d.LoadIdentity()
		camera.camera_2d:LoadIdentityWorld()
	end

	function render2d.PushMatrix(x,y, w,h, a, dont_multiply)
		camera.camera_2d:PushWorld(nil, dont_multiply)

		if x and y then render2d.Translate(x, y) end
		if w and h then render2d.Scale(w, h) end
		if a then render2d.Rotate(a) end
	end

	function render2d.PopMatrix()
		camera.camera_2d:PopWorld()
	end

	function render2d.SetWorldMatrix(mat)
		camera.camera_2d:SetWorld(mat)
	end

	function render2d.GetWorldMatrix()
		return camera.camera_2d:GetWorld()
	end

	function render2d.ScreenToWorld(x, y)
		return camera.camera_2d:ScreenToWorld(x, y)
	end

	function render2d.Start3D2D(pos, ang, scale)
		camera.camera_2d:Start3D2DEx(pos, ang, scale)
	end

	function render2d.End3D2D()
		camera.camera_2d:End3D2D()
	end
end

do
	function render2d.SetColor(r, g, b, a)
		render2d.shader.global_color.r = r
		render2d.shader.global_color.g = g
		render2d.shader.global_color.b = b
		render2d.shader.global_color.a = a or render2d.shader.global_color.a
	end

	function render2d.GetColor()
		return render2d.shader.global_color:Unpack()
	end

	utility.MakePushPopFunction(render2d, "Color")

	function render2d.SetAlpha(a)
		render2d.shader.global_color.a = a
	end

	function render2d.GetAlpha()
		return render2d.shader.global_color.a
	end

	utility.MakePushPopFunction(render2d, "Alpha")
end

function render2d.SetAlphaMultiplier(a)
	render2d.shader.alpha_multiplier = a or render2d.shader.alpha_multiplier
end

function render2d.GetAlphaMultiplier()
	return render2d.shader.alpha_multiplier
end

utility.MakePushPopFunction(render2d, "AlphaMultiplier")

function render2d.SetTexture(tex)
	render2d.shader.tex = tex
end

function render2d.GetTexture()
	return render2d.shader.tex
end

utility.MakePushPopFunction(render2d, "Texture")

function render2d.SetTexture()
	render2d.shader.tex = render.GetWhiteTexture()
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

		render2d.rectangle:Draw()
	render2d.PopMatrix()
end

function render2d.SetScissor(x, y, w, h)
	if not x then
		render.SetScissor()
	else
		x, y = render2d.ScreenToWorld(-x, -y)
		render.SetScissor(-x, -y, w, h)
	end
end

do
    local stack = {}
	local depth = 1

	local stencil_debug_tex

	function render2d.DrawStencilTexture()

	    stencil_debug_tex = stencil_debug_tex or render.CreateBlankTexture(Vec2(render.GetWidth(), render.GetHeight()))

		local stencilStateArray = ffi.new("GLboolean[1]", 0)
		gl.GetBooleanv("GL_STENCIL_TEST", stencilStateArray)

		--if wait(0.25) then

			gl.Enable("GL_STENCIL_TEST")

			local stencilWidth = render.GetWidth()
			local stencilHeight = render.GetHeight()
			local stencilSize = stencilWidth*stencilHeight
			local stencilData = ffi.new("unsigned char[?]", stencilSize)
			gl.ReadPixels(0, 0, stencilWidth, stencilHeight, "GL_STENCIL_INDEX", "GL_UNSIGNED_BYTE", stencilData)

			--[[for y = 0, stencilHeight-1 do
				for x = 0, stencilWidth-1 do
					local i = y*stencilWidth + x
					io.stdout:write(string.format("%02X ", stencilData[i]))
				end
				io.stdout:write("\n")
			end]]

			local y = math.floor(stencilHeight/2)
			for x = math.floor(stencilWidth/2-10), math.floor(stencilWidth/2+10) do
				local i = y*stencilWidth + x
				stencilData[i] = 1
			end

			local maxValue = 0
			for i = 0, stencilSize-1 do
				maxValue = math.max(maxValue, stencilData[i])
			end

			local scale = 255/maxValue
			for i = 0, stencilSize-1 do
				stencilData[i] = math.floor(stencilData[i]*scale)
			end

			stencil_debug_tex:Upload(stencilData, {upload_format = "red", internal_format = "r8"})
		--end

		render2d.PushMatrix()
		render2d.LoadIdentity()
    		render2d.SetColor(1,1,1,1)
    		render2d.SetTexture(stencil_debug_tex)
    		gl.Disable("GL_STENCIL_TEST")
    		render2d.DrawRect(64,64,128,128)
    		gl.Enable("GL_STENCIL_TEST")
		render2d.PopMatrix()

		if stencilStateArray[0] == 0 then
		    gl.Disable("GL_STENCIL_TEST")
	    end
    end

	function render2d.EnableStencilClipping()
		--assert(#stack == 0, "I think this is good assertion, wait, you may want to draw something regardless of clipping, so nvm")
		--table.clear(stack)
		-- that means the stack should not be emptied, in case you want to disobey clipping?

		-- Don't consider depth buffer while stenciling or drawing
		gl.DepthMask(0)
		gl.DepthFunc("GL_ALWAYS")

		-- Enable stencil test
		gl.Enable("GL_STENCIL_TEST")

		-- Write to all stencil bits
		gl.StencilMask(0xFF)

		-- Don't consider stencil buffer while clearing it
		gl.StencilFunc("GL_ALWAYS", 0, 0xFF)

		-- Clear the stencil buffer to zero
		gl.ClearStencil(0)
		gl.Clear("GL_STENCIL_BUFFER_BIT")

		-- Stop writing to stencil
		gl.StencilMask("GL_FALSE")
	end

	function render2d.DisableStencilClipping()
		-- disable stencil completely, how2
		gl.Disable("GL_STENCIL_TEST")
	end

    --[[
		it works like this:

		00000000000000000000000000
	    push frame; depth = 1
    		00011111111111111000000000
		    push panel; depth = 2
        		00011222222222211000000000
        		push button1; depth = 3
        		    00011233322222211000000000
    		    pop button1; depth = 2
    		    00011222222222211000000000
    		    push button2; depth = 3
    		        00011222222333211000000000
		        pop button2; depth = 2
		        00011222222222211000000000
	        pop panel; depth = 1
	        00011111111111111000000000
        pop frame; depth = 0
        00000000000000000000000000

        gl.StencilFunc("GL_EQUAL", depth, 0xFF)
        means
        only draw if stencil == current depth
	]]

	local function update_stencil_buffer(mode)

		-- Write to all stencil bits
		gl.StencilMask(0xFF)

		-- For each object on the stack, increment/decrement any pixel it touches by 1
		gl.DepthMask(0) -- Don't write to depth buffer
		gl.StencilFunc("GL_NEVER", 0, 0xFF) -- Update stencil regardless of current value
		gl.StencilOp(
			mode, -- For each pixel white pixel, increment/decrement
			"GL_REPLACE", -- Ignore depth buffer
			"GL_REPLACE" -- Ignore depth buffer
		)

		local data = stack[depth]
		data.func(unpack(data.args))

		-- Stop writing to stencil
		gl.StencilMask("GL_FALSE")

		-- Now make future drawing obey stencil buffer
		gl.DepthMask(1) -- Write to depth buffer
		gl.StencilFunc("GL_EQUAL", depth-1, 0xFF) -- Pass test if stencil value is equal to depth
	end

	function render2d.PushClipFunction(draw_func, ...)
	    depth = depth+1

		stack[depth] = {func = draw_func, args = {...}}

		update_stencil_buffer("GL_INCR")
	end

	function render2d.PopClipFunction()
		update_stencil_buffer("GL_DECR")

		stack[depth] = nil
		depth = depth-1

		if depth < 1 then
			error("stack underflow", 2)
		end
	end
end

do
	local X, Y, W, H
	function render2d.EnableClipRect(x, y, w, h)
		gl.Enable("GL_STENCIL_TEST")

		gl.StencilFunc("GL_ALWAYS", 1, 0xFF) -- Set any stencil to 1
		gl.StencilOp("GL_KEEP", "GL_KEEP", "GL_REPLACE")
		gl.StencilMask(0xFF) -- Write to stencil buffer
		render.GetFrameBuffer():ClearStencil(0xFF) -- Clear stencil buffer (0 by default)

		render2d.PushColor(0,0,0,0)
		render2d.DrawRect(x, y, w, h)
		render2d.PopColor()

		gl.StencilFunc("GL_EQUAL", 1, 0xFF) -- Pass test if stencil value is 1
		gl.StencilMask(0x00) -- Don't write anything to stencil buffer

		X = x
		Y = y
		W = w
		H = h
	end

	function render2d.GetClipRect()
		return X or 0, Y or 0, W or render.GetWidth(), H or render.GetHeight()
	end

	function render2d.DisableClipRect()
		gl.Disable("GL_STENCIL_TEST")
	end
end

function render2d.SetHSV(h,s,v)
	render2d.shader.hsv_mult.x = h
	render2d.shader.hsv_mult.y = s
	render2d.shader.hsv_mult.z = v
end

function render2d.GetHSV()
	return render2d.shader.hsv_mult:Unpack()
end

utility.MakePushPopFunction(render2d, "HSV")

do -- effects
	function render2d.EnableEffects(b)
		if b then
			local fb = render.CreateFrameBuffer()
			fb:SetTexture(1, render.CreateBlankTexture(render.GetScreenSize()))
			fb:SetTexture("depth_stencil", {internal_format = "depth_stencil", size = render.GetScreenSize()})
			fb:CheckCompletness()

			render2d.framebuffer = fb
		elseif render2d.framebuffer then
			render2d.framebuffer = nil
		end
	end

	render2d.effects = {}

	function render2d.AddEffect(name, pos, ...)
		render2d.RemoveEffect(name)

		table.insert(render2d.effects, {name = name, pos = pos, args = {...}})

		table.sort(render2d.effects, function(a, b)
			return a.pos > b.pos
		end)
	end

	function render2d.RemoveEffect(name)
		for i, info in ipairs(render2d.effects) do
			if info.name == name then
				table.remove(render2d.effects, i)
			end
		end

		table.sort(render2d.effects, function(a, b)
			return a.pos > b.pos
		end)
	end

	function render2d.Start()
		if render2d.framebuffer then
			render2d.framebuffer:Begin()
		end
	end

	function render2d.End()
		if render2d.framebuffer then
			for _, info in ipairs(render2d.effects) do
				render2d.framebuffer:GetTexture():Shade(unpack(info.args))
			end

			render2d.framebuffer:End()

			render2d.framebuffer:Blit(render.GetScreenFrameBuffer())
		end
	end
end

if RELOAD then
	render2d.Initialize()
end

return render2d
