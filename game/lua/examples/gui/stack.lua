local base = gui.CreatePanel("frame", nil, "lol")
base:SetSize(Vec2()+128*2)
base:CenterSimple()

local area = base:CreatePanel("base")
area:SetupLayout("fill")
area:SetStack(true)
area:SetStackDown(false)

for i = 1, 5 do
	local btn = area:CreatePanel("button")
	btn:SetSize(Vec2()+16)
end
