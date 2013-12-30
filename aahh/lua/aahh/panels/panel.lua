local PANEL = {}

PANEL.ClassName = "panel"

function PANEL:OnDraw()
	self:DrawHook("PanelDraw")
end

aahh.RegisterPanel(PANEL, "panel")