function gmod.env.HSVToColor(h,s,v)
	return gmod.env.Color(ColorHSV(h*360,s,v):Unpack())
end

function gmod.env.ColorToHSV(r,g,b)
	if type(r) == "table" then
		local t = r
		r = t.r
		g = t.g
		b = t.b
	end
	return ColorBytes(r,g,b):GetHSV()
end