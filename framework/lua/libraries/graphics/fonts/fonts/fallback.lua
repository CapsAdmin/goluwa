local ffi = desire("ffi")
local fonts = ... or _G.fonts
local META = prototype.CreateTemplate("fallback_font")

function META:Initialize(options)
	if options.type ~= "fallback_font" then return false end

	self:SetFiltering("nearest")
	self:CreateTextureAtlas()
	self:OnLoad()
end

-- code taken from Flyguy at https://www.shadertoy.com/view/Mt2GWD
local WIDTH = 8
local HEIGHT = 12
local chars = {
	[" "] = {0x000000, 0x000000, 0x000000, 0x000000},
	["!"] = {0x003078, 0x787830, 0x300030, 0x300000},
	["\""] = {0x006666, 0x662400, 0x000000, 0x000000},
	["#"] = {0x006C6C, 0xFE6C6C, 0x6CFE6C, 0x6C0000},
	["$"] = {0x30307C, 0xC0C078, 0x0C0CF8, 0x303000},
	["%"] = {0x000000, 0xC4CC18, 0x3060CC, 0x8C0000},
	["&"] = {0x0070D8, 0xD870FA, 0xDECCDC, 0x760000},
	["'"] = {0x003030, 0x306000, 0x000000, 0x000000},
	["("] = {0x000C18, 0x306060, 0x603018, 0x0C0000},
	[")"] = {0x006030, 0x180C0C, 0x0C1830, 0x600000},
	["*"] = {0x000000, 0x663CFF, 0x3C6600, 0x000000},
	["+"] = {0x000000, 0x18187E, 0x181800, 0x000000},
	[","] = {0x000000, 0x000000, 0x000038, 0x386000},
	["-"] = {0x000000, 0x0000FE, 0x000000, 0x000000},
	["."] = {0x000000, 0x000000, 0x000038, 0x380000},
	["/"] = {0x000002, 0x060C18, 0x3060C0, 0x800000},
	["0"] = {0x007CC6, 0xD6D6D6, 0xD6D6C6, 0x7C0000},
	["1"] = {0x001030, 0xF03030, 0x303030, 0xFC0000},
	["2"] = {0x0078CC, 0xCC0C18, 0x3060CC, 0xFC0000},
	["3"] = {0x0078CC, 0x0C0C38, 0x0C0CCC, 0x780000},
	["4"] = {0x000C1C, 0x3C6CCC, 0xFE0C0C, 0x1E0000},
	["5"] = {0x00FCC0, 0xC0C0F8, 0x0C0CCC, 0x780000},
	["6"] = {0x003860, 0xC0C0F8, 0xCCCCCC, 0x780000},
	["7"] = {0x00FEC6, 0xC6060C, 0x183030, 0x300000},
	["8"] = {0x0078CC, 0xCCEC78, 0xDCCCCC, 0x780000},
	["9"] = {0x0078CC, 0xCCCC7C, 0x181830, 0x700000},
	[":"] = {0x000000, 0x383800, 0x003838, 0x000000},
	[";"] = {0x000000, 0x383800, 0x003838, 0x183000},
	["<"] = {0x000C18, 0x3060C0, 0x603018, 0x0C0000},
	["="] = {0x000000, 0x007E00, 0x7E0000, 0x000000},
	[">"] = {0x006030, 0x180C06, 0x0C1830, 0x600000},
	["?"] = {0x0078CC, 0x0C1830, 0x300030, 0x300000},
	["@"] = {0x007CC6, 0xC6DEDE, 0xDEC0C0, 0x7C0000},
	A = {0x003078, 0xCCCCCC, 0xFCCCCC, 0xCC0000},
	B = {0x00FC66, 0x66667C, 0x666666, 0xFC0000},
	C = {0x003C66, 0xC6C0C0, 0xC0C666, 0x3C0000},
	D = {0x00F86C, 0x666666, 0x66666C, 0xF80000},
	E = {0x00FE62, 0x60647C, 0x646062, 0xFE0000},
	F = {0x00FE66, 0x62647C, 0x646060, 0xF00000},
	G = {0x003C66, 0xC6C0C0, 0xCEC666, 0x3E0000},
	H = {0x00CCCC, 0xCCCCFC, 0xCCCCCC, 0xCC0000},
	I = {0x007830, 0x303030, 0x303030, 0x780000},
	J = {0x001E0C, 0x0C0C0C, 0xCCCCCC, 0x780000},
	K = {0x00E666, 0x6C6C78, 0x6C6C66, 0xE60000},
	L = {0x00F060, 0x606060, 0x626666, 0xFE0000},
	M = {0x00C6EE, 0xFEFED6, 0xC6C6C6, 0xC60000},
	N = {0x00C6C6, 0xE6F6FE, 0xDECEC6, 0xC60000},
	O = {0x00386C, 0xC6C6C6, 0xC6C66C, 0x380000},
	P = {0x00FC66, 0x66667C, 0x606060, 0xF00000},
	Q = {0x00386C, 0xC6C6C6, 0xCEDE7C, 0x0C1E00},
	R = {0x00FC66, 0x66667C, 0x6C6666, 0xE60000},
	S = {0x0078CC, 0xCCC070, 0x18CCCC, 0x780000},
	T = {0x00FCB4, 0x303030, 0x303030, 0x780000},
	U = {0x00CCCC, 0xCCCCCC, 0xCCCCCC, 0x780000},
	V = {0x00CCCC, 0xCCCCCC, 0xCCCC78, 0x300000},
	W = {0x00C6C6, 0xC6C6D6, 0xD66C6C, 0x6C0000},
	X = {0x00CCCC, 0xCC7830, 0x78CCCC, 0xCC0000},
	Y = {0x00CCCC, 0xCCCC78, 0x303030, 0x780000},
	Z = {0x00FECE, 0x981830, 0x6062C6, 0xFE0000},
	["["] = {0x003C30, 0x303030, 0x303030, 0x3C0000},
	["\\"] = {0x000080, 0xC06030, 0x180C06, 0x020000},
	["]"] = {0x003C0C, 0x0C0C0C, 0x0C0C0C, 0x3C0000},
	["^"] = {0x10386C, 0xC60000, 0x000000, 0x000000},
	["_"] = {0x000000, 0x000000, 0x000000, 0x00FF00},
	a = {0x000000, 0x00780C, 0x7CCCCC, 0x760000},
	b = {0x00E060, 0x607C66, 0x666666, 0xDC0000},
	c = {0x000000, 0x0078CC, 0xC0C0CC, 0x780000},
	d = {0x001C0C, 0x0C7CCC, 0xCCCCCC, 0x760000},
	e = {0x000000, 0x0078CC, 0xFCC0CC, 0x780000},
	f = {0x00386C, 0x6060F8, 0x606060, 0xF00000},
	g = {0x000000, 0x0076CC, 0xCCCC7C, 0x0CCC78},
	h = {0x00E060, 0x606C76, 0x666666, 0xE60000},
	i = {0x001818, 0x007818, 0x181818, 0x7E0000},
	j = {0x000C0C, 0x003C0C, 0x0C0C0C, 0xCCCC78},
	k = {0x00E060, 0x60666C, 0x786C66, 0xE60000},
	l = {0x007818, 0x181818, 0x181818, 0x7E0000},
	m = {0x000000, 0x00FCD6, 0xD6D6D6, 0xC60000},
	n = {0x000000, 0x00F8CC, 0xCCCCCC, 0xCC0000},
	o = {0x000000, 0x0078CC, 0xCCCCCC, 0x780000},
	p = {0x000000, 0x00DC66, 0x666666, 0x7C60F0},
	q = {0x000000, 0x0076CC, 0xCCCCCC, 0x7C0C1E},
	r = {0x000000, 0x00EC6E, 0x766060, 0xF00000},
	s = {0x000000, 0x0078CC, 0x6018CC, 0x780000},
	t = {0x000020, 0x60FC60, 0x60606C, 0x380000},
	u = {0x000000, 0x00CCCC, 0xCCCCCC, 0x760000},
	v = {0x000000, 0x00CCCC, 0xCCCC78, 0x300000},
	w = {0x000000, 0x00C6C6, 0xD6D66C, 0x6C0000},
	x = {0x000000, 0x00C66C, 0x38386C, 0xC60000},
	y = {0x000000, 0x006666, 0x66663C, 0x0C18F0},
	z = {0x000000, 0x00FC8C, 0x1860C4, 0xFC0000},
	["{"] = {0x001C30, 0x3060C0, 0x603030, 0x1C0000},
	bar = {0x001818, 0x181800, 0x181818, 0x180000}, -- ?
	["}"] = {0x00E030, 0x30180C, 0x183030, 0xE00000},
	["~"] = {0x0073DA, 0xCE0000, 0x000000, 0x000000},
	lar = {0x000000, 0x10386C, 0xC6C6FE, 0x000000}, -- ?
}

local function extract_bit(n, b)
	return math.floor(n / 2 ^ math.clamp(b, -1, 24)) % 2
end

local function has_pixel(char, x, y)
	local bit = (WIDTH - x - 1) + y * WIDTH
	return extract_bit(chars[char][1], bit - 72) + extract_bit(chars[char][2], bit - 48) + extract_bit(chars[char][3], bit - 24) + extract_bit(chars[char][4], bit - 00)
end

function META:GetGlyphData(char)
	if not chars[char] then return end

	local buffer = ffi.typeof("unsigned char[$][$][$]", 12, 12, 4)()

	for y = 0, HEIGHT - 1 do
		for x = 0, WIDTH - 1 do
			buffer[y][x][0] = 255
			buffer[y][x][1] = 255
			buffer[y][x][2] = 255
			buffer[y][x][3] = has_pixel(char, x, -y + HEIGHT) == 1 and 255 or 0
		end
	end

	return buffer,
	{
		char = code,
		w = 12,
		h = 12,
		x_advance = WIDTH,
		y_advance = 0,
		bitmap_left = 0,
		bitmap_top = HEIGHT,
		ascender = 0,
	}
end

fonts.RegisterFont(META)