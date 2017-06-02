local gui = ... or _G.gui
local META = prototype.CreateTemplate("text")

META:GetSet("Text")
META:GetSet("ParseTags", false)
META:GetSet("TextWrap", false)
META:GetSet("ConcatenateTextToSize", false)
META:GetSet("LightMode", false)
META:GetSet("CopyTags", true)
META:GetSet("ObeyPanelWidth", false)
META:IsSet("Selectable", false)

META:GetSet("MaxWidth")
META:GetSet("Font")
META:GetSet("TextColor")

function META:Initialize()
	self:SetNoDraw(true)
	self:SetLayoutWhenInvisible(false)
	local markup = gfx.CreateMarkup()
	markup:SetEditable(false)
	markup.OnInvalidate = function()
		if not self.ObeyPanelWidth then
			self.Size.x = markup.width + self.Padding:GetLeft() + self.Padding:GetRight()
		end
		self.Size.y = markup.height + self.Padding:GetTop() + self.Padding:GetBottom()

		self.LayoutSize = self.Size

		local str = self.markup:GetText(self.ParseTags)
		if str ~= self.last_text then
			self:OnTextChanged(str)
			self.last_text = str
		end

		self:MarkCacheDirty()
	end
	self.markup = markup
	self:SetFont(gfx.GetDefaultFont())
end

function META:SetPadding(rect)
	self.Padding = rect

	self.markup:Invalidate()
end

function META:SetFont(font)
	self.markup:SetMinimumHeight(select(2, font:GetTextSize("")))
	self.Font = font
	self:SetText(self:GetText())
end

function META:SetTextColor(color)
	self.TextColor = color
	self:SetText(self:GetText())
end

function META:SetMaxWidth(width)
	self.MaxWidth = width
	self:SetText(self:GetText())
end

function META:SetLightMode(b)
	self.LightMode = b
	self:SetText(self:GetText())
end

function META:SetTextWrap(b)
	self.TextWrap = b
	self:SetText(self:GetText())
end

function META:SetCopyTags(b)
	self.CopyTags = b
	self.markup:SetCopyTags(b)
end

function META:SetSelectable(b)
	self.Selectable = b
	self.markup:SetSelectable(b)
end

function META:SetText(str)
	str = tostring(str)

	self.Text = str

	local markup = self.markup

	markup:SuppressLayout(true)

	markup:SetLightMode(self.LightMode)
	markup:SetLineWrap(self.TextWrap)
	markup:SetCopyTags(self.CopyTags)

	markup:Clear()
	if self.Font then markup:AddFont(self.Font) end
	if self.TextColor then markup:AddColor(self.TextColor:Copy()) end
	if self.MaxWidth then markup:SetMaxWidth(self.MaxWidth) end
	markup:AddString(self.Text, self.ParseTags)
	markup:SetCaretPosition(0,0)

	markup:SuppressLayout(false)

	markup:Invalidate()
end

function META:GetText()
	return self.markup:GetText(self.ParseTags)
end

function META:OnLayout()
	if self.ObeyPanelWidth then self.markup:SetMaxWidth(self:GetWidth()) end
	if self.MaxWidth then self.markup:SetMaxWidth(self.MaxWidth) end
	self.markup:Invalidate()
end

function META:OnPostDraw()
	self.markup:Draw(self.ConcatenateTextToSize and (self.markup.cull_w - self.markup.cull_x))
end

function META:OnPostMatrixBuild()
	self.Matrix:Translate(self.Padding:GetLeft(), self.Padding:GetTop(), 0)
end

function META:OnMouseMove(x, y)
	self.markup:SetMousePosition(Vec2(x, y))
	self:MarkCacheDirty()
end

function META:OnStyleChanged(skin)
	self:SetTextColor(skin.text_color)
	self:SetFont(skin.default_font)
end

function META:OnUpdate()
	if not self:HasParent() then return end

	local markup = self.markup

	markup.cull_x = self.Parent.Scroll.x
	markup.cull_y = self.Parent.Scroll.y
	markup.cull_w = self.Parent.Size.x
	markup.cull_h = self.Parent.Size.y

	--markup.need_layout = nil
	markup:Update()

	-- :(
	if markup:IsCaretVisible() then
		if not self.sadface then
			self:MarkCacheDirty()
			self.sadface = true
		end
	else
		if self.sadface then
			self:MarkCacheDirty()
			self.sadface = false
		end
	end
end

function META:OnMouseInput(button, press)
	self.markup:OnMouseInput(button, press)
	if press then
		event.Delay(0, function() self:GlobalMouseCapture(true) end, "asdf", self)
	else
		self:GlobalMouseCapture(false)
	end
end

function META:OnKeyInput(key, press)
	local markup = self.markup

	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end

	if press then
		if key == "enter" then if self:OnEnter() == false then return end end
		markup:OnKeyInput(key, press)
	end
end

function META:OnCharInput(char)
	self.markup:OnCharInput(char)
end

function META:OnEnter() end
function META:OnTextChanged() end

gui.RegisterPanel(META)
