local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+128)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.5,0.5,0.5,1))
base:SetMargin(Rect()+4)
base:SetName("base")

local scroll = base:CreatePanel("scroll")
scroll:SetupLayout("fill")

local area = gui.CreatePanel("base")
area:SetColor(Color(1,0,1,0.1))
--area:SetSize(Vec2()+300)
scroll:SetPanel(area)

local i = 0

function area:Add(w,h)
	local pnl = self:CreatePanel("button")
	pnl:SetSize(Vec2(w, h or w))
	pnl:SetColor(ColorHSV(i/2, 1, 1):SetAlpha(0.75)*2)
	pnl:SetName("test" .. i+1)
	pnl:SetPadding(Rect()+8)
	local lbl = pnl:CreatePanel("text")
	lbl:SetText(i+1)
	lbl:SetupLayout("center_simple")

	i = i + 1

	return pnl
end

for i = 1, 10 do
area:Add(math.random(16,64)):SetPosition(Vec2():GetRandom()*100)
end
area:SetupLayout("size_to_children")
