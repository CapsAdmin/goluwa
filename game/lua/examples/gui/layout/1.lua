local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+128*2)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.1,0.1,0.1,1))
base:SetMargin(Rect()+16)
base:SetName("base")
local i = 0

function base:Add(w,h)
	local pnl = base:CreatePanel("button")
	pnl:SetSize(Vec2(w, h or w))
	pnl:SetColor(ColorHSV(i/100, 1, 1):SetAlpha(0.75)*2)
	pnl:SetName("test" .. i+1)
	pnl:SetPadding(Rect()+2)
	local lbl = pnl:CreatePanel("text")
	lbl:SetText(i+1)
	lbl:SetupLayout("center_simple")

	i = i + 1

	return pnl
end

for i = 1, 8 do
	base:Add(8):SetupLayout("gmod_bottom")
	base:Add(8):SetupLayout("gmod_top")
	base:Add(8):SetupLayout("gmod_left")
	base:Add(8):SetupLayout("gmod_right")
end