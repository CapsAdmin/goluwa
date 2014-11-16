local surface = _G.surface or ...

local freetype = require("lj-freetype")

local META = {}

META.Name = "freetype"

function META.LoadFont(name, options, callback)	

	if options.path:endswith(".txt") then
		error("not a valid font")
	end

	if not surface.freetype_lib then
		local lib = ffi.new("FT_Library[1]")
		freetype.InitFreeType(lib)
		freetype.LibrarySetLcdFilter(lib[0], 1)
		surface.freetype_lib = lib
	end

	local self = prototype.CreateObject(META, {
		path = options.path,
		options = options,
		pages = {},
		chars = {},
		state = "reading"
	})
	
	assert(vfs.ReadAsync(options.path, function(data, err)
		assert(data, err)
		self.font = data
		self.state = "loading"
		self:Init()
		vfs.UncacheAsync(options.path)
		if self.state == "loaded" then
			callback(self)
		end
	end, options.load_speed or 10, "font"))
	
	return self
end

function META:OnRemove()
	self.state = "disposed"
	freetype.DoneFace(self.face)
end

local flags = {
	default = 0x0,
	no_scale = bit.lshift(1, 0),
	no_hinting = bit.lshift(1, 1),
	render = bit.lshift(1, 2),
	no_bitmap = bit.lshift(1, 3),
	vertical_layout = bit.lshift(1, 4),
	force_autohint = bit.lshift(1, 5),
	crop_bitmap = bit.lshift(1, 6),
	pedantic = bit.lshift(1, 7),
	ignore_global_advance_width = bit.lshift(1, 9),
	no_recurse = bit.lshift(1, 10),
	ignore_transform = bit.lshift(1, 11),
	monochrome = bit.lshift(1, 12),
	linear_design = bit.lshift(1, 13),
	no_autohint = bit.lshift(1, 15),
	color = bit.lshift(1, 20),
}

function META:GetGlyphData(code)	
	if freetype.LoadChar(self.face, utf8.byte(code), bit.bor(flags.render, flags.color, flags.force_autohint)) == 0 then
		local glyph = self.face.glyph
		local bitmap = glyph.bitmap
		
		if bitmap.width == 0 and bitmap.rows == 0 and utf8.byte(code) > 128 then
			return
		end

		local char = {
			char = code,
			w = tonumber(bitmap.width), 
			h = tonumber(bitmap.rows),
			pitch = tonumber(bitmap.pitch),
			x_advance = math.round(tonumber(glyph.advance.x) / surface.font_dpi),
			y_advance = math.round(tonumber(glyph.advance.y) / surface.font_dpi),
			bitmap_left = tonumber(glyph.bitmap_left),
			bitmap_top = tonumber(glyph.bitmap_top)
		}
		
		--local size = bitmap.pitch * bitmap.rows * 4
		--local copy = ffi.new("unsigned char[?]", size)
		--ffi.copy(copy, bitmap.buffer, size)
		
		local copy = ffi.new("unsigned char["..char.w.."]["..char.h.."][4]")
		
		local i = 0
		for x = 0, char.w - 1 do
			for y = 0, char.h - 1 do
				copy[x][y][0] = 255
				copy[x][y][1] = 255
				copy[x][y][2] = 255
				copy[x][y][3] = bitmap.buffer[i] 
				i = i + 1
			end
		end
		
		return copy, char
	end
end

function META:LoadGlyph(code)
	if self.chars[code] then return end
	
	local buffer, char = self:GetGlyphData(code)
	
	if not buffer and self.options.fallback then
		for i, font in ipairs(self.options.fallback) do
			if surface.fonts[font] and surface.fonts[font].GetGlyphData then
				buffer, char = surface.fonts[font]:GetGlyphData(code)
				if buffer then break end
			end
		end
	end
	
	if buffer then		
		self.texture_atlas:Insert(code, {		
			w = char.w, 
			h = char.h, 
			buffer = buffer,
		})
		
		self.chars[code] = char
	end
end

function META:Init()
	local face = ffi.new("FT_Face[1]")
	
	if freetype.NewMemoryFace(surface.freetype_lib[0], self.font, #self.font, 0, face) == 0 then
		self.face_ref = face
		face = face[0]
		self.face = face
		
		freetype.SetCharSize(face, 0, self.options.size * surface.font_dpi, surface.font_dpi, surface.font_dpi)
		
		self.line_height = face.height / surface.font_dpi
		self.max_height = (face.ascender - face.descender) / surface.font_dpi
		
		self.texture_atlas = render.CreateTextureAtlas(512, 512, {
			min_filter = "linear",
			mag_filter = "linear",
		})
		
		self.texture_atlas:SetPadding(self.options.padding)
		
		for i = 32, 128 do
			self:LoadGlyph(utf8.char(i))
		end
		
		self.texture_atlas:Build()
		
		surface.ShadeFont(self)
		
		self.state = "loaded"		
	else
		self.state = "error"
		error("unable to initialize font")
	end
end

function META:GetTextures()
	return self.texture_atlas:GetTextures()
end

function META:Rebuild()
	if self.options.shade then		
		self.texture_atlas = render.CreateTextureAtlas(512, 512, {
			min_filter = "linear",
			mag_filter = "linear",
		})
		
		self.texture_atlas:SetPadding(self.options.padding)

		for code in pairs(self.chars) do
			self.chars[code] = nil
			self:LoadGlyph(code)
		end
		
		self.texture_atlas:Build()
		
		surface.ShadeFont(self)
	else
		self.texture_atlas:Build()
	end
end

function META:DrawString(str, x, y)	
	self.string_cache = self.string_cache or {}
	
	if not self.string_cache[str] then	
		
		local poly
		local data = {}
	
		local X, Y = 0, 0
		local last_tex
		
		local rebuild = false
		
		for i = 1, utf8.length(str) do
			local char = utf8.sub(str, i,i)
			local ch = self.chars[char]
			if not ch then
				self:LoadGlyph(char)
				rebuild = true
			end
		end
		
		if rebuild then
			self:Rebuild()
		end
				
		for i = 1, utf8.length(str) do
			local char = utf8.sub(str, i,i)
			local ch = self.chars[char]
			
			if char == "\n" then
				X = x
				Y = Y + self.options.size
			elseif char == "\t" then
				X = X + self.options.size
			elseif ch then		
				local texture = self.texture_atlas:GetPageTexture(char)
				
				if texture ~= last_tex then
					poly = surface.CreatePoly(#str)
					table.insert(data, {poly = poly, texture = texture})
					last_tex = texture
				end
				
				local x,y, w,h, sx,sy = self.texture_atlas:GetUV(char)
				poly:SetUV(x,y, w,h, sx,sy) 
				poly:SetRect(i, X-self.options.padding/2, Y+self.options.padding/2 + (ch.h - ch.bitmap_top) + self.options.size, w, -h)
				
				if self.options.monospace then 
					X = X + self.options.spacing
				else
					X = X + ch.x_advance + self.options.spacing
				end
			end
		end
				
		self.string_cache[str] = data
	end
	
	surface.PushMatrix(x, y)
	for i, v in ipairs(self.string_cache[str]) do
		surface.SetTexture(v.texture)
		render.SetCullMode("front")
		v.poly:Draw()
		render.SetCullMode("back")
	end	
	surface.PopMatrix()
	
	if surface.debug_font_size then
		surface.SetColor(1,0,0,0.25)
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, surface.GetTextSize(str))
	end
end

function META:GetTextSize(str)
	if self.state ~= "loaded" then return 0, 0 end
	local X, Y = 0, self.options.size
	
	local rebuild = false
	
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char]
		if not ch then
			self:LoadGlyph(char)
			rebuild = true
		end
	end
	
	if rebuild then
		self:Rebuild()
	end
	
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char] 
		if char == "\n" then
			Y = Y + self.options.size
		elseif char == "\t" then
			X = X + self.options.size
		elseif ch then
			if self.options.monospace then 
				X = X + self.options.spacing
			else
				X = X + ch.x_advance + self.options.spacing
			end
		end
	end
	return X, Y
end

surface.RegisterFontLoader(META)