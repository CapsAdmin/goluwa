local gui = ... or _G.gui
local META = {}

META.ClassName = "text_edit"

prototype.GetSet(META, "CaretColor")
prototype.GetSet(META, "SelectionColor")
prototype.GetSet(META, "Editable", true)
prototype.GetSet(META, "CaretPosition", Vec2(0, 0))

prototype.GetSetDelegate(META, "Text", "", "label")
prototype.GetSetDelegate(META, "ParseTags", false, "label")
prototype.GetSetDelegate(META, "Font", nil, "label")
prototype.GetSetDelegate(META, "TextColor", nil, "label")
prototype.GetSetDelegate(META, "TextWrap", false, "label")

prototype.Delegate(META, "label", "CenterText", "Center")
prototype.Delegate(META, "label", "CenterTextY", "CenterY")
prototype.Delegate(META, "label", "CenterTextX", "CenterX")
prototype.Delegate(META, "label", "GetTextSize", "GetSize")

function META:Initialize()
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

function META:GetMarkup()
	return self.label.markup
end

function META:OnStyleChanged(skin)
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

function META:OnLayout(S)
	self.label:SetPosition(Vec2()+S*2)
end

function META:SetCaretPosition(pos)
	self.label.markup:SetCaretPosition(pos.x, pos.y)
end

function META:GetCaretPosition()
	return Vec2(self.label.markup:GetCaretPosition())
end

function META:SelectAll()
	self.label.markup:SelectAll()
end

function META:SetEditable(b)
	self.Editable = b
	self.label.markup:SetEditable(b)
end

function META:SizeToText()
	local marg = self:GetMargin()

	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)
end

function META:OnFocus()
	input.DisableFocus = true -- TODO
	if self.Editable then
		self.label.markup:SetEditable(true)
	end
end

function META:OnUnfocus()
	input.DisableFocus = false -- TODO
	self.label.markup:SetEditable(false)
end

function META:OnKeyInput(...)
	return self.label:OnKeyInput(...)
end

function META:OnCharInput(...)
	return self.label:OnCharInput(...)
end

function META:OnMouseInput(button, press, ...)
	self.label:OnMouseInput(button, press, ...)
end

function META:OnMouseMove(...)
	self.label:OnMouseMove(...)
end

function META:OnEnter() end
function META:OnTextChanged() end

gui.RegisterPanel(META)