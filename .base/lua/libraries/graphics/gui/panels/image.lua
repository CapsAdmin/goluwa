local gui = ... or _G.gui

local PANEL = {}
PANEL.ClassName = "image"

prototype.GetSet(PANEL, "Path", "loading")

function PANEL:SetPath(path)
	self.Path = path
	self:SetTexture(Texture(path))
end

gui.RegisterPanel(PANEL)