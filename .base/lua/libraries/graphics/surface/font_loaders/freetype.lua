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

function META:LoadGlyph(code)
	if self.chars[code] then return end
	
	if freetype.LoadChar(self.face, utf8.byte(code), 4) == 0 then
		local glyph = self.face.glyph
		local bitmap = glyph.bitmap

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
		
		self.texture_atlas:Insert(code, {		
			w = char.w, 
			h = char.h, 
			buffer = copy,
		})
		
		self.chars[code] = char
	else		
		self.chars[code] = {invalid = true}
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
	if self.state ~= "loaded" or not str or not x or not y then return false end
	local X, Y = x, y
	local tex
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char]
		if char == "\n" then
			X = x
			Y = Y + self.options.size
		elseif char == "\t" then
			X = X + self.options.size
		elseif ch and not ch.invalid then
			if tex ~= ch.page.texture then
				surface.SetTexture(ch.page.texture)
				tex = ch.page.texture
			end
			surface.SetRectUV(ch.x, ch.y, ch.w, ch.h, 256, 256)
			surface.DrawRect(X, Y - (ch.bitmap_top) + self.options.size, ch.w, ch.h)
			X = X + ch.x_advance
			Y = Y + ch.y_advance
		elseif not ch or not ch.invalid then
			self:LoadGlyph(char)
		end
	end
	
	return X, Y
end

function META:DrawString(str, x, y)
	self.vertex_buffer = self.vertex_buffer or surface.CreatePoly(500)
	
	self.string_cache = self.string_cache or {}
	
	if not self.string_cache[str] then		
		local data = {}
	
		local X, Y = 0, 0
		local last_texture
		local chars
			
		for i = 1, utf8.length(str) do
			local char = utf8.sub(str, i,i)
			local ch = self.chars[char]
			
			if char == "\n" then
				X = x
				Y = Y + self.options.size
			elseif char == "\t" then
				X = X + self.options.size
			else			
				if not ch or not ch.invalid then
					self:LoadGlyph(char)
					ch = self.chars[char]
				end
				
				if ch then				
					if last_texture ~= ch.page.texture then
						chars = {}
						table.insert(data, {texture = ch.page.texture, chars = chars})
						last_texture = ch.page.texture
					end
				
					table.insert(chars, {
						uv = {ch.x, ch.y, ch.w, ch.h, ch.page.texture.w, ch.page.texture.h},
						rect = {i, X, Y - (ch.bitmap_top) + self.options.size, ch.w, ch.h},					
						tex = ch.page.texture, -- todo: sort by texture
					})
					
					X = X + ch.x_advance
					Y = Y + ch.y_advance
				end
			end
		end
				
		self.string_cache[str] = data
	end
	
	surface.PushMatrix(x, y)
	for i, v in ipairs(self.string_cache[str]) do
		surface.SetTexture(v.texture)
		for i, char in ipairs(v.chars) do
			self.vertex_buffer:SetUV(char.uv[1], char.uv[2], char.uv[3], char.uv[4], char.uv[5], char.uv[6])
			self.vertex_buffer:SetRect(char.rect[1], char.rect[2], char.rect[3], char.rect[4], char.rect[5])
		end
		self.vertex_buffer:Draw(#v.chars)
	end	
	surface.PopMatrix()
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
			if not ch or not ch.invalid then
				self:LoadGlyph(char)
				ch = self.chars[char]
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
				poly:SetRect(i, X-self.options.padding/2, Y-self.options.padding/2 + (ch.h - ch.bitmap_top) + self.options.size, w, -h)
				
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
end

function META:GetTextSize(str)
	if self.state ~= "loaded" then return 0, 0 end
	local X, Y = 0, self.options.size
	
	local rebuild = false
	
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char]
		if not ch or not ch.invalid then
			self:LoadGlyph(char)
			ch = self.chars[char]
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