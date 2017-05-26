local gui = ... or _G.gui

local META = prototype.CreateTemplate("image")

META:GetSet("Path", "loading")
META:GetSet("SizeToImage", false)

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
