local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(Vec2(300,300))
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(Color(0.1,0.1,0.1,1))
--base:SetMargin(Rect()+16)
base:SetName("base")
base:SetMargin(Rect()+8)

local function add(self, w,h)
	self.i = self.i or 0

	local pnl = self:CreatePanel("button")
	pnl:SetSize(Vec2(w, h or w))
	pnl:SetColor(ColorHSV(self.i/4, 1, 1):SetAlpha(1)*2)
	pnl:SetName("test" .. self.i+1)
	local lbl = pnl:CreatePanel("text")
	lbl:SetText(self.i+1)
	lbl:SetupLayout("center_simple")
	lbl:NoCollide()

	self.i = self.i + 1

	return pnl
end

local hm = add(base, 100)
hm:SetMargin(Rect()+4)
hm:SetupLayout("SizeToChildren")

add(hm, 32):SetupLayout("top")
add(hm, 32):SetupLayout("top")
add(hm, 32):SetupLayout("top")
add(hm, 32):SetupLayout("top")

base:SetupLayout("SizeToChildren", "CenterSimple")


