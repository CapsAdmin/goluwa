local META = {}

META.Type = "font"
META.ClassName = "base"

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
	self.texture_atlas = render.CreateTextureAtlas(512, 512, self.Filtering)
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
			flip_y = true,
		})

		self.chars[code] = char
	end
end

function META:DrawString(str, x, y, w)
	if not self.Ready then return end

	if str == nil then str = "nil" end

	self.string_cache = self.string_cache or {}

	if not self.string_cache[str] then
		self.total_strings_stored = self.total_strings_stored or 0

		if self.total_strings_stored > 1000 then
			--logf("surface warning: string cache for %s is above 1000, flushing cache\n", self)
			table.clear(self.string_cache)
			self.total_strings_stored = 0
		end

		self.string_cache[str] = self:CompileString({tostring(str)})

		self.total_strings_stored = self.total_strings_stored + 1
	end

	self.string_cache[str]:Draw(x, y, w)

	if surface.debug_font_size then
		surface.SetColor(1,0,0,0.25)
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, surface.GetTextSize(str))
	end
end

function META:SetPolyChar(poly, i, x, y, char)
	local ch = self.chars[char]

	if ch then
		local x_,y_, w,h, sx,sy = self.texture_atlas:GetUV(char)
		poly:SetUV(x_,y_, w,h, sx,sy)

		x = x - self.Padding / 2
		y = y - self.Padding * 2

		x = x * self.Scale.x
		y = y * self.Scale.y

		y = y - ch.bitmap_top + self.Size + (0.5 * self.Scale.y)

		poly:SetRect(i, x, y, w * self.Scale.x, h * self.Scale.y)
	end
end

function META:CompileString(data)
	local size = 0

	do
		for _, str in ipairs(data) do
			if type(str) == "string" then
				local rebuild = false
				size = size + utf8.length(str)
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
			end
		end
	end

	local poly = surface.CreatePoly(size)
	local width_info = {}
	local out = {}

	local X, Y = 0, 0
	local i = 1
	local last_tex

	for _, str in ipairs(data) do
		if type(str) ~= "string" then
			if typex(str) == "vec2" then
				X = str.x
				Y = str.y
			else
				poly:SetColor(str:Unpack())
			end
		else
			for str_i = 1, utf8.length(str) do
				local char = utf8.sub(str, str_i,str_i)
				local ch = self.chars[char]

				if char == "\n" then
					X = 0
					Y = Y + self.Size
				elseif char == "\t" then
					local ch = self.chars[" "]

					if ch then
						if self.Monospace then
							X = X + self.Spacing * 4
						else
							X = X + ((ch.x_advance + self.Spacing) * self.Scale.x) * 4
						end
					else
						X = X + self.Size * 4
					end
				elseif not ch and char == " " then
					local ch = self.chars[" "]

					if ch then
						if self.Monospace then
							X = X + self.Spacing
						else
							X = X + (ch.x_advance + self.Spacing) * self.Scale.x
						end
					else
						X = X + self.Size
					end
				elseif ch then
					local texture = self.texture_atlas:GetPageTexture(char)

					if texture ~= last_tex then
						table.insert(out, {poly = poly, texture = texture})
						last_tex = texture
					end

					self:SetPolyChar(poly, i, X, Y, char)

					if self.Monospace then
						X = X + self.Spacing
					else
						X = X + ch.x_advance + self.Spacing
					end

					width_info[i] = X

					i = i + 1
				end
			end
		end
	end

	local string = {}

	local width_cache = {}

	function string:Draw(x, y, w)
		if w and not width_cache[w] then
			for i, x in ipairs(width_info) do
				if x > w then
					width_cache[w] = i - 1
					break
				end
			end
		end

		surface.PushMatrix(x, y)
		for i, v in ipairs(out) do
			surface.SetTexture(v.texture)
			v.poly:Draw(width_cache[w])
		end
		surface.PopMatrix()
	end

	return string
end

function META:GetTextSize(str)
	if not self.Ready then return 0,0 end

	str = tostring(str)

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
			Y = Y + self.Size * self.Scale.y
		elseif char == "\t" then
			local ch = self.chars[" "]
			if ch then
				if self.Monospace then
					X = X + self.Spacing * 4
				else
					X = X + ((ch.x_advance + self.Spacing) * self.Scale.x) * 4
				end
			else
				X = X + self.Size * 4
			end
		elseif not ch and char == " " then
			local ch = self.chars[" "]

			if ch then
				if self.Monospace then
					X = X + self.Spacing
				else
					X = X + (ch.x_advance + self.Spacing) * self.Scale.x
				end
			else
				X = X + self.Size
			end
		elseif ch then
			if self.Monospace then
				X = X + self.Spacing
			else
				X = X + (ch.x_advance + self.Spacing) * self.Scale.x
			end
		end
	end
	return X, Y
end

function META:OnLoad()

end

prototype.Register(META)

if RELOAD then
	for k,v in pairs(surface.registered_fonts) do
		surface.RegisterFont(v)
	end
	for k,v in pairs(surface.fonts) do
		v.string_cache = {}
		v.total_strings_stored = 0
		v:CreateTextureAtlas()
		v:Rebuild()
	end
end