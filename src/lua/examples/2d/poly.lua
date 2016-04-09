local tex = render.CreateTextureFromPath("textures/pac.png")
local count = 100
local poly = surface.CreatePoly(count * 6)

event.AddListener("Draw2D", "lol", function()
	local time = system.GetElapsedTime()

	for i = 1, count do
		poly:SetColor(math.random(), math.random(), math.random(), math.random())
		poly:SetRect(i, (math.sin(time+i)*128)+256, (math.cos(time+i)*128)+256, 64, 64,math.sin(time+i))
	end

	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)

	poly:Draw()
end)