local structs = (...) or _G.structs
-- not very efficent

local META = prototype.CreateTemplate("Color")

function ColorBytes(r, g, b, a)
	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 255

	return Color(r/255, g/255, b/255, a/255)
end

function ColorHex(hex, a)
	local r,g,b = hex:match("#?(..)(..)(..)")
	r = tonumber("0x" .. (r or 0))
	g = tonumber("0x" .. (g or 0))
	b = tonumber("0x" .. (b or 0))
	return ColorBytes(r, g, b, a)
end

do
	local names = {
		aliceblue = "#f0f8ff",
		antiquewhite = "#faebd7",
		aqua = "#00ffff",
		aquamarine = "#7fffd4",
		azure = "#f0ffff",
		beige = "#f5f5dc",
		bisque = "#ffe4c4",
		black = "#000000",
		blanchedalmond = "#ffebcd",
		blue = "#0000ff",
		blueviolet = "#8a2be2",
		brown = "#a52a2a",
		burlywood = "#deb887",
		cadetblue = "#5f9ea0",
		chartreuse = "#7fff00",
		chocolate = "#d2691e",
		coral = "#ff7f50",
		cornflowerblue = "#6495ed",
		cornsilk = "#fff8dc",
		crimson = "#dc143c",
		cyan = "#00ffff",
		darkblue = "#00008b",
		darkcyan = "#008b8b",
		darkgoldenrod = "#b8860b",
		darkgray = "#a9a9a9",
		darkgreen = "#006400",
		darkgrey = "#a9a9a9",
		darkkhaki = "#bdb76b",
		darkmagenta = "#8b008b",
		darkolivegreen = "#556b2f",
		darkorange = "#ff8c00",
		darkorchid = "#9932cc",
		darkred = "#8b0000",
		darksalmon = "#e9967a",
		darkseagreen = "#8fbc8f",
		darkslateblue = "#483d8b",
		darkslategray = "#2f4f4f",
		darkslategrey = "#2f4f4f",
		darkturquoise = "#00ced1",
		darkviolet = "#9400d3",
		deeppink = "#ff1493",
		deepskyblue = "#00bfff",
		dimgray = "#696969",
		dimgrey = "#696969",
		dodgerblue = "#1e90ff",
		firebrick = "#b22222",
		floralwhite = "#fffaf0",
		forestgreen = "#228b22",
		fuchsia = "#ff00ff",
		gainsboro = "#dcdcdc",
		ghostwhite = "#f8f8ff",
		gold = "#ffd700",
		goldenrod = "#daa520",
		gray = "#808080",
		green = "#008000",
		greenyellow = "#adff2f",
		grey = "#808080",
		honeydew = "#f0fff0",
		hotpink = "#ff69b4",
		indianred = "#cd5c5c",
		indigo = "#4b0082",
		ivory = "#fffff0",
		khaki = "#f0e68c",
		lavender = "#e6e6fa",
		lavenderblush = "#fff0f5",
		lawngreen = "#7cfc00",
		lemonchiffon = "#fffacd",
		lightblue = "#add8e6",
		lightcoral = "#f08080",
		lightcyan = "#e0ffff",
		lightgoldenrodyellow = "#fafad2",
		lightgray = "#d3d3d3",
		lightgreen = "#90ee90",
		lightgrey = "#d3d3d3",
		lightpink = "#ffb6c1",
		lightsalmon = "#ffa07a",
		lightseagreen = "#20b2aa",
		lightskyblue = "#87cefa",
		lightslategray = "#778899",
		lightslategrey = "#778899",
		lightsteelblue = "#b0c4de",
		lightyellow = "#ffffe0",
		lime = "#00ff00",
		limegreen = "#32cd32",
		linen = "#faf0e6",
		magenta = "#ff00ff",
		maroon = "#800000",
		mediumaquamarine = "#66cdaa",
		mediumblue = "#0000cd",
		mediumorchid = "#ba55d3",
		mediumpurple = "#9370db",
		mediumseagreen = "#3cb371",
		mediumslateblue = "#7b68ee",
		mediumspringgreen = "#00fa9a",
		mediumturquoise = "#48d1cc",
		mediumvioletred = "#c71585",
		midnightblue = "#191970",
		mintcream = "#f5fffa",
		mistyrose = "#ffe4e1",
		moccasin = "#ffe4b5",
		navajowhite = "#ffdead",
		navy = "#000080",
		oldlace = "#fdf5e6",
		olive = "#808000",
		olivedrab = "#6b8e23",
		orange = "#ffa500",
		orangered = "#ff4500",
		orchid = "#da70d6",
		palegoldenrod = "#eee8aa",
		palegreen = "#98fb98",
		paleturquoise = "#afeeee",
		palevioletred = "#db7093",
		papayawhip = "#ffefd5",
		peachpuff = "#ffdab9",
		peru = "#cd853f",
		pink = "#ffc0cb",
		plum = "#dda0dd",
		powderblue = "#b0e0e6",
		purple = "#800080",
		rebeccapurple = "#663399",
		red = "#ff0000",
		rosybrown = "#bc8f8f",
		royalblue = "#4169e1",
		saddlebrown = "#8b4513",
		salmon = "#fa8072",
		sandybrown = "#f4a460",
		seagreen = "#2e8b57",
		seashell = "#fff5ee",
		sienna = "#a0522d",
		silver = "#c0c0c0",
		skyblue = "#87ceeb",
		slateblue = "#6a5acd",
		slategray = "#708090",
		slategrey = "#708090",
		snow = "#fffafa",
		springgreen = "#00ff7f",
		steelblue = "#4682b4",
		tan = "#d2b48c",
		teal = "#008080",
		thistle = "#d8bfd8",
		tomato = "#ff6347",
		turquoise = "#40e0d0",
		violet = "#ee82ee",
		wheat = "#f5deb3",
		white = "#ffffff",
		whitesmoke = "#f5f5f5",
		yellow = "#ffff00",
		yellowgreen = "#9acd32"
	}
	function ColorName(name)
		return ColorHex(names[name:lower()] or names.black)
	end
end


-- http://code.google.com/p/sm-ssc/source/browse/Themes/_fallback/Scripts/02+Colors.lua?spec=svnca631130221f6ed8b9065685186fb696660bc79a&name=ca63113022&r=ca631130221f6ed8b9065685186fb696660bc79a

function ColorHSV(h, s, v, a)
	h = (h%1 * 360) / 60
	s = s or 1
	v = v or 1
	a = a or 1

	if s == 0 then
		return Color(v, v, v, a)
	end

	local i = math.floor(h)
	local f = h - i
	local p = v * (1-s)
	local q = v * (1-s*f)
	local t = v * (1-s*(1-f))

	if i == 0 then
		return Color(v, t, p, a)
	elseif i == 1 then
		return Color(q, v, p, a)
	elseif i == 2 then
		return Color(p, v, t, a)
	elseif i == 3 then
		return Color(p, q, v, a)
	elseif i == 4 then
		return Color(t, p, v, a)
	end

	return Color(v, p, q, a)
end

META.NumberType = "double"
META.Args = {"r", "g", "b", "a"}
META.ProtectedFields = {a = true}

structs.AddAllOperators(META)

function META:Unpack()
	return self.r, self.g, self.b, self.a
end
function META:Lighter(factor)
	factor = factor or .5
	factor = factor+1
	return Color( self.r*factor, self.g*factor, self.b*factor, self.a )
end
function META:Darker(factor)
	return self:Lighter( ( 1 - ( factor or .5 ) )-1 )
end
function META:Get255()
	return Color(self.r * 255, self.g * 255, self.b * 255, self.a * 255)
end

function META:SetAlpha(a)
	self.a = a
	return self
end

function META:SetHue(h)
	local _h,s,l = self:GetHSV()
	_h = (_h + h)%1
	local new = ColorHSV(_h, s, l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:SetComplementary()
	return self:SetHue(math.pi)
end

function META:GetNeighbors(angle)
   angle = angle or 30
   return self:SetHue(angle), self:SetHue(360 - angle)
end

function META:GetNeighbors()
   return self:GetNeighbors(120)
end

function META:GetSplitComplementary(angle)
   return self:GetNeighbors(180 - (angle or 30))
end

function META.Lerp(a, mult, b)

	a.r = (b.r - a.r) * mult + a.r
	a.g = (b.g - a.g) * mult + a.g
	a.b = (b.b - a.b) * mult + a.b

	a.a = (b.a - a.a) * mult + a.a

	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:SetSaturation(s)
	local h, _, l = self:GetHSV()
	local new = ColorHSV(h, s, l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:SetLightness(l)
	local h, s, _ = self:GetHSV()
	local new = ColorHSV(h, s, l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:GetTints(count)
	local tbl = {}

	for i = 1, count do
		local _,_,v = self:GetHSV()
		local copy = self:Copy()
		copy:SetLightness(v + ( 1 - v) / count * i)
		table.insert(tbl, copy)
	end

   return tbl
end

function META:GetShades(count)
	local tbl = {}

	for i = 1, count do
		local _,_,v = self:GetHSV()
		local copy = self:Copy()
		copy:SetLightness(v - (v) / count * i)
		table.insert(tbl, copy)
	end

   return tbl
end

function META:GetHex()
	return bit.bor(bit.lshift(self.r*255, 16), bit.lshift(self.g*255, 8), self.b*255)
end

function META:SetTint(num)
	local _,_,v = self:GetHSV()
	self:SetLightness(v + (1 - v) * num)

	return self
end

function META:SetShade(num)
	local _,_,v = self:GetHSV()
	self:SetLightness(v - v * num)

	return self
end

function META:GetHSV()
	local r = self.r
	local g = self.g
	local b = self.b

	local h
	local s
	local v

	local min = math.min( r, g, b )
	local max = math.max( r, g, b )
	v = max

	local delta = max - min

	-- xxx: how do we deal with complete black?
	if min == 0 and max == 0 then
		-- we have complete darkness; make it cheap.
		return 0, 0, 0
	end

	if max ~= 0 then
		s = delta / max -- rofl deltamax :|
	else
		-- r = g = b = 0; s = 0, v is undefined
		s = 0
		h = -1
		return h, s, v
	end

	if r == max then
		h = ( g - b ) / delta     -- yellow/magenta
	elseif g == max then
		h = 2 + ( b - r ) / delta -- cyan/yellow
	else
		h = 4 + ( r - g ) / delta -- magenta/cyan
	end

	if h < 0 then
		h = h + 1
	end

	return h, s, v
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("color", function(var) return ("Color(%f, %f, %f, %f)"):format(var:Unpack()) end, structs.Color, "Color")
