local surface = _G.surface or ...

local META = {}

META.Name = "zfont"

local width = 8
local height = 5

function META.LoadFont(name, options, callback)
	local file = vfs.Open(options.path)
	
	if file:ReadBytes(18) ~= "; empty space 0x00" then
		error("first line of font is not '; empty space 0x00'")
	end
	
	local self = prototype.CreateObject(META, {
		data = "\n" .. vfs.Read(options.path), 
		dir = options.path .. "/", 
		chars = {},
		options = options,
		size = math.ceil(options.size / 8),
	})
	
	self:BuildAtlas()
	
	self.state = "loaded"
	
	callback(self)
	
	return self
end

function META:BuildAtlas()
	local atlas = render.CreateTextureAtlas(128, 128, {
		min_filter = "nearest",
		mag_filter = "nearest",
	})

	for glyph in self.data:gmatch("(.-)\n; ") do
		local name, byte, data = glyph:match("(.+) (0x.-)\n(.+)")
		byte = tonumber(byte) or byte
			
		if data then
			data = data:gsub("%s", "")
			data = data:gsub("0", "\0")
			data = data:gsub("1", "\255")
			
			local buffer = ffi.cast("unsigned char *", data)
			local copy = ffi.new("unsigned char["..width.."]["..height.."][4]")
			
			local i = 0
			for x = 0, width - 1 do
				for y = 0, height - 1 do
					copy[x][y][0] = 255
					copy[x][y][1] = 255
					copy[x][y][2] = 255
					copy[x][y][3] = buffer[i] 
					i = i + 1
				end
			end
							
			self.chars[name] = true
			
			atlas:Insert(name, {		
				w = width, 
				h = height, 
				buffer = copy,
			})
		end
	end
		
	atlas:Build()
	
	self.texture_atlas = atlas
end

function META:DrawString(str, X, Y)
	self.string_cache = self.string_cache or {}
		
	if not self.string_cache[str] then	
		
		local poly
		local data = {}
	
		local X, Y = 0, 0
		local last_tex
				
		for i = 1, utf8.length(str) do
			local char = utf8.sub(str, i,i)
						
			if char == "\n" then
				X = x
				Y = Y + height
			elseif char == " " then
				X = X + width
			elseif char == "\t" then
				X = X + width*4
			elseif self.chars[char] then
				local texture = self.texture_atlas:GetPageTexture(char)
				
				if texture ~= last_tex then
					poly = surface.CreatePoly(#str)
					table.insert(data, {poly = poly, texture = texture})
					last_tex = texture
				end
				
				local x,y, w,h, sx,sy = self.texture_atlas:GetUV(char)
				poly:SetUV(x,y, w,h, sx,sy) 
				poly:SetRect(i, X, Y, width, -height)
				
				if self.options.monospace then 
					X = X + self.options.spacing
				else
					X = X + width + self.options.spacing
				end
			end			
		end
		
		self.string_cache[str] = data
	end
	
	surface.PushMatrix(X, Y, self.size, self.size)
	for i, v in ipairs(self.string_cache[str]) do
		surface.SetTexture(v.texture)
		render.SetCullMode("front")
		v.poly:Draw()
		render.SetCullMode("back")
	end	
	surface.PopMatrix()
end

function META:GetTextSize(str)
	local curX, curY = 0, height
	
	for i = 1, utf8.length(str) do
		local char = utf8.sub(str, i,i)
		if char == "\n" then
			curY = curY + height + self.options.spacing
		elseif char == "\t" then
			curY = curY + width*4 + self.options.spacing
		else
			if self.options.monospace then 
				curX = curX + self.options.spacing
			else
				curX = curX + width + self.options.spacing
			end
		end
	end
		
	return curX, curY
end

surface.RegisterFontLoader(META)