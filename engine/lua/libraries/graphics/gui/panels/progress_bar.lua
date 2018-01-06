local gui = ... or _G.gui

local META = prototype.CreateTemplate("progress_bar")

META:GetSet("Fraction", 0)

function META:Initialize()
	self:SetStyle("frame")

	local green = self:CreatePanel("base")
	green:SetStyle("frame")
	green:SetColor(Color(0,2,0,1))
	self.green = green

	local percent = self:CreatePanel("text")
	percent:SetupLayout("center_simple")
	self.percent = percent

	self:SetFraction(self:GetFraction())
end

function META:SetFraction(f)
	self:Layout()
	self.Fraction = f
end

function META:OnLayout()
	self.green:SetWidth(self:GetWidth() * self.Fraction)
	self.green:SetHeight(self:GetHeight())

	self.percent:SetText(math.round(self.Fraction * 100, 2) .. "%")
end

gui.RegisterPanel(META)