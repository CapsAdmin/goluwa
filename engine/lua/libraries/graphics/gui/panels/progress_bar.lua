local gui = ... or _G.gui

local META = prototype.CreateTemplate("progress_bar")

META:GetSet("Fraction", 0)

function META:Initialize()
	self:SetStyle("frame")

	local green = self:CreatePanel("base")
	green:SetStyle("frame")
	green:SetColor(Color(0,2,0,1))
	self.green = green

	self:SetFraction(self:GetFraction())
end

function META:OnLayout()
	self.green:SetWidth(self:GetWidth() * self.Fraction)
	self.green:SetHeight(self:GetHeight())
end

gui.RegisterPanel(META)