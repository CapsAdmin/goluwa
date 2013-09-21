surface = surface or {}

function surface.Initialize()
	surface.rectmesh = render.Create2DVBO({
		{pos = Vec2(0, 0), uv = Vec2(0, 1), color = Color(1,1,1,1)},
		{pos = Vec2(0, 1), uv = Vec2(0, 0), color = Color(1,1,1,1)},
		{pos = Vec2(1, 1), uv = Vec2(1, 0), color = Color(1,1,1,1)},

		{pos = Vec2(1, 1), uv = Vec2(1, 0), color = Color(1,1,1,1)},
		{pos = Vec2(1, 0), uv = Vec2(1, 1), color = Color(1,1,1,1)},
		{pos = Vec2(0, 0), uv = Vec2(0, 1), color = Color(1,1,1,1)},
	})
	
	surface.white_texture = Texture(64,64)
	surface.white_texture:Fill(function() return 255, 255, 255, 255 end)
	
	surface.InitFreetype()
	
	surface.ready = true
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
local A = 1

do -- fonts
	-- this might not be the best way to do it but it should do for now

	freetype.debug = true
	
	surface.ft = surface.ft or {}
	local ft = surface.ft
	
	local DPI = 72
	
	ft.fonts = ft.fonts or {}
	ft.current_font = ft.current_font

	-- clear font data for reloading
	for k,v in pairs(ft.fonts) do
		v.glyphs = {}
		v.strings = {}
	end
	
	function surface.InitFreetype()
		if ft.ptr then
			surface.SetFont("default")
		return end
		
		local ptr = ffi.new("FT_Library[1]")  
		freetype.InitFreeType(ptr)
		ptr = ptr[0]
		ft.ptr = ptr
		surface.SetFont(surface.CreateFont("default"))	
				
		surface.fontmesh = render.Create2DVBO({
			{pos = Vec2(0, 0), uv = Vec2(0, 0), color = Color(1,1,1,1)},
			{pos = Vec2(0, 1), uv = Vec2(0, 1), color = Color(1,1,1,1)},
			{pos = Vec2(1, 1), uv = Vec2(1, 1), color = Color(1,1,1,1)},

			{pos = Vec2(1, 1), uv = Vec2(1, 1), color = Color(1,1,1,1)},
			{pos = Vec2(1, 0), uv = Vec2(1, 0), color = Color(1,1,1,1)},
			{pos = Vec2(0, 0), uv = Vec2(0, 0), color = Color(1,1,1,1)},
		})
	end

	function surface.CreateFont(name, info)
		if not ft.ptr then return end
		
		info = info or {}

		info.path = info.path or "fonts/unifont.ttf"
		info.size = info.size or 14
		info.spacing = info.spacing or 0
		info.res_multiplier = info.res_multiplier or 1

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

					w = w + tex.metrics.w2 + info.spacing
					
					data.w = w
					
					if tex.metrics.h > data.h then
						data.h = tex.metrics.h
					end
				end
			end
			
			ft.current_font.strings[str] = data
		end 

		for _, glyph in pairs(data.glyphs) do
			glyph.tex:Bind()			
			surface.PushMatrix(X + glyph.x, Y + glyph.y, glyph.w, glyph.h)
				render.Draw2DVBO(surface.fontmesh, 1)
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
	if a then
		render.a = a * A
	end
end

function surface.SetAlphaMultiplier(a)
	A = a
end

function surface.SetWhiteTexture()
	surface.white_texture:Bind()
end

-- completeness?
function surface.SetTexture(tex)
	if not tex then
		surface.SetWhiteTexture()
	else
		tex:Bind()
	end
end

function surface.DrawRect(x,y, w,h, a)	
	gl.PushMatrix()			
		surface.Translate(x,y)
			
		if a then
			surface.Translate(w*0.5, h*0.5)
			surface.Rotate(a)
			surface.Translate(w*-0.5, h*-0.5)
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