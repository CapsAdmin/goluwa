local panel = gui.CreatePanel("frame", nil, "lol")
panel:SetSize(Vec2() + 500)
panel:CenterSimple()
panel:SetResizable(true)

local scroll = panel:CreatePanel("base")
scroll:SetupLayout("fill")
scroll:SetPadding(Rect()+4)
scroll:SetStyle("frame")

local lol = scroll:CreatePanel("text")
runfile("lua/examples/2d/markup.lua", lol.markup)

local old = panel.OnLayout
function panel:OnLayout(...)
	return old(self, ...)
end

scroll.lol = true

function scroll:OnUpdate()
	local t = system.GetElapsedTime()
	local s = math.sin(t) * 0.5 + 0.5
	local c = math.cos(t) * 0.5 + 0.5
	self:SetScrollFraction(Vec2(0,1))
	--panel:SetTitle(tostring(self:GetScrollFraction()))
end