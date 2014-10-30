local surface = _G.surface or ...

local META = {}

META.Name = "zfont"

local width = 8 -- the actual width is 8 but the 3 last pixels
local height = 5
local pixel_padding = 3

local translate = {
	["maximize (Win)"] = "▫",
	["maximize (SDL)"] = "⬜",
	["minimize (Win)"] = "‾",
	["arrow down"] = "↓",
	["left"] = "◀",
	["right"] = "▶",
	["down"] = "▼",
	["up"] = "▲",

	["shw a"] = "ア",	
	["shw i"] = "イ",	
	["shw u"] = "ウ",	
	["shw e"] = "エ",	
	["shw o"] = "オ",	
	["shw ha"] = "ハ",	
	["shw hi"] = "ヒ",	
	["shw fu"] = "フ",	
	["shw he"] = "ヘ",	
	["shw ho"] = "ホ",	

	["shw ka"] = "カ",	
	["shw ki"] = "キ",	
	["shw ku"] = "ク",	
	["shw ke"] = "ケ",	
	["shw ko"] = "コ",	
	["shw ma"] = "マ",	
	["shw mi"] = "ミ",	
	["shw mu"] = "ム",	
	["shw me"] = "メ",	
	["shw mo"] = "モ",	
	["shw sa"] = "サ",	
	["shw shi"] = "シ",	
	["shw su"] = "ス",	
	["shw se"] = "セ",	
	["shw so"] = "ソ",	
	
	["shw ya"] = "ヤ",	
	["shw ri"] = "リ",	
	["shw yu"] = "ユ",	
	["shw re"] = "レ",	
	["shw yo"] = "ヨ",	
	
	["shw ta"] = "タ",	
	["shw chi"] = "チ",	
	["shw tsu"] = "ツ",	
	["shw te"] = "テ",	
	["shw to"] = "ト",
	
	["shw ra"] = "ラ",	
	["shw wi"] = "ヰ",
	["shw ru"] = "ル",	
	["shw we"] = "ヱ",
	["shw ro"] = "ロ",		
	["shw na"] = "ナ",
	["shw ni"] = "ニ",
	["shw nu"] = "ヌ",
	["shw ne"] = "ネ",
	["shw no"] = "ノ",
	["shw wa"] = "ワ",
	["shw n"] = "ン",
	["shw wo"] = "ヲ",	
	
	["shw comma"] = "，",
	["shw fullstop"] = "．",
	
}

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
			
			name = translate[name] or name
							
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
				X = X + width - pixel_padding + self.options.spacing 
			elseif char == "\t" then
				X = X + (width*4) - pixel_padding + self.options.spacing 
			else	
				if not self.chars[char] then 
					char = char:upper()
					if not self.chars[char] then 	
						char = "?"
					end
				end
				local texture = self.texture_atlas:GetPageTexture(char)
				
				if texture ~= last_tex then
					poly = surface.CreatePoly(#str)
					table.insert(data, {poly = poly, texture = texture})
					last_tex = texture
				end
				
				local x,y, w,h, sx,sy = self.texture_atlas:GetUV(char)
				poly:SetUV(x,y, w,h, sx,sy)
				
				poly:SetRect(i, X, Y+height+self.size/2, width, -height-self.size/2)
				
				if self.options.monospace then 
					X = X + self.options.spacing
				else
					X = X + width - pixel_padding + self.options.spacing 
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
			curX = curX + (width*4) - pixel_padding + self.options.spacing 
		else
			curX = curX + width - pixel_padding + self.options.spacing
		end
	end
	
	curX = curX - self.options.spacing
		
	return curX*self.size+pixel_padding, curY*self.size+pixel_padding
end

surface.RegisterFontLoader(META)