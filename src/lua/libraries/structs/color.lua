local structs = (...) or _G.structs
-- not very efficent

local META = {}

META.ClassName = "Color"

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

META.NumberType = "float"
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
	local _h,s,l = ColorToHSV(self)
	_h = (_h + h)%360
	local new = HSVToColor(_h, s, l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:SetComplementary()
	return 	self:SetHue(180)
end

function META:GetNeighbors(angle)
   local angle = angle or 30
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
	local h, _s, l = ColorToHSV(self)
	_s = s
	local new = HSVToColor(h, _s, l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:SetLightness(l)
	local h, s, _l = ColorToHSV(self)
	_l = l
	local new = HSVToColor(h, s, _l, self.a)
	self.r = new.r
	self.g = new.g
	self.b = new.b

	return self
end

function META:GetTints(count)
	local tbl = {}

	for i = 1, count do
		local h,s,v = ColorToHSV(self)
		local copy = self:Copy()
		copy:SetLightness(v + ( 1 - v) / count * i)
		table.insert(tbl, copy)
	end

   return tbl
end

function META:GetShades(count)
	local tbl = {}

	for i = 1, count do
		local h,s,v = ColorToHSV(self)
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
	local h,s,v = ColorToHSV(self)
	self:SetLightness(v + (1 - v) * num)

	return self
end

function META:SetShade(num)
	local h,s,v = ColorToHSV(self)
	self:SetLightness(v - v * num)

	return self
end

-- http://code.google.com/p/sm-ssc/source/browse/Themes/_fallback/Scripts/02+Colors.lua?spec=svnca631130221f6ed8b9065685186fb696660bc79a&name=ca63113022&r=ca631130221f6ed8b9065685186fb696660bc79a

function HSVToColor(h, s, v, a)
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

function ColorToHSV(c)
	local r = c.r
	local g = c.g
	local b = c.b

	local h = 0
	local s = 0
	local v = 0

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

	h = h * 60 -- degrees

	if h < 0 then
		h = h + 360
	end

	return h, s, v
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("color", function(var) return ("Color(%f, %f, %f, %f)"):format(var:Unpack()) end, structs.Color, "Color")