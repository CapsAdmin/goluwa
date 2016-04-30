local gui = ... or _G.gui

local META = {}

META.ClassName = "text_button"
META.Base = "button"

prototype.GetSet(META, "SizeToTextOnLayout", false)

prototype.GetSetDelegate(META, "Text", "", "label")
prototype.GetSetDelegate(META, "ParseTags", false, "label")
prototype.GetSetDelegate(META, "Font", nil, "label")
prototype.GetSetDelegate(META, "TextColor", nil, "label")
prototype.GetSetDelegate(META, "TextWrap", false, "label")
prototype.GetSetDelegate(META, "ConcatenateTextToSize", false, "label")

prototype.Delegate(META, "label", "CenterText", "CenterSimple")
prototype.Delegate(META, "label", "CenterTextY", "CenterYSimple")
prototype.Delegate(META, "label", "CenterTextX", "CenterXSimple")
prototype.Delegate(META, "label", "GetTextSize", "GetSize")

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