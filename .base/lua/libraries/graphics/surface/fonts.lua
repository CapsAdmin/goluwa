local surface = (...) or _G.surface

local freetype = require("lj-freetype")

surface.ft = surface.ft or {}
local ft = surface.ft
local create_font_queue = {}

function surface.InitializeFonts()
	if not ft.ptr then
		local ptr = ffi.new("FT_Library[1]")  
		freetype.InitFreeType(ptr)
		ptr = ptr[0]
		ft.ptr = ptr	
	end

	local shader = render.CreateShader({
		name = "glyph",
		base = "mesh_2d",
		fragment = {
			uniform = {
				smoothness = 0,
				alpha_multiplier = 1,
			},
			source = [[
				out highp vec4 frag_color;

				void main()
				{								
					vec4 font_color = texture(tex, uv);
					highp float mask = font_color.a;
					
					if (smoothness > 0.00)
					{
						mask = pow(mask, 0.75);
						mask *= smoothstep(0.25, 0.75 * smoothness, mask);
						mask = pow(mask, 1.25);
						mask *= smoothness * smoothness * smoothness;
					}
					
					frag_color.rgb = font_color.rgb * global_color.rgb;
					frag_color.a = mask * alpha_multiplier;
				}
			]],
		},
	})
	
	shader.pvm_matrix = render.GetPVWMatrix2D
	surface.fontshader = shader		
	
	surface.fontmesh = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 0}, color = {1,1,1,1}},
		{pos = {0, 1}, uv = {0, 1}, color = {1,1,1,1}},
		{pos = {1, 1}, uv = {1, 1}, color = {1,1,1,1}},

		{pos = {1, 1}, uv = {1, 1}, color = {1,1,1,1}},
		{pos = {1, 0}, uv = {1, 0}, color = {1,1,1,1}},
		{pos = {0, 0}, uv = {0, 0}, color = {1,1,1,1}},
	})

	if create_font_queue then
		for k,v in pairs(create_font_queue) do
			local ok, err = pcall(surface.CreateFont, unpack(v))
			if not ok then logn("queued surface.CreateFont error: ", err) end
		end
		
		create_font_queue = nil
	end
	
	surface.SetFont(surface.CreateFont("default", {read_speed = 50}))	
end

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

	local allowed_types = {
		woff = true,
		truetype = true,
	}  
	
	local dirs = {
		Vec2(1,0),
		Vec2(0,1),
		
		Vec2(-1,0),
		Vec2(0,-1),
	}
	
	local function blur_texture(tex, info)
		info.blur.color = info.blur.color or Color(0,0,0,0)
		info.blur.size = info.blur.size or 1
		info.blur.step_size = info.blur.step_size or 1
		info.blur.alpha = info.blur.alpha or 1
		for x = -1, 1, info.blur.step_size do
		for y = -1, 1, info.blur.step_size do
			tex:Shade([[	
				out highp vec4 out_color;
				const float pi = 3.14159265;
      
				void main()
				{
					float avg = 0;
					
					float w = dir.x / size.x;
					float h = dir.y / size.y;
					
					avg += texture(self, vec2(uv.x - 4.0*w, uv.y - 4.0*h)).a * 0.0162162162;
					avg += texture(self, vec2(uv.x - 3.0*w, uv.y - 3.0*h)).a * 0.0540540541;
					avg += texture(self, vec2(uv.x - 2.0*w, uv.y - 2.0*h)).a * 0.1216216216;
					avg += texture(self, vec2(uv.x - 1.0*w, uv.y - 1.0*h)).a * 0.1945945946;

					avg += texture(self, uv).a * 0.2270270270;

					avg += texture(self, vec2(uv.x + 1.0*w, uv.y + 1.0*h)).a * 0.1945945946;
					avg += texture(self, vec2(uv.x + 2.0*w, uv.y + 2.0*h)).a * 0.1216216216;
					avg += texture(self, vec2(uv.x + 3.0*w, uv.y + 3.0*h)).a * 0.0540540541;
					avg += texture(self, vec2(uv.x + 4.0*w, uv.y + 4.0*h)).a * 0.0162162162;
										
					out_color.a = min(avg, 0.3 * alpha);
					out_color.rgb = blur_color.rgb / 16.0;
					out_color = out_color + texture(self, uv);
					out_color = vec4(1,0,1,1);
				}
			]], 
			{		 
				dir = Vec2(x, y) * info.blur.size,
				alpha = info.blur.alpha,
				blur_color = info.blur.color,
			})
		end
		end
	end

		
	function surface.CreateFont(name, info)
		if not ft.ptr then 
			table.insert(create_font_queue, {name, info})
			return name 
		end
		
		info = info or {}

		info.path = info.path or "fonts/unifont.ttf"
		info.size = info.size or 14     
		
		info.border = math.pow2ceil(info.size) 
		info.border_2 = info.border / 2   
		
		if info.monospace and not info.spacing then
			info.spacing = info.size
		end
		
		info.spacing = info.spacing or 0
		
		ft.fonts[name] = 
		{
			name = name, 
			glyphs = {}, 
			strings = {},
			info = info,
		}
		
		ft.fonts[name].loading = true
		
		if not vfs.ReadAsync(info.path, function(data)
			ft.fonts[name].loading = false
			
			local face = ffi.new("FT_Face[1]")
			if freetype.NewMemoryFace(ft.ptr, data, #data, 0, face) == 0 then
				face = face[0]	
		
				 -- not doing this will make freetype crash because the data gets garbage collected
				ft.fonts[name].face = face
				ft.fonts[name].font_data = data
				
				event.Call("FontChanged", name, info)
			end
		end, info.read_speed, "font") then
			error("could not load font " .. info.path .. " : could not find anything with the path field", 2)
		end
		
		return name
	end
	
	function surface.SetFont(name)
		ft.current_font = ft.fonts[name] or ft.fonts.default
	end

	function surface.GetFont()
		return ft.current_font and ft.current_font.name
	end
	
	local X, Y = 0,0
	local W, H = 1,1
	
	function surface.SetTextPos(x, y)
		X = x
		Y = y
	end
	
	function surface.SetTextScale(w, h)
		W = w
		H = h
	end
	
	local function get_text_data(font, str)
		local face = font.face
		
		if not face then return end
		
		local data = font.strings[str]
		
		if data then
			return data
		end
			
		local info = font.info 
		
		freetype.SetCharSize(face, 0, info.size * DPI, DPI, DPI)
		
		-- get the tallest character and use it as height
		local bbox = ffi.new("FT_BBox[1]")
		local glyph2 = ffi.new("FT_Glyph[1]")
		
		local i = freetype.GetCharIndex(face, ("|"):byte()) 
		freetype.LoadGlyph(face, i, 0)
		freetype.RenderGlyph(face.glyph, 0) 
		freetype.GetGlyph(face.glyph, glyph2)
		freetype.GlyphGetCBox(glyph2[0], 2, bbox)
		bbox = bbox[0]
		
		data = {chars = {}, h = face.glyph.bitmap.rows - bbox.yMin + 1, w = info.size}
					
		local w = 0
		
		for _, str in pairs(utf8.totable(str)) do
			local byte = utf8.byte(str)
			if byte == -1 then byte = str:byte() end
			
			if str == " " or str == "" then	
				w = w + font.info.size / 2
			elseif str == "\t" then
				w = w + font.info.size * 2
			else				
				local glyph = font.glyphs[str]
				
				if not glyph then
					local face = face
					local i = freetype.GetCharIndex(face, byte)
					
					-- try the default font
					if i == 0 then
						face = ft.fonts.default.face
						i = freetype.GetCharIndex(face, byte)
						freetype.SetCharSize(face, 0, info.size * DPI, DPI, DPI)
					end
					
					freetype.LoadGlyph(face, i, 0)
					freetype.RenderGlyph(face.glyph, 0)
					
					local bitmap = face.glyph.bitmap 
					local m = face.glyph.metrics
					
					-- bboox
					local glyph2 = ffi.new("FT_Glyph[1]")
					freetype.GetGlyph(face.glyph, glyph2)
					
					local bbox = ffi.new("FT_BBox[1]")
					freetype.GlyphGetCBox(glyph2[0], 2, bbox)
					bbox = bbox[0]
					
					local x_min = bbox.xMin
					local x_max = bbox.xMax
					
					local y_min = bbox.yMin
					local y_max = bbox.yMax
					
					
					-- copy the data cause we call freetype.RenderGlyph the next frame
					local length = bitmap.width * bitmap.rows
					local buffer = ffi.new("unsigned char[?]", length * 4, 255) -- rgba
					for i = 1, length do 
						buffer[(i*4) - 1] = bitmap.buffer[i-1] 
					end
					
					glyph = {
						buffer = buffer, 
						left = face.glyph.bitmap_left,
						top = face.glyph.bitmap_top,
			
						w = bitmap.width, 
						h = bitmap.rows,
						
						w2 = face.glyph.advance.x / DPI,
						w3 = face.glyph.linearHoriAdvance / DPI,
						
						bx = m.horiBearingX / DPI,
						by = m.horiBearingY / DPI,
						
						x_min = x_min,
						x_max = x_max,
						y_min = y_min,
						y_max = y_max,
						
						i = i,
						
						str = str,
					}
						
					font.glyphs[str] = glyph
				end
				
				local char = {glyph = glyph}

				char.x = glyph.bx + w
				char.y = (info.size - glyph.y_max)
						
				if info.monospace then
					w = w + info.spacing
				else
					w = w + glyph.x_max + 1 + info.spacing
				end
				
				data.chars[#data.chars+1] = char
			end
			
			data.w = w
		end
		
		local tex = render.CreateTexture(math.floor(tonumber(data.w + info.border)), math.floor(tonumber(data.h + info.border)))
		
		tex:Clear()	  		
		
		for _, char in pairs(data.chars) do
			tex:Upload(char.glyph.buffer, {
				x = char.x + info.border_2,  
				y = char.y + info.border_2, 
			
				w = char.glyph.w, 
				h = char.glyph.h,
			})
		end
		
		if font.info.blur then
			blur_texture(tex, font.info)
		end
		
		data.tex = tex

		font.strings[str] = data
		
		return data
	end
			
	function surface.DrawText(str)
		if not ft.ptr or not ft.current_font then return end
		
		str = tostring(str) 
		
		local info = ft.current_font.info 
		
		if ft.current_font.loading then
			local tex = render.GetLoadingTexture()
			surface.SetTexture(tex)
			for i = 1, #str do
				surface.DrawRect(X + (i * info.size)  - info.border_2, Y, info.size, info.size)
			end
			return
		end
		
		local data = get_text_data(ft.current_font, str)
		
		if not data then return end
				 
		if surface.debug then
			surface.SetWhiteTexture()
			surface.Color(1, 0, 0, 0.5)
			surface.DrawRect(X, Y, data.w * W, data.h * H)
			surface.Color(1,1,1,1,1)	
			
			surface.SetWhiteTexture()
			surface.Color(0, 1, 0, 0.1)  
			surface.DrawRect(X - info.border_2, Y - info.border_2, (data.w + info.border) * W, (data.h + info.border) * H)
			surface.Color(1,1,1,1,1)
		end
		
		surface.PushMatrix(X - info.border_2, Y - info.border_2, data.tex.w * W, data.tex.h * H) 
			surface.fontshader.tex = data.tex
			surface.fontshader.global_color = surface.mesh_2d_shader.global_color
			surface.fontshader.smoothness = ft.current_font.info.smoothness 
			surface.fontshader:Bind()
			surface.fontmesh:Draw()
		surface.PopMatrix()
	end 
	
	function surface.GetTextSize(str)
		str = tostring(str)
		
		if not ft.current_font then
			return 0, 0
		end
	
		local data = get_text_data(ft.current_font, str)
		
		if not data then return 0, 0 end
		
		if str == " " then
			local _, h = surface.GetTextSize("|")
			return (ft.current_font.info.size / 2) * W + ft.current_font.info.spacing, h
		elseif str == "\t" then
			local _, h = surface.GetTextSize("|")
			return (ft.current_font.info.size * 2) * W + ft.current_font.info.spacing, h
		end
	
		return data.w * W, data.h * H
	end
	
	function surface.WrapString(str, max_width)
		if not max_width or max_width == 0 then
			return str:explode("")
		end
		
		local lines = {}
		
		local last_pos = 0
		local line_width = 0
		local found = false
	
		local space_pos
	
		for pos, char in pairs(str:utotable()) do
			local w, h = surface.GetTextSize(char)
	
			if char:find("%s") then
				space_pos = pos
			end
	
			if line_width + w >= max_width then
	
				if space_pos then
					lines[#lines+1] = str:usub(last_pos+1, space_pos)
					last_pos = space_pos
				else
					lines[#lines+1] = str:usub(last_pos+1, pos)
					last_pos = pos
				end
	
				line_width = 0
				found = true
				space_pos = nil
			else
				line_width = line_width + w
			end
		end
	
		if found then
			lines[#lines+1] = str:usub(last_pos+1, pos)
		else
			lines[#lines+1] = str
		end
	
		return lines
	end
end

if RELOAD then
	surface.InitializeFonts()
end