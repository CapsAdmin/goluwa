-- not very efficent

local META = {}

META.ClassName = "Color"

function META.Constructor(r,g,b,a)
	if type(r) == "string" then
		r,g,b = r:match("#?(..)(..)(..)")
		r = tonumber("0x" .. r)
		g = tonumber("0x" .. g)
		b = tonumber("0x" .. b)
	end

	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 1
	
	if r > 1 then r = r / 255 end
	if g > 1 then g = g / 255 end
	if b > 1 then b = b / 255 end
	if a > 1 then a = a / 255 end

	return r,g,b,a
end

META.NumberType = "float"
META.Args = {"r", "g", "b", "a"}
META.ProtectedFields = {a = true}

structs.AddAllOperators(META)

function META:SetHue(h)
	local _h,s,l = ColorToHSV(self)
	_h = (_h + h)%360
	local new = HSVToColor(_h, s, l)
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

function META:SetSaturation(s)
	local h, _s, l = ColorToHSV(self)
	_s = s
	local new = HSVToColor(h, _s, l)
	self.r = new.r
	self.g = new.g
	self.b = new.b
	
	return self
end

function META:SetLightness(l)
	local h, s, _l = ColorToHSV(self)
	_l = l
	local new = HSVToColor(h, s, _l)
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

function META:GetShades()
	local tbl = {}

	for i = 1, count do
		local h,s,v = ColorToHSV(self)
		local copy = self:Copy()
		copy:SetLightness(v - (v) / count * i)
		table.insert(tbl, copy)
	end

   return tbl
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

function HSVToColor(hue, sat, val)
	hue = hue%360

	local i
	local f, q, p, t
	local r, g, b
	local h, s, v

	s = sat
	v = val

	if s == 0 then
		return Color(v, v, v)
	end

	h = hue / 60

	i = math.floor(h)
	f = h - i
	p = v * (1-s)
	q = v * (1-s*f)
	t = v * (1-s*(1-f))

	if i == 0 then
		return Color(v, t, p)
	elseif i == 1 then
		return Color(q, v, p)
	elseif i == 2 then
		return Color(p, v, t)
	elseif i == 3 then
		return Color(p, q, v)
	elseif i == 4 then
		return Color(t, p, v)
	end

	return Color(v, p, q)
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

color_white = Color(1,1,1,1)
color_black = Color(0,0,0,1)