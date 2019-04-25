local gui = ... or _G.gui

local META = prototype.CreateTemplate("text_button")
META.Base = "button"

META:GetSet("SizeToTextOnLayout", false)

META:GetSetDelegate("Text", "", "label")
META:GetSetDelegate("ParseTags", false, "label")
META:GetSetDelegate("Font", nil, "label")
META:GetSetDelegate("TextColor", nil, "label")
META:GetSetDelegate("TextWrap", false, "label")
META:GetSetDelegate("ConcatenateTextToSize", false, "label")

META:Delegate("label", "CenterText", "CenterSimple")
META:Delegate("label", "CenterTextY", "CenterYSimple")
META:Delegate("label", "CenterTextX", "CenterXSimple")
META:Delegate("label", "GetTextSize", "GetSize")

function META:Initialize()
	prototype.GetRegistered(self.Type, "button").Initialize(self)

	local label = self:CreatePanel("text", "label")
	label:SetIgnoreMouse(true)
	self:Layout(true)
	self:SetLayoutWhenInvisible(false)
end

function META:SizeToText()
	local marg = self:GetMargin()

	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)

	self.LayoutSize = self:GetSize():Copy()
end

function META:OnLayout(S)
	if self.SizeToTextOnLayout then
		self:SizeToText()
	end
end

gui.RegisterPanel(META)
