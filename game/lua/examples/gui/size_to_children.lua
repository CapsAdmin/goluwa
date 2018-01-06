local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2()+100)
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.5,0.5,0.5,1))
base:SetMargin(Rect()+32)
base:SetName("base")
local i = 0

function base:Add(pos, w,h)
	local pnl = base:CreatePanel("button")
	pnl:SetSize(Vec2(w, h or w))
	pnl:SetPosition(pos)
	pnl:SetColor(ColorHSV(i/100, 1, 1):SetAlpha(0.75)*2)
	pnl:SetName("test" .. i+1)
	--pnl:SetPadding(Rect()+8)
	local lbl = pnl:CreatePanel("text")
	lbl:SetText(i+1)
	lbl:SetupLayout("center_simple")

	i = i + 1

	return pnl
end

for i = 1, 32 do
	base:Add(Vec2():GetRandom(300), math.random(32, 128))
end

base:SizeToChildren()
base:CenterSimple()
