local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2(300,300))
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.1,0.1,0.1,1))
--base:SetMargin(Rect()+16)
base:SetName("base")
base:SetMargin(Rect()+8)

local hm = base:CreatePanel("button")
hm:SetSize(Vec2() + 200)
hm:SetupLayout("SizeToChildren", "CenterSimple")

-- this will cause the total size to shrink on layout
-- how to detect and warn or prevent this?
local dot = hm:CreatePanel("button")
dot:SetSize(Vec2() + 8)
dot:SetupLayout("CenterXSimple")

local dot = hm:CreatePanel("button")
dot:SetSize(Vec2() + 8)
dot:SetupLayout("CenterYSimple")