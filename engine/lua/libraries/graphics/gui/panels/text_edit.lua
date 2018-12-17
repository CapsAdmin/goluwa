local gui = ... or _G.gui
local META = prototype.CreateTemplate("text_edit")

META:GetSet("CaretColor")
META:GetSet("SelectionColor")
META:GetSet("Editable", true)
META:GetSet("CaretPosition", Vec2(0, 0))
META:GetSet("CaretSubPosition", 0)
META:GetSet("Multiline", false)

META:GetSetDelegate("Text", "", "label")
META:GetSetDelegate("ParseTags", false, "label")
META:GetSetDelegate("Font", nil, "label")
META:GetSetDelegate("TextColor", nil, "label")
META:GetSetDelegate("TextWrap", false, "label")

META:Delegate("label", "CenterText", "Center")
META:Delegate("label", "CenterTextY", "CenterY")
META:Delegate("label", "CenterTextX", "CenterX")
META:Delegate("label", "GetTextSize", "GetSize")

function META:Initialize()
	self:SetStyle("text_edit")
	self:SetFocusOnClick(true)
	META.BaseClass.Initialize(self)

	local label = self:CreatePanel("text", "label")

	label.OnStyleChanged = function() end
	label.markup:SetEditable(self.Editable)

	label:SetClipping(true)
	label:SetIgnoreMouse(true)

	self:SetEditable(true)
	self:SetSmoothScroll(0)

	label.OnTextChanged = function(_, ...)
		self:OnTextChanged(...)

		self:ScrollToCaret()
	end
	label.markup.OnAdvanceCaret = function()
		self:ScrollToCaret()
	end
	label.OnEnter = function(_, ...)
		self:OnEnter(...)
		if not self.Multiline then
			return false
		end
	end

	self:SetCursor("ibeam")
	self:SizeToText()
	self:SetMultiline(self.Multiline)
end

function META:ScrollToCaret()
	local cpos = self:GetPixelCaretPosition()

	if
		cpos.x < self:GetScroll().x + self.Size.x and
		cpos.x + self.Size.x > self:GetScroll().x + self.Size.x
	then

	else
		local scroll = cpos.x - self.Size.x
		local padding = self.label.Padding:GetRight() + self.label.Padding:GetLeft()
		scroll = scroll + self:GetSize().x - padding
		scroll = scroll + padding


		local prev = self:GetScroll()
		prev.x = scroll
		self:SetScroll(prev)
	end


	local height = 15
	local font = self:GetFont()

	if font then
		local _, h = font:GetTextSize("|")
		height = h
	end

	if cpos.y + self.Size.y < self:GetScroll().y + self.Size.y + height then
		cpos.y = cpos.y - height
	end

	if
		cpos.y < self:GetScroll().y + self.Size.y and
		cpos.y + self.Size.y > self:GetScroll().y + self.Size.y
	then

	else
		local scroll = cpos.y - self.Size.y
		local padding = self.label.Padding:GetTop() + self.label.Padding:GetBottom()
		scroll = scroll + self:GetSize().y - padding
		scroll = scroll + padding

		local prev = self:GetScroll()
		prev.y = scroll
		self:SetScroll(prev)
	end
end

function META:SetMultiline(b)
	self.Multiline = b
	if b then
		self.label:SetupLayout()
	else
		self.label:SetupLayout("center_y_simple")
	end
end

function META:GetMarkup()
	return self.label.markup
end

function META:OnStyleChanged(skin)
	if skin.text_edit_color then
		self:SetCaretColor(skin.text_edit_color:Copy())
		self:SetSelectionColor(skin.text_edit_color:Copy():SetAlpha(0.5))
		self:SetTextColor(skin.text_edit_color:Copy())
	end
	self:SetFont(skin.default_font)
	--self:SetScrollable(true)

	self.label.markup:SetCaretColor(self.CaretColor)
	self.label.markup:SetSelectionColor(self.SelectionColor)
end

function META:OnLayout(S)
	self.label:SetPadding(Rect() + S)
end

function META:SetCaretPosition(pos)
	self.label.markup:SetCaretPosition(pos.x, pos.y)
end

function META:GetCaretPosition()
	return Vec2(self.label.markup:GetCaretPosition())
end

function META:GetPixelCaretPosition()
	local data = self.label.markup:CaretFromPosition(self:GetCaretPosition():Unpack())
	return Vec2(data.px, data.py)
end

function META:SetCaretSubPosition(pos)
	self.label.markup:SetCaretSubPosition(pos)
end

function META:GetCaretSubPosition()
	return self.label.markup:GetCaretSubPosition()
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
	self:SetSize(self.label:GetSize() + marg:GetSize() * 2)
end

function META:OnFocus()
	event.Call("TextInputFocus", self)
	input.PushDisableFocus()
	if self.Editable then
		self.label.markup:SetEditable(true)
	end
end

function META:OnUnfocus()
	event.Call("TextInputUnfocus", self)
	input.PopDisableFocus()
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

if RELOAD then
	local frame = gui.CreatePanel("frame", nil, "lol")
	frame:SetSize(Vec2()+256)
	local pnl = frame:CreatePanel(META.ClassName)
	pnl:SetupLayout("fill")
	pnl:SetPosition(Vec2() + 50)
	pnl:SetMultiline(true)
	pnl:SetTextWrap(true)
	MARKUP = pnl.label.markup
	--pnl:Center()
	pnl:RequestFocus()
end
