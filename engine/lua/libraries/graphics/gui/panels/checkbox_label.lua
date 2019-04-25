local gui = ... or _G.gui

local META = prototype.CreateTemplate("checkbox_label")

META:GetSetDelegate("Text", "", "label")
META:GetSetDelegate("ParseTags", false, "label")
META:GetSetDelegate("Font", nil, "label")
META:GetSetDelegate("TextColor", nil, "label")
META:GetSetDelegate("TextWrap", false, "label")
META:GetSetDelegate("ConcatenateTextToSize", false, "label")
META:GetSetDelegate("State", false, "checkbox")

META:Delegate("label", "CenterText", "Center")
META:Delegate("label", "CenterTextY", "CenterY")
META:Delegate("label", "CenterTextX", "CenterX")
META:Delegate("label", "GetTextSize", "GetSize")

function META:Initialize()
	self:SetNoDraw(true)

	local check = self:CreatePanel("button", "checkbox")
	check:SetActiveStyle("check")
	check:SetInactiveStyle("uncheck")
	check:SetMode("radio")
	check.OnCheck = function(_, b) self:OnCheck(b) end

	local label = self:CreatePanel("text", "label")
	self:Layout(true)
end

function META:TieCheckbox(checkbox)
	self.checkbox:TieCheckbox(checkbox.checkbox)
end

function META:IsChecked()
	return self.checkbox:GetState()
end

function META:OnCheck(b)

end

function META:SizeToText()
	local marg = self:GetMargin()

	self.checkbox:SetX(0)
	self.label:SetX(self.checkbox:GetPosition().x + marg:GetLeft() + self.checkbox:GetWidth() + self.checkbox:GetPadding():GetRight())
	self:SetSize(self.label:GetPosition() + Vec2(marg:GetLeft(), 0) + self.label:GetSize() + marg:GetSize())
	self.label:CenterY()
	self.checkbox:CenterY()

	if self.LayoutSize then
		self.LayoutSize = self:GetSize():Copy()
	end
end

gui.RegisterPanel(META)
