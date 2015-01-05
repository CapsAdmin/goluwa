local surface = ... or _G.surface

local META = {}

META.ClassName = "love"

function META:Initialize(options)
	if type(options.glyphs) ~= "string" then 
		return false, "missing glyphs field"
	end

	local tex, err = options.texture or render.CreateTextureFromPath(self.Path)
	
	if not tex then return false, err end
	
	self:SetSize(tex.h)
		
	local glyphs = options.glyphs:explode()
	local separator = ColorBytes()
	local i = 0
	local last_y = 0
	local last_separator
	local last_x = 0
	
	local buffers = {}
	
	tex:Fill(function(x, y, pos, r,g,b,a)

		if x == 0 and y == 0 then 
			separator = Color(r,g,b,a)
		end

		if last_y ~= y then
			i = 0
		end
		
		last_y = y
		
		if separator:IsEqual(r,g,b,a) then	
			if not last_separator then
				last_separator = true
			end
		else
			if last_separator then
				last_separator = false
				i = i + 1
				last_x = x
			end
				
			local x = (x - last_x) + 1
			local y = y + 1
			
			buffers[i] = buffers[i] or {}
			buffers[i][x] = buffers[i][x] or {}
			buffers[i][x][y] = {r,g,b,a}
		end
		
		return r,g,b,a
	end, false, false)
	
	
	local font_data = {}

	for i, buffer in ipairs(buffers) do
		if glyphs[i] then
		-- GRRRRRRRRRRRR
-- GRRRRRRRRRRRR

			pcall(function()
			local w, h = #buffer, #buffer[1]
			local sigh = {}
			
			for x = 1, h do
			for y = 1, w do
				sigh[x] = sigh[x] or {}
				sigh[x][y] = buffer[y][-x+h+1]
			end
			end
			
			w, h = #sigh, #sigh[1]
			
			font_data[glyphs[i]] = {
				w = h,
				h = w,
				buffer = ffi.new("uint8_t["..w.."]["..h.."][4]", sigh)
			}
			end)
			
			-- GRRRRRRRRRRRR
-- GRRRRRRRRRRRR

		end
	end
	
	-- GRRRRRRRRRRRR
	
	print(font_data["A"], options.path)

	self.font_data = font_data
	
	self:CreateTextureAtlas()
	
	self:OnLoad()
end

function META:GetGlyphData(code)
	
	local info = self.font_data[code]
	
	if info then
		local char = {
			char = code,
			w = info.w, 
			h = info.h,
			x_advance = info.w,
			y_advance = info.h,
			bitmap_left = info.w,
			bitmap_top = info.h,
		}
				
		return info.buffer, char
	end
end

surface.RegisterFont(META)