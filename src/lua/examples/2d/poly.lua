local tex = render.CreateTextureFromPath("textures/pac.png")
local count = 100
local poly = gfx.CreatePolygon2D(count * 6)

event.AddListener("PreDrawGUI", "lol", function()
	local time = system.GetElapsedTime()

	for i = 1, count do
		poly:SetColor(math.random(), math.random(), math.random(), math.random())
		poly:SetRect(i, (math.sin(time+i)*128)+256, (math.cos(time+i)*128)+256, 64, 64,math.sin(time+i))
	end

	render2d.SetColor(1,1,1,1)
	render2d.SetTexture(tex)

	poly:Draw()
end)