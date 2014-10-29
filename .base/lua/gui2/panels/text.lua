local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "text"

prototype.GetSet(PANEL, "Text")
prototype.GetSet(PANEL, "ParseTags", false)
prototype.GetSet(PANEL, "Editable", false)
prototype.GetSet(PANEL, "TextWrap", false)

prototype.GetSet(PANEL, "Font", "default")
prototype.GetSet(PANEL, "TextColor", Color(1,1,1,1))

function PANEL:Initialize()
	self.markup = surface.CreateMarkup()
	
	self:SetNoDraw(true)
	self:SetRedirectFocus(carrier)
end

function PANEL:SetText(str)
	self.Text = str
	
	self:SetIgnoreMouse(not self.Editable)

	local markup = self.markup
	
	markup:SetEditable(self.Editable)
	markup:SetLineWrap(self.TextWrap)
	
	markup:Clear()
	markup:AddFont(self.Font)
	markup:AddColor(self.TextColor)
	markup:AddString(self.Text, self.ParseTags)
	
	self:OnDraw() -- hack! this will update markup sizes
	self:OnDraw() -- hack! this will update markup sizes
end

function PANEL:OnDraw()
	local markup = self.markup

	markup:SetMousePosition(self:GetMousePosition():Copy())

	markup.cull_x = self.Parent.Scroll.x
	markup.cull_y = self.Parent.Scroll.y
	markup.cull_w = self.Parent.Size.w
	markup.cull_h = self.Parent.Size.h
	
	markup:Draw()
	
	self.Size.w = markup.width
	self.Size.h = markup.height
	
	if not input.IsMouseDown("button_1") then
		if not markup.mouse_released then
			markup:OnMouseInput("button_1", false)
			markup.mouse_released = true
		end
	end
end

function PANEL:OnMouseInput(button, press)
	local markup = self.markup

	markup:OnMouseInput(button, press)
	
	if button == "button_1" then
		self:RequestFocus()
		self:BringToFront()
		markup.mouse_released = false
	end
end

function PANEL:OnKeyInput(key, press)
	local markup = self.markup

	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end

	if press then
		markup:OnKeyInput(key, press)
	end
end

function PANEL:OnCharInput(char)
	self.markup:OnCharInput(char)
end	

gui2.RegisterPanel(PANEL)