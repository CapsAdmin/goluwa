local gui = ... or _G.gui
local PANEL = {}

PANEL.ClassName = "text_edit"

prototype.GetSet(PANEL, "CaretColor")
prototype.GetSet(PANEL, "SelectionColor")
prototype.GetSet(PANEL, "Editable", true)
prototype.GetSet(PANEL, "CaretPosition", Vec2(0, 0))

prototype.GetSetDelegate(PANEL, "Text", "", "label")
prototype.GetSetDelegate(PANEL, "ParseTags", false, "label")
prototype.GetSetDelegate(PANEL, "Font", nil, "label")
prototype.GetSetDelegate(PANEL, "TextColor", nil, "label")
prototype.GetSetDelegate(PANEL, "TextWrap", false, "label")

prototype.Delegate(PANEL, "label", "CenterText", "Center")
prototype.Delegate(PANEL, "label", "CenterTextY", "CenterY")
prototype.Delegate(PANEL, "label", "CenterTextX", "CenterX")
prototype.Delegate(PANEL, "label", "GetTextSize", "GetSize")

function PANEL:Initialize()
	self:SetStyle("text_edit")
	self:SetFocusOnClick(true)
	self.BaseClass.Initialize(self)

	local label = self:CreatePanel("text", "label")
	label.OnStyleChanged = nil
	label.markup:SetEditable(self.Editable)

	label:SetClipping(true)
	label:SetIgnoreMouse(true)

	self:SetEditable(true)

	label.OnTextChanged = function(_, ...) self:OnTextChanged(...) end
	label.OnEnter = function(_, ...) self:OnEnter(...) end

	self:SetCursor("ibeam")
end

function PANEL:GetMarkup()
	return self.label.markup
end

function PANEL:OnStyleChanged(skin)
	self:SetCaretColor(skin.text_edit_color:Copy())
	self:SetSelectionColor(skin.text_edit_color:Copy():SetAlpha(0.5))
	self:SetTextColor(skin.text_edit_color:Copy())
	self.label:SetTextColor(skin.text_edit_color:Copy())
	self:SetFont(skin.default_font)

	if self.label and self.label.markup then
		self.label.markup:SetCaretColor(self.CaretColor)
		self.label.markup:SetSelectionColor(self.SelectionColor)
	end
end

function PANEL:OnLayout(S)
--	self.label:SetPosition(Vec2()+S)
end

function PANEL:SetCaretPosition(pos)
	self.label.markup:SetCaretPosition(pos.x, pos.y)
end

function PANEL:GetCaretPosition()
	return Vec2(self.label.markup:GetCaretPosition())
end

function PANEL:SelectAll()
	self.label.markup:SelectAll()
end

function PANEL:SetEditable(b)
	self.Editable = b
	self.label.markup:SetEditable(b)
end

function PANEL:SizeToText()
	local marg = self:GetMargin()

	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)
end

function PANEL:OnFocus()
	if self.Editable then
		self.label.markup:SetEditable(true)
	end
end

function PANEL:OnUnfocus()
	self.label.markup:SetEditable(false)
end

function PANEL:OnKeyInput(...)
	return self.label:OnKeyInput(...)
end

function PANEL:OnCharInput(...)
	return self.label:OnCharInput(...)
end

function PANEL:OnMouseInput(button, press, ...)
	self.label:OnMouseInput(button, press, ...)
end

function PANEL:OnMouseMove(...)
	self.label:OnMouseMove(...)
end

function PANEL:OnEnter() end
function PANEL:OnTextChanged() end

gui.RegisterPanel(PANEL)