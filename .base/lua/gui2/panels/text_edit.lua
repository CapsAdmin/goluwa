local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "text_edit"

prototype.GetSetDelegate(PANEL, "Text", "", "label")
prototype.GetSetDelegate(PANEL, "ParseTags", false, "label")
prototype.GetSetDelegate(PANEL, "Font", gui2.skin.default_font, "label")
prototype.GetSetDelegate(PANEL, "TextColor", gui2.skin.font_edit_color, "label")
prototype.GetSetDelegate(PANEL, "TextWrap", false, "label")

prototype.Delegate(PANEL, "label", "CenterText", "Center")
prototype.Delegate(PANEL, "label", "CenterTextY", "CenterY")
prototype.Delegate(PANEL, "label", "CenterTextX", "CenterX")
prototype.Delegate(PANEL, "label", "GetTextSize", "GetSize")

function PANEL:Initialize()	
	self:SetColor(gui2.skin.font_edit_background)
	self:SetFocusOnClick(true)
	self.BaseClass.Initialize(self)
	
	local label = gui2.CreatePanel("text", self)
	label:SetFont(self.Font)
	label:SetTextColor(self.TextColor)
	label:SetEditable(true)
	label:SetClipping(true)
	label:SetIgnoreMouse(true)
	self.label = label
	
	label.OnTextChanged = function(_, ...) self:OnTextChanged(...) end
	label.OnEnter = function(_, ...) self:OnEnter(...) end
end

function PANEL:SizeToText()
	local marg = self:GetMargin()
		
	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)
end

function PANEL:OnFocus()
	self.label:SetEditable(true)
end

function PANEL:OnUnfocus()
	self.label:SetEditable(false)
end

function PANEL:OnKeyInput(...)
	self.label:OnKeyInput(...)
end

function PANEL:OnCharInput(...)
	self.label:OnCharInput(...)
end

function PANEL:OnMouseInput(button, press, ...)
	self.label:OnMouseInput(button, press, ...)
end

function PANEL:OnMouseMove(...)
	self.label:OnMouseMove(...)
end

function PANEL:OnEnter() end
function PANEL:OnTextChanged() end
	
gui2.RegisterPanel(PANEL)