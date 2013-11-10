window.Open(500, 500)

local tex = Image("textures/aahh/pac.png")
local count = 1
local poly = surface.CreatePoly(count)
 
event.AddListener("OnDraw2D", "lol", function()
	local time = glfw.GetTime()
	for i = 1, count do
	--	poly:SetColor(math.random(), math.random(), math.random(), math.random())
		poly:SetRect(i, 64, 64, 32, 32, glfw.GetTime())
		--poly:SetRect(i, (math.sin(time+i)*128)+256, (math.cos(time+i)*128)+256, 32, 32,math.sin(time+i))
	end

	surface.Color(1,1,1,1)
	surface.SetTexture(tex)
  	
	surface.DrawPoly(poly)	
end)                                   