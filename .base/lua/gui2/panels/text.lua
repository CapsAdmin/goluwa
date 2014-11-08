local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "text"

prototype.GetSet(PANEL, "Text")
prototype.GetSet(PANEL, "ParseTags", false)
prototype.GetSet(PANEL, "TextWrap", false)
prototype.GetSet(PANEL, "ConcatenateTextToSize", false)

prototype.GetSet(PANEL, "Font", gui2.skin.default_font)
prototype.GetSet(PANEL, "TextColor", gui2.skin.default_font_color)

function PANEL:Initialize()
	local markup = surface.CreateMarkup()
	markup:SetEditable(false)
	markup.OnInvalidate = function() 
		self:MarkCacheDirty()
		self:OnTextChanged(self.markup:GetText())
	end
	self.markup = markup
	
	self:SetTextWrap(self.TextWrap)
end

function PANEL:SetText(str)
	self.Text = str
	
	local markup = self.markup
	
	markup:Clear()
	markup:AddFont(self.Font)
	markup:AddColor(self.TextColor)
	markup:AddString(self.Text, self.ParseTags)
	
	markup:Invalidate()
	self:OnUpdate()
	if self.ConcatenateTextToSize then
		self:Concatenate()
	end
end

function PANEL:GetText()
	return self.markup:GetText(self.ParseTags)
end

function PANEL:SetTextWrap(b)
	self.TextWrap = b
	self.markup:SetLineWrap(b)
end

function PANEL:OnDraw()
	self.markup:Draw()
end

function PANEL:OnMouseMove(x, y)
	self.markup:SetMousePosition(Vec2(x, y))
	self:MarkCacheDirty()
end

function PANEL:Concatenate()
	if not self.Text then return end
			
	self:OnUpdate()
			
	local markup = self.markup
	
	surface.SetFont(self.Font)
	local w = surface.GetTextSize("...") * 2
		
	if markup.cull_w-markup.cull_x - w < markup.width then
		
		if self.Text == "world" then print(markup.cull_x) end
		local caret = markup:CaretFromPixels(markup.cull_w-markup.cull_x - w, 0)
		local sub_pos = markup:GetSubPosFromPosition(caret.x, caret.y)
				
		local concatenated = self.Text:sub(0, sub_pos) .. "..."	
		
		markup:Clear()
		markup:AddFont(self.Font)
		markup:AddColor(self.TextColor)
		markup:AddString(concatenated, self.ParseTags)
		self.concatenated = true
		
		self:OnUpdate()
	elseif self.concatenated then
		self:SetText(self.Text)
		self.concatenated = false
	end
end

function PANEL:OnLayout()
	if self.ConcatenateTextToSize then
		self:Concatenate()
	end
end

function PANEL:OnUpdate()
	local markup = self.markup
	
	markup.cull_x = self.Parent.Scroll.x + self.Position.x
	markup.cull_y = self.Parent.Scroll.y + self.Position.y
	markup.cull_w = self.Parent.Size.w
	markup.cull_h = self.Parent.Size.h
		
	markup:Update()
	
	self.Size.w = markup.width
	self.Size.h = markup.height
end

function PANEL:OnMouseInput(button, press)
	self.markup:OnMouseInput(button, press)
end

function PANEL:OnKeyInput(key, press)
	local markup = self.markup

	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end
	
	if press then
		if key == "enter" then self:OnEnter() end
		markup:OnKeyInput(key, press)
	end
end

function PANEL:OnCharInput(char)
	self.markup:OnCharInput(char)
end	

function PANEL:OnEnter() end
function PANEL:OnTextChanged() end

gui2.RegisterPanel(PANEL)