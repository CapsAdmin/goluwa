local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+128*2)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.1,0.1,0.1,1))
base:SetMargin(Rect()+16)
base:SetName("base")


local btn = base:CreatePanel("button")
btn:SetSize(Vec2() + 32)
btn:SetMouseZPos(0)

local btn = base:CreatePanel("button")
btn:SetSize(Vec2() + 32)
btn:SetPosition(Vec2() + 8)
btn:SetMouseZPos(1)
