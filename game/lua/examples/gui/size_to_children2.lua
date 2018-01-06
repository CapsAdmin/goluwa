local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+128)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.5,0.5,0.5,1))
base:SetMargin(Rect()+4)
base:SetName("base")
local i = 0

function base:Add(w,h)
	local pnl = base:CreatePanel("button")
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

base:Add(32):SetupLayout("top", "fill_x")
base:Add(32):SetupLayout("fill")

base:SizeToChildren()
base:CenterSimple()
