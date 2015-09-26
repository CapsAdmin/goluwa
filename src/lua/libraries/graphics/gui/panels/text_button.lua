local gui = ... or _G.gui

local PANEL = {}

PANEL.ClassName = "text_button"
PANEL.Base = "button"

prototype.GetSet(PANEL, "SizeToTextOnLayout", false)

prototype.GetSetDelegate(PANEL, "Text", "", "label")
prototype.GetSetDelegate(PANEL, "ParseTags", false, "label")
prototype.GetSetDelegate(PANEL, "Font", nil, "label")
prototype.GetSetDelegate(PANEL, "TextColor", nil, "label")
prototype.GetSetDelegate(PANEL, "TextWrap", false, "label")
prototype.GetSetDelegate(PANEL, "ConcatenateTextToSize", false, "label")

prototype.Delegate(PANEL, "label", "CenterText", "Center")
prototype.Delegate(PANEL, "label", "CenterTextY", "CenterY")
prototype.Delegate(PANEL, "label", "CenterTextX", "CenterX")
prototype.Delegate(PANEL, "label", "GetTextSize", "GetSize")

function PANEL:Initialize()
	prototype.GetRegistered(self.Type, "button").Initialize(self)

	local label = self:CreatePanel("text", "label")
	label:SetIgnoreMouse(true)
	self:Layout(true)
	self:SetLayoutWhenInvisible(false)
end

function PANEL:SizeToText()
	local marg = self:GetMargin()

	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)

	self.LayoutSize = self:GetSize():Copy()
end

function PANEL:OnLayout(S)
	if self.SizeToTextOnLayout then
		self:SizeToText()
	end
end

gui.RegisterPanel(PANEL)