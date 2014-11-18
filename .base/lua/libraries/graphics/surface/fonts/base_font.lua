local META = {}

META.Type = "font"
META.ClassName = "base"

META.pages = {}
META.chars = {}
META.state = "reading"

prototype.GetSet(META, "Path", "")
prototype.GetSet(META, "Padding", 0)
prototype.IsSet(META, "Spacing", 1)
prototype.IsSet(META, "Size", 12)
prototype.IsSet(META, "Scale", Vec2(1,1))
prototype.GetSet(META, "Filtering", "linear")
prototype.GetSet(META, "ShadingInfo")
prototype.GetSet(META, "FallbackFonts")
prototype.IsSet(META, "Monospace", false)
prototype.IsSet(META, "Ready", false)
prototype.GetSet(META, "LoadSpeed", 10)
prototype.GetSet(META, "Shadow", 0)
prototype.GetSet(META, "ShadowColor", Color(0,0,0,1))

function META:GetGlyphData(code)
	error("not implemented")
end

function META:CreateTextureAtlas()
	self.texture_atlas = render.CreateTextureAtlas(512, 512, {
		min_filter = self.Filtering,
		mag_filter = self.Filtering,
	})
	
	self.texture_atlas:SetPadding(self.Padding)

	for code in pairs(self.chars) do
		self.chars[code] = nil
		self:LoadGlyph(code)
	end
	
	self.texture_atlas:Build()
end

function META:Shade(source, vars)
	if source then
		for _, tex in ipairs(self:GetTextures()) do
			tex:Shade(source, vars)
		end
	elseif self.ShadingInfo then
		self:CreateTextureAtlas()
		
		for _, info in ipairs(self.ShadingInfo) do
			for _, tex in ipairs(self.texture_atlas:GetTextures()) do
				tex:Shade(info.source, info.vars)
			end
		end
	end
end

function META:Rebuild()
	if self.ShadingInfo then
		self:Shade()
	else
		self.texture_atlas:Build()
	end
end

function META:LoadGlyph(code)
	if self.chars[code] then return end
	
	local buffer, char = self:GetGlyphData(code)
	
	if not buffer and self.FallbackFonts then
		for i, font in ipairs(self.FallbackFonts) do
			buffer, char = font:GetGlyphData(code)
			if buffer then break end
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

function META:DrawString(str, x, y)
	if not self.Ready then return end
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
				Y = Y + self.Size
			elseif char == "\t" then
				X = X + self.Size * 4
			elseif not ch and char == " " then
				X = X + self.Size
			elseif ch then		
				local texture = self.texture_atlas:GetPageTexture(char)
				
				if texture ~= last_tex then
					poly = surface.CreatePoly(#str)
					table.insert(data, {poly = poly, texture = texture})
					last_tex = texture
				end
				
				local x,y, w,h, sx,sy = self.texture_atlas:GetUV(char)
				poly:SetUV(x,y, w,h, sx,sy) 
				poly:SetRect(i, (X-self.Padding/2) * self.Scale.w, ((Y+self.Padding/2) * self.Scale.h) + (ch.h - ch.bitmap_top) + self.Size, w * self.Scale.w, -h * self.Scale.h)
				
				if self.Monospace then 
					X = X + self.Spacing
				else
					X = X + ch.x_advance + self.Spacing
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
	if not self.Ready then return 0,0 end
	
	local X, Y = 0, self.Size
	
	local rebuild = false
	local length = utf8.length(str)
	
	for i = 1, length do
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
	
	for i = 1, length do
		local char = utf8.sub(str, i,i)
		local ch = self.chars[char] 
		if char == "\n" then
			Y = Y + self.Size * self.Scale.h
		elseif char == "\t" then
			X = X + self.Size * self.Scale.w
		elseif not ch and char == " " then
			X = X + self.Size * self.Scale.w
		elseif ch then
			if self.Monospace then 
				X = X + self.Spacing
			else
				X = X + (ch.x_advance + self.Spacing) * self.Scale.w
			end
		end
	end
	return X, Y
end

function META:OnLoad()

end

prototype.Register(META)