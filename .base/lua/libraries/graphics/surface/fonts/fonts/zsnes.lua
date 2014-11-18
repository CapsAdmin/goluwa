local surface = ... or _G.surface

local META = {}

META.ClassName = "zsnes"

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