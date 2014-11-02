local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "text"

prototype.GetSet(PANEL, "Text")
prototype.GetSet(PANEL, "ParseTags", false)
prototype.GetSet(PANEL, "Editable", false)
prototype.GetSet(PANEL, "TextWrap", false)

prototype.GetSet(PANEL, "Font", gui2.skin.default_font)
prototype.GetSet(PANEL, "TextColor", gui2.skin.default_font_color)

function PANEL:Initialize()
	self.markup = surface.CreateMarkup()
	self:SetEditable(self.Editable)
	self:SetTextWrap(self.TextWrap)
end

function PANEL:SetText(str)
	self.Text = str
	
	local markup = self.markup
	
	markup.OnInvalidate = function() 
		self:MarkCacheDirty()
		self:OnTextChanged(self.markup:GetText())
	end
		
	markup:Clear()
	markup:AddFont(self.Font)
	markup:AddColor(self.TextColor)
	markup:AddString(self.Text, self.ParseTags)
	
	self:OnUpdate() -- hack! this will update markup sizes
end

function PANEL:GetText()
	return self.markup:GetText(self.ParseTags)
end

function PANEL:SetEditable(b)
	self.Editable = b
	self.markup:SetEditable(b)
end

function PANEL:SetTextWrap(b)
	self.TextWrap = b
	self.markup:SetLineWrap(b)
end

function PANEL:OnDraw()
	local markup = self.markup	
	markup:Draw()
end

function PANEL:OnMouseMove(x, y)
	local markup = self.markup
	
	markup:SetMousePosition(Vec2(x, y))
	self:MarkCacheDirty()
end

function PANEL:OnUpdate()
	local markup = self.markup
	
	markup.cull_x = self.Parent.Scroll.x
	markup.cull_y = self.Parent.Scroll.y
	markup.cull_w = self.Parent.Size.w
	markup.cull_h = self.Parent.Size.h
		
	markup:Update()
	
	self.Size.w = markup.width
	self.Size.h = markup.height
end

function PANEL:OnMouseInput(button, press)
	local markup = self.markup

	markup:OnMouseInput(button, press)
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