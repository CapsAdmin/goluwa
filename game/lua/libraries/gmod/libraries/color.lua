function gine.env.HSVToColor(h,s,v)
	local r,g,b,a = ColorHSV(h/360,s,v):Unpack()
	return gine.env.Color(r*255,g*255,b*255,a*255)
end

function gine.env.ColorToHSV(r,g,b)
	if type(r) == "table" then
		local t = r
		r = t.r
		g = t.g
		b = t.b
	end

	local h,s,v = ColorBytes(r,g,b):GetHSV()

	return h * 360, s, v
end
