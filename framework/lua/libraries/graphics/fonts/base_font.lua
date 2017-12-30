local META = prototype.CreateTemplate("font", "base")

META:GetSet("Path", "")
META:GetSet("Padding", 0)
META:GetSet("Curve", 0)
META:IsSet("Spacing", 0)
META:IsSet("Size", 12)
META:IsSet("Scale", Vec2(1,1))
META:GetSet("Filtering", "linear")
META:GetSet("ShadingInfo")
META:GetSet("FallbackFonts")
META:IsSet("Monospace", false)
META:IsSet("Ready", false)
META:IsSet("ReverseDraw", false)
META:GetSet("LoadSpeed", 10)
META:GetSet("TabWidthMultiplier", 4)
META:GetSet("Flags")

function META:GetGlyphData(code)
	error("not implemented")
end

function META:CreateTextureAtlas()
	self.texture_atlas = render.CreateTextureAtlas(1024, 1024, self.Filtering)
	self.texture_atlas:SetPadding(self.Padding)

	for code in pairs(self.chars) do
		self.chars[code] = nil
		self:LoadGlyph(code)
	end

	self.texture_atlas:Build()
end

function META:Shade(source, vars, blend_mode)
	if source then
		for _, tex in ipairs(self.texture_atlas:GetTextures()) do
			if tex.font_shade_keep then
				vars.copy = tex.font_shade_keep
				--tex.font_shade_keep = nil
			end
			tex:Shade(source, vars, blend_mode)
		end
	elseif self.ShadingInfo then
		self:CreateTextureAtlas()
		for _, info in ipairs(self.ShadingInfo) do
			if info.copy then
				for _, tex in ipairs(self.texture_atlas:GetTextures()) do
					tex.font_shade_keep = render.CreateBlankTexture(tex:GetSize())
					tex.font_shade_keep:Shade("return texture(tex, uv);", {tex = tex}, "none")
				end
			else
				self:Shade(info.source, info.vars, info.blend_mode)
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
	if self.chars[code] ~= nil then return end

	local buffer, char = self:GetGlyphData(code)

	if not buffer and self.FallbackFonts then
		for _, font in ipairs(self.FallbackFonts) do
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
	else
		self.chars[code] = false
	end
end

function META:DrawString(str, x, y, w)
	if not self.Ready then
		return fonts.loading_font:DrawString(str, x, y, w)
	end

	if str == nil then str = "nil" end

	self.string_cache = self.string_cache or {}

	if not self.string_cache[str] then
		self.total_strings_stored = self.total_strings_stored or 0

		if self.total_strings_stored > 10000 then
			logf("self warning: string cache for %s is above 10000, flushing cache\n", self)
			table.clear(self.string_cache)
			self.total_strings_stored = 0
		end

		self.string_cache[str] = self:CompileString({tostring(str)})
		self.total_strings_stored = self.total_strings_stored + 1
	end

	self.string_cache[str]:Draw(x, y, w)

	if fonts.debug_font_size then
		render2d.SetColor(1,0,0,0.25)
		render2d.SetTexture()
		render2d.DrawRect(x, y, gfx.GetTextSize(str))
	end
end

function META:SetPolyChar(poly, i, x, y, char, r)
	local ch = self.chars[char]

	if ch then
		local x_,y_, w,h, sx,sy = self.texture_atlas:GetUV(char)
		poly:SetUV(x_,y_, w,h, sx,sy)

		y = y - ch.bitmap_top + self.Size

		x = x - (self.Padding / 2)
		y = y - (self.Padding / 2)

		x = x * self.Scale.x
		y = y * self.Scale.y

		w = w * self.Scale.x
		h = h * self.Scale.y

		if r then
			poly:SetRect(i, x, y, w, h, r, nil, nil, -w/2, -h/2)
		else
			poly:SetRect(i, x, y, w, h)
		end
	end
end

function META:GetChar(char)
	local data = self.chars[char]

	if data == nil then
		self:LoadGlyph(char)
		self.rebuild = true
		return self.chars[char]
	end

	if char == "\n" and data.h <= 1 then
		data.h = self.Size
	end

	return data
end

function META:CompileString(data)

	if not self.Ready then
		return fonts.loading_font:CompileString(data)
	end

	local vertex_count = 0

	local strings = {}

	for i, str in ipairs(data) do
		if type(str) == "string" then
			local chars = utf8.totable(str)
			vertex_count = vertex_count + (#chars * 6)
			strings[i] = chars
		end
	end

	local poly = gfx.CreatePolygon2D(vertex_count)
	poly.vertex_buffer:SetDrawHint("dynamic")
	local width_info = {}
	local out = {}

	local max_width = 0
	local X, Y = 0, 0
	local i = 1
	local last_tex
	local rebuild = false

	for i2, str in ipairs(data) do
		if type(str) ~= "string" then
			if typex(str) == "vec2" then
				X = str.x
				Y = str.y
			else
				poly:SetColor(str:Unpack())
			end
		else
			for str_i, char in ipairs(strings[i2]) do
				local data = self:GetChar(char)

				local spacing = self.Spacing

				if char == "\n" then
					X = 0
					Y = Y + self:GetChar("\n").h + spacing
				elseif char == "\t" then
					data = self:GetChar(" ")

					if data then
						if self.Monospace then
							X = X + spacing * self.TabWidthMultiplier
						else
							X = X + (data.x_advance + spacing) * self.TabWidthMultiplier
						end
					else
						X = X + self.Size * self.TabWidthMultiplier
					end
				elseif data then
					if self.rebuild then
						self:Rebuild()
						self.rebuild = false
					end
					local texture = self.texture_atlas:GetPageTexture(char)

					if texture ~= last_tex then
						table.insert(out, {poly = poly, texture = texture})
						last_tex = texture
					end

					local draw_i = self.ReverseDraw and (-i + count + 1) or i

					if self.Curve ~= 0 then
						local offset = math.sin(((str_i-1)/count)*math.pi+math.pi/2)
						Y = Y + (offset * -self.Curve)

						self:SetPolyChar(poly, draw_i, X, Y, char, -offset*self.Curve/50)
					else
						self:SetPolyChar(poly, draw_i, X + data.bitmap_left, Y, char)
					end

					if self.Monospace then
						X = X + spacing
					else
						X = X + data.x_advance + spacing
					end

					width_info[i] = X

					i = i + 1
				elseif char == " " then
					X = X + self.Size / 2
				end
				max_width = math.max(max_width, X)
			end
		end
	end

	local string = {}

	local width_cache = table.weak()

	function string:Draw(x, y, w)
		if w and not width_cache[w] then
			for i, x in ipairs(width_info) do
				if x > w then
					width_cache[w] = (i - 1) * 6
					break
				end
			end
		end

		render2d.PushMatrix(x, y)
		for _, v in ipairs(out) do
			render2d.SetTexture(v.texture)
			v.poly:Draw(width_cache[w])
		end
		render2d.PopMatrix()
	end

	return string, max_width, Y
end

function META:GetTextSize(str)
	if not self.Ready then
		return fonts.loading_font:GetTextSize(str)
	end

	str = tostring(str)

	local X, Y = 0, self.Size
	local max_x = 0

	local spacing = self.Spacing

	for i, char in ipairs(utf8.totable(str)) do
		local data = self:GetChar(char)

		if char == "\n" then
			Y = Y + self:GetChar("\n").h + spacing
			max_x = math.max(max_x, X)
			X = 0
		elseif char == "\t" then
			data = self:GetChar(" ")
			if data then
				if self.Monospace then
					X = X + spacing * 4
				else
					X = X + (data.x_advance + spacing) * 4
				end
			else
				X = X + self.Size * 4
			end
		elseif data then
			if self.Monospace then
				X = X + spacing
			else
				X = X + data.x_advance + spacing
			end
		elseif char == " " then
			X = X + self.Size
		end
	end

	if max_x ~= 0 then X = max_x end

	return X * self.Scale.x, Y * self.Scale.y
end

function META:WrapString(str, max_width, max_word_length)
	max_word_length = max_word_length or 15
	local tbl = {}
	local tbl_i = 1
	local start_pos = 1
	local end_pos = 1

	local str_tbl = utf8.totable(str)

	for i = 1, #str_tbl do
		end_pos = end_pos + 1
		if self:GetTextSize(str:usub(start_pos, end_pos)) > max_width then
			local n = str_tbl[end_pos]

			for i = 1, max_word_length do
				if n == " " or n == "," or n == "." or n == "\n" then
					break
				else
					end_pos = end_pos - 1
					n = str_tbl[end_pos]
				end
			end

			tbl[tbl_i] = str:usub(start_pos, end_pos):trim()
			tbl_i = tbl_i + 1
			start_pos = end_pos + 1
		end
	end
	tbl[tbl_i] = str:usub(start_pos, end_pos)
	tbl_i = tbl_i + 1
	return table.concat(tbl,"\n")
end

function META:OnLoad()

end

META:Register()

if RELOAD then
	for _, v in pairs(fonts.registered_fonts) do
		fonts.RegisterFont(v)
	end
	for _, v in pairs(prototype.GetCreated()) do
		if v.Type == "font" then
			v.string_cache = {}
			v.total_strings_stored = 0
			v:CreateTextureAtlas()
			v:Rebuild()
		end
	end
end
