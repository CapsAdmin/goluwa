local PANEL = {}

PANEL.ClassName = "panel"

function PANEL:OnDraw()
	self:DrawHook("PanelDraw")
end

gui.RegisterPanel(PANEL, "panel")