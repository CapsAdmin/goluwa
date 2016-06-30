local gui = ... or _G.gui

local META = {}
META.ClassName = "image"

prototype.GetSet(META, "Path", "loading")
prototype.GetSet(META, "SizeToImage", false)

function META:SetPath(path)
	self.Path = path
	self:SetTexture(render.CreateTextureFromPath(path))
end

function META:OnLayout()
	if self.SizeToImage then
		self:SetSize(self.Texture:GetSize():Copy())
	end
end

gui.RegisterPanel(META)