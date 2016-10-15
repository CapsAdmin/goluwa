function gine.env.HSVToColor(h,s,v)
	return gine.env.Color(ColorHSV(h*360,s,v):Unpack())
end

function gine.env.ColorToHSV(r,g,b)
	if type(r) == "table" then
		local t = r
		r = t.r
		g = t.g
		b = t.b
	end
	return ColorBytes(r,g,b):GetHSV()
end
