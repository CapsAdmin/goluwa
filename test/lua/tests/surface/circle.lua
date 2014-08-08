local function create_circle(radius, quality)
    local circle = surface.CreatePoly(quality / 6)
    
    for i = 1, quality do
        
		local tmp = math.rad((i / quality) * 360)
		local s = math.sin(tmp)
		local c = math.cos(tmp)
		
        circle:SetVertex(
			i, 
			c * radius, s * radius, 
			(c + 1) / 2, (s + 1) / 2
		)
    end
	
    return circle
end

local circle = create_circle(64, 64)

event.AddListener("Draw2D", "lol", function()
	surface.SetWhiteTexture()
	surface.SetColor(1,1,1,1)
	
	circle:Draw()
end)