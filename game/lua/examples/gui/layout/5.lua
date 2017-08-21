local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2(80,82))
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.1,0.1,0.1,1))
--base:SetMargin(Rect()+16)
base:SetName("base")
base:SetMargin(Rect(0,8,0,8))
local i = 0

function base:Add(w,h)
	local pnl = base:CreatePanel("button")
	pnl:SetSize(Vec2(w, h or w))
	pnl:SetColor(ColorHSV(i/4, 1, 1):SetAlpha(1)*2)
	pnl:SetName("test" .. i+1)
	local lbl = pnl:CreatePanel("text")
	lbl:SetText(i+1)
	lbl:SetupLayout("center_simple")

	i = i + 1

	return pnl
end


base:Add(64):SetupLayout("gmod_top")
base:Add(30,14):SetupLayout("gmod_bottom")

