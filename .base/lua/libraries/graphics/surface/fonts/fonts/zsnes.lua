local surface = ... or _G.surface

local META = {}

META.ClassName = "zsnes"

local width = 8 -- the actual width is 8 but the 3 last pixels
local height = 5
local pixel_padding = 3

local translate = {
	["maximize (Win)"] = "?",
	["maximize (SDL)"] = "?",
	["minimize (Win)"] = "?",
	["arrow down"] = "?",
	["left"] = "?",
	["right"] = "?",
	["down"] = "?",
	["up"] = "?",

	["shw a"] = "?",	
	["shw i"] = "?",	
	["shw u"] = "?",	
	["shw e"] = "?",	
	["shw o"] = "?",	
	["shw ha"] = "?",	
	["shw hi"] = "?",	
	["shw fu"] = "?",	
	["shw he"] = "?",	
	["shw ho"] = "?",	

	["shw ka"] = "?",	
	["shw ki"] = "?",	
	["shw ku"] = "?",	
	["shw ke"] = "?",	
	["shw ko"] = "?",	
	["shw ma"] = "?",	
	["shw mi"] = "?",	
	["shw mu"] = "?",	
	["shw me"] = "?",	
	["shw mo"] = "?",	
	["shw sa"] = "?",	
	["shw shi"] = "?",	
	["shw su"] = "?",	
	["shw se"] = "?",	
	["shw so"] = "?",	
	
	["shw ya"] = "?",	
	["shw ri"] = "?",	
	["shw yu"] = "?",	
	["shw re"] = "?",	
	["shw yo"] = "?",	
	
	["shw ta"] = "?",	
	["shw chi"] = "?",	
	["shw tsu"] = "?",	
	["shw te"] = "?",	
	["shw to"] = "?",
	
	["shw ra"] = "?",	
	["shw wi"] = "?",
	["shw ru"] = "?",	
	["shw we"] = "?",
	["shw ro"] = "?",		
	["shw na"] = "?",
	["shw ni"] = "?",
	["shw nu"] = "?",
	["shw ne"] = "?",
	["shw no"] = "?",
	["shw wa"] = "?",
	["shw n"] = "?",
	["shw wo"] = "?",	
	
	["shw comma"] = ",",
	["shw fullstop"] = ".",	
}

function META:Initialize()
	if not self.Path:endswith(".txt") then
		return false, "not a valid font"
	end

	local file, err = vfs.Open(self.Path)
	
	if not file then
		return false, "no such file"
	end
	
	if file:ReadBytes(18) ~= "; empty space 0x00" then
		error("first line of font is not '; empty space 0x00'")
	end

	self.font_data = {}
	
	for glyph in file:ReadAll():gmatch("(.-)\n; ") do
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
			
			self.font_data[name] = {w = width, h = height , buffer = copy}
		end
	end
	
	self:CreateTextureAtlas()
	
	self:OnLoad()
end

function META:GetGlyphData(code)
	code = code:upper()
	
	local info = self.font_data[code]
	if info then
		local char = {
			char = code,
			w = info.w, 
			h = info.h,
			x_advance = info.w - pixel_padding,
			y_advance = info.h,
			bitmap_left = info.w,
			bitmap_top = info.h,
		}
		return info.buffer, char
	end
end

surface.RegisterFont(META)