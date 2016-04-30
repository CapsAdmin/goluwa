local gui = ... or _G.gui

local META = {}
META.ClassName = "image"

prototype.GetSet(META, "Path", "loading")

function META:SetPath(path)
	self.Path = path
	self:SetTexture(render.CreateTextureFromPath(path))
end

gui.RegisterPanel(META)