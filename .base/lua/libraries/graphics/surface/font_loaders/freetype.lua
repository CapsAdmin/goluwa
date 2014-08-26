local surface = _G.surface or ...

local freetype = require("lj-freetype")

local META = {}

META.Name = "freetype"

function META.LoadFont(name, options, callback)	

	if not surface.freetype_lib then
		local lib = ffi.new("FT_Library[1]")
		freetype.InitFreeType(lib)
		surface.freetype_lib = lib
	end

	local self = META:New({
		path = options.path,
		options = options,
		pages = {},
		chars = {},
		dirty_chars = {},
		state = "reading"
	})
	
	assert(vfs.ReadAsync(options.path, function(data)
		self.font = data
		self.state = "loading"
		self:Init()
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

function META:FindFreePage(w, h)
	local found_page, x, y
	
	for k,v in pairs(self.pages) do
		local found = v.packer:Fit(w, h)
		if found then
			found_page = v
			x, y = found.x, found.y
			break	
		end
	end

	if not found_page then
		x, y = 0, 0
		
		found_page = { 
			texture = render.CreateTexture(256, 256, nil, {
				min_filter = "linear",
				mag_filter = "linear",
			}), 
			chars = {}, 
			packer = PackedRectangle(256, 256) 
		}
		
		--found_page.texture:Clear()
		
		table.insert(self.pages, found_page)
	end
	
	return found_page, x, y
end

function META:LoadGlyph(codepoint, build_texture)
	if self.chars[utf8.char(codepoint)] then return end
	
	local suc = freetype.LoadChar(self.face, codepoint, 4)
	if suc == 0 then
		local glyph = self.face.glyph
		local bitmap= glyph.bitmap
		--local page, x, y = self:FindFreePage(bitmap.width, bitmap.rows)
		local char = {
			char = utf8.char(codepoint),
			w = tonumber(bitmap.width), 
			h = tonumber(bitmap.rows),
			pitch = tonumber(bitmap.pitch),
			xAdvance = tonumber(glyph.advance.x) / surface.font_dpi,
			yAdvance = tonumber(glyph.advance.y) / surface.font_dpi,
			bitmapLeft = tonumber(glyph.bitmap_left),
			bitmapTop = tonumber(glyph.bitmap_top)
		}
		local copy = ffi.new("unsigned char[?]", bitmap.pitch * bitmap.rows)
		ffi.copy(copy, bitmap.buffer, bitmap.pitch * bitmap.rows)
		
		char.bitmap = copy
		
		table.insert(self.dirty_chars, char)
	else		
		self.chars[utf8.char(codepoint)] = {invalid = true}
	end
	
	if not build_texture then self:build_textures() end
end

function META:build_textures()
	table.sort(self.dirty_chars, function(a, b)
		return (a.w * a.h) > (b.w * b.h)
	end)
	
	for i = 1, #self.dirty_chars do
		local char = self.dirty_chars[i]
		local page, x, y = self:FindFreePage(char.w, char.h)
		char.page = page
		char.x = x
		char.y = y
		
		page.chars[char.char] = char
		self.chars[char.char] = char
		
		page.dirty = true
	end
	
	self.dirty_chars = {}

	for k, page in pairs(self.pages) do
		if page.dirty then
			page.texture:Clear()
			local buffer = ffi.new("unsigned int[256][256]")
			
			for k,char in pairs(page.chars) do				
				local bitmap = char.bitmap
				for x = 0, char.w - 1 do
					for y = 0, char.h - 1 do
						buffer[255 - (y + char.y)][x + char.x] = bit.lshift(bitmap[x + y * char.pitch], 24) + 0xFFFFFF
					end
				end
			end
			page.texture:Upload(buffer)
			page.dirty = false
		end
	end
end
function META:LoadGlyphs(code_start, code_end)
	for i = code_start, code_end do
		self:LoadGlyph(i, true)
	end
	self:build_textures()
end

function META:Init()
	local face = ffi.new("FT_Face[1]")
	
	if freetype.NewMemoryFace(surface.freetype_lib[0], self.font, #self.font, 0, face) == 0 then
		self.face_ref = face
		face = face[0]
		self.face = face
		freetype.SetCharSize(face, 0, self.options.size * surface.font_dpi, surface.font_dpi, surface.font_dpi)
		self.lineHeight = face.height / surface.font_dpi
		self.maxHeight = (face.ascender - face.descender) / surface.font_dpi
		self:LoadGlyphs(32, 128)
		
		self.state = "loaded"
		
	else
		self.state = "error"
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
			surface.DrawRect(X, Y - (ch.bitmapTop) + self.options.size, ch.w, ch.h)
			X = X + ch.xAdvance
			Y = Y + ch.yAdvance
		elseif not ch or not ch.invalid then
			self:LoadGlyph(utf8.byte(char))
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
					self:LoadGlyph(utf8.byte(char))
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
						rect = {i, X, Y - (ch.bitmapTop) + self.options.size, ch.w, ch.h},					
						tex = ch.page.texture, -- todo: sort by texture
					})
					
					X = X + ch.xAdvance
					Y = Y + ch.yAdvance
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
		
		local lol = 1
		
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
					self:LoadGlyph(utf8.byte(char))
					ch = self.chars[char]
				end
				
				if ch then				
					if ch.page.texture ~= last_tex then
						tex = ch.page.texture
						poly = surface.CreatePoly(#str)
						table.insert(data, {poly = poly, texture = ch.page.texture})
						last_tex = ch.page.texture
						lol = 1
					end
					
					poly:SetUV(ch.x, ch.y, ch.w, ch.h, ch.page.texture.w, ch.page.texture.h)
					poly:SetRect(i, math.round(X), math.round(Y - (ch.bitmapTop) + self.options.size), ch.w, ch.h)
					
					if self.options.monospace then 
						X = X + self.options.spacing
					else
						X = X + ch.xAdvance + self.options.spacing
					end
					Y = Y + ch.yAdvance
					
					lol = lol + 1
				end
			end
			
		end
		
		self.string_cache[str] = data
	end
	
	surface.PushMatrix(x, y)
	for i, v in ipairs(self.string_cache[str]) do
		surface.SetTexture(v.texture)
		v.poly:Draw()
	end	
	surface.PopMatrix()
end

function META:GetTextSize(str)
	if self.state ~= "loaded" then return 0, 0 end
	local X, Y = 0, self.options.size
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char]
		if char == "\n" then
			Y = Y + self.options.size
		elseif char == "\t" then
			X = X + self.options.size
		elseif ch and not ch.invalid then
			if self.options.monospace then 
				X = X + self.options.spacing
			else
				X = X + ch.xAdvance + self.options.spacing
			end
			Y = Y + ch.yAdvance
		end
	end
	return X, Y
end

surface.RegisterFontLoader(META)