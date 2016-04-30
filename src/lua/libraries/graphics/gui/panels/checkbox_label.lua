local gui = ... or _G.gui

local META = {}

META.ClassName = "checkbox_label"

prototype.GetSetDelegate(META, "Text", "", "label")
prototype.GetSetDelegate(META, "ParseTags", false, "label")
prototype.GetSetDelegate(META, "Font", nil, "label")
prototype.GetSetDelegate(META, "TextColor", nil, "label")
prototype.GetSetDelegate(META, "TextWrap", false, "label")
prototype.GetSetDelegate(META, "ConcatenateTextToSize", false, "label")
prototype.GetSetDelegate(META, "State", false, "checkbox")

prototype.Delegate(META, "label", "CenterText", "Center")
prototype.Delegate(META, "label", "CenterTextY", "CenterY")
prototype.Delegate(META, "label", "CenterTextX", "CenterX")
prototype.Delegate(META, "label", "GetTextSize", "GetSize")

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