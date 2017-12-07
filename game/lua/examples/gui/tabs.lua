local base = gui.CreatePanel("frame", nil, "lol")
base:SetSize(Vec2()+128*2)
base:CenterSimple()

local tabs = base:CreatePanel("tab")
tabs:SetupLayout("fill")

local content = tabs:AddTab("hello")
local pnl = content:CreatePanel("base")
pnl:SetupLayout("fill")
pnl:SetColor(Color(1,1,0,1))

local content = tabs:AddTab("world")
local pnl = content:CreatePanel("base")
pnl:SetupLayout("fill")
pnl:SetColor(Color(1,0,1,1))