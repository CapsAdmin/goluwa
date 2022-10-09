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
			self.Size.x = markup.width + self.Margin:GetLeft() + self.Margin:GetRight()
		end

		self.Size.y = markup.height + self.Margin:GetTop() + self.Margin:GetBottom()
		self.LayoutSize = self.Size
		self.markup_invalidated = true
		self:MarkCacheDirty()
	end
	self.markup = markup
end

function META:SetMargin(rect)
	self.Margin = rect
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
	markup:AddFont(self.Font or self:GetSkin().default_font or gfx.GetDefaultFont())
	markup:AddColor(self.TextColor and self.TextColor:Copy() or self:GetSkin().text_color)

	if self.MaxWidth then markup:SetMaxWidth(self.MaxWidth) end

	markup:AddString(self.Text, self.ParseTags)
	markup:SetCaretPosition(0, 0)
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
	self.Matrix:Translate(self.Margin:GetLeft(), self.Margin:GetTop(), 0)
end

function META:OnMouseMove(x, y)
	local pos = Vec2(x, y)

	if self:HasParent() then pos = pos + self.Parent:GetScroll() end

	self.markup:SetMousePosition(pos)
	self:MarkCacheDirty()
end

function META:OnStyleChanged(skin)
	self:SetText(self:GetText())
end

function META:OnUpdate()
	if not self:HasParent() then return end

	local markup = self.markup
	markup.cull_x = self.Parent:GetScroll().x
	markup.cull_y = self.Parent:GetScroll().y
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

	if self.markup_invalidated then
		local str = self.markup:GetText(self.ParseTags)

		if str ~= self.last_text then
			self:OnTextChanged(str)
			self.last_text = str
		end

		self.markup_invalidated = nil
	end
end

function META:OnMouseInput(button, press)
	if button == "button_2" then
		gui.CreateMenu(
			{
				{
					"undo",
					function()
						self.markup:Undo()
					end,
					"textures/silkicons/arrow_undo.png",
				},
				{
					"redo",
					function()
						self.markup:Undo()
					end,
					"textures/silkicons/arrow_redo.png",
				},
				{},
				{
					"cut",
					function()
						window.SetClipboard(self.markup:Cut())
					end,
					"textures/silkicons/cut.png",
				},
				{
					"copy",
					function()
						window.SetClipboard(self.markup:Copy())
					end,
					"textures/silkicons/page_copy.png",
				},
				{
					"paste",
					function()
						self.markup:Paste(window.GetClipboard())
					end,
					"textures/silkicons/page_paste.png",
				},
				{
					"delete",
					function()
						self.markup:DeleteSelection()
					end,
					"textures/silkicons/textfield_delete.png",
				},
				{
					"clear",
					function()
						self.markup:Clear()
					end,
					"textures/silkicons/cross.png",
				},
				{},
				{
					"select all",
					function()
						self.markup:SelectAll()
					end,
					"textures/silkicons/textfield_rename.png",
				},
			},
			self
		)
		return
	end

	self.markup:OnMouseInput(button, press)

	if press then
		timer.Delay(0, function()
			self:GlobalMouseCapture(true)
		end, "asdf", self)
	else
		self:GlobalMouseCapture(false)
	end
end

function META:OnKeyInput(key, press)
	local markup = self.markup

	if key == "tab" and input.IsKeyDown("left_alt") then return end

	if key == "left_shift" or key == "right_shift" then
		markup:SetShiftDown(press)
		return
	end

	if key == "left_control" or key == "right_control" then
		markup:SetControlDown(press)
		return
	end

	if press then
		if key == "enter" then if self:OnEnter() == false then return end end

		markup:OnKeyInput(key, press)
	end

	markup:Invalidate()
end

function META:OnCharInput(char)
	self.markup:OnCharInput(char)
	self.markup:Invalidate()
end

function META:OnEnter() end

function META:OnTextChanged() end

gui.RegisterPanel(META)