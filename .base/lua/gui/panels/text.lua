local gui = ... or _G.gui
local PANEL = {}

PANEL.ClassName = "text"

prototype.GetSet(PANEL, "Text")
prototype.GetSet(PANEL, "ParseTags", false)
prototype.GetSet(PANEL, "TextWrap", false)
prototype.GetSet(PANEL, "ConcatenateTextToSize", false)

prototype.GetSet(PANEL, "Font")
prototype.GetSet(PANEL, "TextColor")

function PANEL:Initialize()
	self:SetNoDraw(true)
	local markup = surface.CreateMarkup()
	markup:SetEditable(false)
	markup.OnInvalidate = function() 
		self:MarkCacheDirty()
		self:OnTextChanged(self.markup:GetText())
			
		self.Size.w = markup.width
		self.Size.h = markup.height
	end
	self.markup = markup
	
	self:SetTextWrap(self.TextWrap)
end

function PANEL:SetFont(font)
	surface.SetFont(font)
	self.markup:SetMinimumHeight(select(2, surface.GetTextSize("")))
	self.Font = font
	self:SetText(self:GetText())
end

function PANEL:SetTextColor(color)
	self.TextColor = color
	self:SetText(self:GetText())
end

function PANEL:SetText(str)	
	self.Text = str
	
	local markup = self.markup
	
	markup:Clear()
	markup:AddFont(self.Font)
	markup:AddColor(self.TextColor:Copy())
	markup:AddString(self.Text, self.ParseTags)
	
	markup:Invalidate()
	markup:SetCaretPosition(0,0)
	
	self:Layout()
end

function PANEL:GetText()
	return self.markup:GetText(self.ParseTags)
end

function PANEL:SetTextWrap(b)
	self.TextWrap = b
	self.markup:SetLineWrap(b)
end

function PANEL:OnPostDraw()
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
		if self.Font then markup:AddFont(self.Font) end 
		if self.TextColor then markup:AddColor(self.TextColor) end
		markup:AddString(concatenated, self.ParseTags)
		self.concatenated = true
		
		self:OnUpdate()
	elseif self.concatenated then
		self:SetText(self.Text)
		self.concatenated = false
	end
end

function PANEL:OnStyleChanged(skin)
	self:SetTextColor(skin.text_color)
	self:SetFont(skin.default_font)
end

function PANEL:OnLayout(S)
	if self.ConcatenateTextToSize then
		self:Concatenate()
	end
end

function PANEL:OnUpdate()
	local markup = self.markup
	markup.cull_x = self.Parent.Scroll.x
	markup.cull_y = self.Parent.Scroll.y
	markup.cull_w = self.Parent.Size.w
	markup.cull_h = self.Parent.Size.h
	
	self.Size.w = markup.width
	self.Size.h = markup.height
		
	markup:Update()
end

function PANEL:OnMouseInput(button, press)
	self.markup:OnMouseInput(button, press)
end

function PANEL:OnKeyInput(key, press)
	local markup = self.markup

	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end
	
	if press then
		if key == "enter" then if self:OnEnter() == false then return end end
		markup:OnKeyInput(key, press)
	end
end

function PANEL:OnCharInput(char)
	self.markup:OnCharInput(char)
end	

function PANEL:OnEnter() end
function PANEL:OnTextChanged() end

gui.RegisterPanel(PANEL)