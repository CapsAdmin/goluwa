window.Open(500, 500)

local tex = Texture("textures/aahh/pac.png")
local count = 1
local poly = surface.CreatePoly(count)
 
event.AddListener("Draw2D", "lol", function()
	local time = timer.GetSystemTime()
	for i = 1, count do
	--	poly:SetColor(math.random(), math.random(), math.random(), math.random())
		poly:SetRect(i, 64, 64, 32, 32, timer.GetSystemTime())
		--poly:SetRect(i, (math.sin(time+i)*128)+256, (math.cos(time+i)*128)+256, 32, 32,math.sin(time+i))
	end

	surface.Color(1,1,1,1)
	surface.SetTexture(tex)
  	
	poly:Draw()	
end)                                   