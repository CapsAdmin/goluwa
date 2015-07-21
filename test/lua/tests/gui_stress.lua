local world = gui.CreatePanel("base", nil, "test")
world:SetResizable(true)
world:SetSize(Vec2(surface.GetSize()))

world:SetStack(true)

for i = 1, 3000 do
	local child = world:CreatePanel("base")
	child:SetStyle("frame")
	child:SetSize(Vec2()+16)
	child:SetColor(HSVToColor(math.random()))
end