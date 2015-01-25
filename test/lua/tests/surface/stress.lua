window.Open(500, 500)

local cache = {}

event.AddListener("Draw2D", "lol", function()
	surface.SetWhiteTexture()
	local time = system.GetElapsedTime()
	
	for x = 1, 512 do
	for y = 1, 512 do
		
		local h =  math.ceil((time + (x/y))* 100)
		local c = cache[h] or HSVToColor(h/100,1,1)
		cache[h] = c
		
		surface.SetColor(c.r,c.g,c.b, 0.5)
		surface.DrawRect(x, y, 1, 1)
	end
	end	
end)