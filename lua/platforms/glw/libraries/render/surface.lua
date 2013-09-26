surface = surface or {}

surface.ft = surface.ft or {}
local ft = surface.ft

function surface.Initialize()
		
	surface.rectmesh = render.CreateMesh2D({
		{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
		{pos = {0, 1}, uv = {0, 0}, color = {1,1,1,1}},
		{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},

		{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},
		{pos = {1, 0}, uv = {1, 1}, color = {1,1,1,1}},
		{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
	})
		
	surface.white_texture = Texture(64,64)
	surface.white_texture:Fill(function() return 255, 255, 255, 255 end)
	surface.SetWhiteTexture()
	
	if not ft.ptr then
		local ptr = ffi.new("FT_Library[1]")  
		freetype.InitFreeType(ptr)
		ptr = ptr[0]
		ft.ptr = ptr	
	end
				 
	do
		local shader = render.CreateSuperShader("glyph", {
			fragment = {
				uniform = {
					smoothness = 0
				},
				source = [[
					out vec4 frag_color;

					void main()
					{								
						float mask = texture2D(texture, uv).a;

						frag_color.rgb = global_color.rgb;
						
						mask = pow(mask, 0.75);
				 		mask *= smoothstep(0.25, 0.75, mask);
						mask = pow(mask, 1.25);
						
						frag_color.a = mask;
					}
				]],
			},
		}, "mesh_2d")
		
		local mesh = shader:CreateVertexBuffer({
			{pos = {0, 0}, uv = {0, 0}, color = {1,1,1,1}},
			{pos = {0, 1}, uv = {0, 1}, color = {1,1,1,1}},
			{pos = {1, 1}, uv = {1, 1}, color = {1,1,1,1}},

			{pos = {1, 1}, uv = {1, 1}, color = {1,1,1,1}},
			{pos = {1, 0}, uv = {1, 0}, color = {1,1,1,1}},
			{pos = {0, 0}, uv = {0, 0}, color = {1,1,1,1}},
		})
		
		mesh.model_matrix = render.GetModelMatrix
		mesh.camera_matrix = render.GetCameraMatrix	
		
		surface.fontmesh = mesh
		surface.fontshader = shader
	end

	surface.SetFont(surface.CreateFont("default"))	
		
	surface.ready = true
end

if surface.ready then
	surface.Initialize()
end

function surface.IsReady()
	return surface.ready == true
end

function surface.GetScreenSize()
	return render.w, render.h
end

function surface.Start()	
	render.Start2D()
end


local X, Y = 0, 0
local W, H = 0, 0
local R,G,B,A,A2 = 1,1,1,1,1

do -- fonts
	-- this might not be the best way to do it but it should do for now

	freetype.debug = true
		
	local DPI = 72
	
	ft.fonts = ft.fonts or {}
	ft.current_font = ft.current_font

	-- clear font data for reloading
	for k,v in pairs(ft.fonts) do
		v.glyphs = {}
		v.strings = {}
	end
	
	function surface.CreateFont(name, info)
		if not ft.ptr then return end
		
		info = info or {}

		info.path = info.path or "fonts/arial.ttf"
		info.size = info.size or 14    
		info.spacing = info.spacing or 1 
		info.res_multiplier = info.res_multiplier or 1
		
		if not info.smoothness and info.size > 16 then
			info.smoothness = 0.1
		end
		
		info.smoothness = 0.01   

		-- create a face from memory
		local data = vfs.Read(info.path, "rb") 
		
		local face = ffi.new("FT_Face[1]")   
		freetype.NewMemoryFace(ft.ptr, data, #data, 0, face)   
		face = face[0]	

		freetype.SetCharSize(face, 0, info.size * DPI * info.res_multiplier, DPI, DPI)
		
		ft.fonts[name] = 
		{
			name = name, 
			face = face, 
			glyphs = {}, 
			strings = {},
			info = info,
			font_data = data, -- not doing this will make freetype crash because the data gets garbage collected
		}		
		
		return name
	end
	
	function surface.SetFont(name)
		ft.current_font = ft.fonts[name] or ft.fonts.default
	end

	function surface.GetFont()
		return ft.current_font and ft.current_font.name
	end
	
	local X, Y = 0,0
	
	function surface.SetTextPos(x, y)
		X = x
		Y = y
	end
			
	function surface.DrawText(str)
		if not ft.ptr or not ft.current_font then return end
		
		str = tostring(str) 

		local face = ft.current_font.face
		local data = ft.current_font.strings[str]
		
		if not data then
			data = {glyphs = {}, h = 0, w = 0}
			
			local info = ft.current_font.info
			local w = 0
			
			for _, char in pairs(utf8.totable(str)) do
				local byte = utf8.byte(char)
				if byte == -1 then byte = char:byte() end
				
				if char == " " then	
					w = w + ft.current_font.info.size / 4
				else				
					local tex = ft.current_font.glyphs[char]
					
					if not tex then
						local i = freetype.GetCharIndex(face, byte) 
						freetype.LoadGlyph(face, i, 0)
						freetype.RenderGlyph(face.glyph, 0) 
						
						local bitmap = face.glyph.bitmap 
						local w = bitmap.width
						local h = bitmap.rows	 
						local buffer = bitmap.buffer	 
						
						tex = Texture(
							w, h, buffer, 
							{
								format = e.GL_ALPHA, 
								internal_format = e.GL_ALPHA8, 
								stride = 1, 
								mip_map_levels = 1,  
								mag_filter = e.GL_LINEAR,
								min_filter = e.GL_LINEAR_MIPMAP_LINEAR,
								mip_map_levels = 1,
								
								wrap_r = e.GL_MIRRORED_REPEAT,
								wrap_s = e.GL_MIRRORED_REPEAT,
								wrap_t = e.GL_MIRRORED_REPEAT,
							}  
						) 
				
						local m = face.glyph.metrics

						tex.metrics = 
						{
							w = m.width / DPI,
							h = m.height / DPI,
							x = m.horiBearingX / DPI,
							y = m.horiBearingY / DPI,
							w2 = m.horiAdvance / DPI,
						}
						ft.current_font.glyphs[char] = tex
					end
										
					local glyph = {}
					
					glyph.tex = tex
					glyph.x = w
					glyph.y = -tex.metrics.y + info.size*0.5
					
					glyph.x = glyph.x / info.res_multiplier
					glyph.y = glyph.y / info.res_multiplier
					glyph.w = tex.w / info.res_multiplier
					glyph.h = tex.h / info.res_multiplier
					
					table.insert(data.glyphs, glyph)

					if info.monospace then
						w = w + info.spacing
					else
						w = w + tex.metrics.w2 + info.spacing
					end
					
					data.w = w
					
					if tex.metrics.h > data.h then
						data.h = tex.metrics.h
					end
				end
			end
			
			ft.current_font.strings[str] = data
		end 

		for _, glyph in pairs(data.glyphs) do
			surface.PushMatrix(X + glyph.x, Y + glyph.y, glyph.w, glyph.h)
				surface.fontmesh.texture = glyph.tex
				surface.fontmesh.global_color = surface.rectmesh.global_color
				surface.fontmesh.smoothness = ft.current_font.info.smoothness 
				surface.fontmesh:Draw()
			surface.PopMatrix()
		end
	end 
	
	function surface.GetTextSize(str)
		local data = ft.current_font and ft.current_font.strings[str]
		
		if data then
			return data.w, data.h
		elseif ft.current_font then
			surface.DrawText(str) 
			data = ft.current_font and ft.current_font.strings[str]
			if data then
				return data.w, data.h
			end
		end
		
		return 0, 0
	end
end

do -- orientation
	function surface.Translate(x, y)	
		X = x
		Y = y
		
		render.Translate(x, y, 0)
	end
	
	function surface.Rotate(a)		
		render.Rotate(a, 0, 0, 1)
	end
	
	function surface.Scale(w, h)
		render.Scale(w, h, 0)
	end
		
	function surface.PushMatrix(x,y, w,h, a)
		render.PushMatrix()

		if x and y then surface.Translate(x, y, 0) end
		if w and h then surface.Scale(w, h, 1) end
		if a then surface.Rotate(a) end
	end
	
	function surface.PopMatrix()
		render.PopMatrix() 
	end
end

local c = Color()

function surface.Color(r,g,b,a)
	R = r
	G = g
	B = b
	if a then
		A = a * A2
	end
	
	c.r = R
	c.g = G
	c.b = B
	c.a = A
	
	surface.rectmesh.global_color = c
end

function surface.SetAlphaMultiplier(a)
	A2 = a
end

function surface.SetTexture(tex)
	tex = tex or surface.white_texture
	
	surface.rectmesh.texture = tex
	surface.bound_texture = tex
end

surface.SetWhiteTexture = surface.SetTexture

function surface.GetTexture()
	return surface.bound_texture or surface.white_texture
end

function surface.DrawRect(x,y, w,h, a)	
	render.PushMatrix()			
		render.Translate(x,y,0)

		if a then
			render.Translate(w*0.5, h*0.5,0)
			render.Rotate(a, 0, 0, 1)
			render.Translate(w*-0.5, h*-0.5,0)
		end	
			
		render.Scale(w,h,0)
		surface.rectmesh:Draw()
	render.PopMatrix()
end

function surface.DrawRectEx(x,y, w,h, a, ox,oy)
	render.PushMatrix()			
		render.Translate(x,y,0)
		render.Rotate(a, 0, 0, 1)
		render.Translate(-ox, -oy,0)
		render.Scale(w,h,0)
		surface.rectmesh:Draw()
	render.PopMatrix()
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
	render.ScissorRect(x, y, w, h)
end

function surface.EndClipping()
	render.ScissorRect()
end

return surface