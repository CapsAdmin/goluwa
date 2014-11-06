local PANEL = {}

PANEL.ClassName = "text_input"

prototype.GetSet(PANEL, "Text", "")
prototype.GetSet(PANEL, "Wrap", false)
prototype.GetSet(PANEL, "FixedHeight", true)
prototype.GetSet(PANEL, "LineSpacing", 3)
prototype.GetSet(PANEL, "MultiLine", false)
prototype.GetSet(PANEL, "LineNumbers", true)
prototype.GetSet(PANEL, "EditorMode", false)

function PANEL:SetCaretPosition(pos)
	self.markup:SetCaretPosition(pos.x, pos.y)
end

function PANEL:GetCaretPosition()
	return Vec2(self.markup.caret_pos.x,self.markup.caret_pos.y)
end

function PANEL:SetMultiline(b)
	self.MultiLine = b
	self.markup:SetMultiline(b)
end

function PANEL:SetWrap(b)
	self.Wrap = b
	self.markup:SetLineWrap(b)
end

function PANEL:Initialize()
	self.markup = surface.CreateMarkup()
end

function PANEL:OnRequestLayout()
	self.markup:SetMaxWidth(self:GetWidth())
	
	self.markup.OnInvalidate = function()
		if self.OnTextChanged then
			self:OnTextChanged(self.markup:GetText())
		end
	end
end

function PANEL:OnDraw(size)
	local w,h = size:Unpack()
	
	surface.SetWhiteTexture()
	surface.SetColor(0.1, 0.1, 0.1, 1)
	surface.DrawRect(0,0, w, h)
	
	--surface.SetColor(1, 1, 1, 0.1)
	--surface.DrawRect(0,0, self.markup.width or w, self.markup.height or h)
	
	-- this is needed for proper mouse coordinates
	local x, y = self:GetWorldPosition():Unpack()
	self.markup:Draw(x, y, size:Unpack())
end

function PANEL:OnMouseInput(button, press)
	self:MakeActivePanel()  
	self.markup:OnMouseInput(button, press, window.GetMousePosition():Unpack())
end

function PANEL:OnKeyInput(key, press)	
	if key == "left_shift" or key == "right_shift" then  self.markup:SetShiftDown(press) return end
	if key == "left_control" or key == "right_control" then  self.markup:SetControlDown(press) return end
	
	if self.OnPreKeyInput and self:OnPreKeyInput(key, press) ~= nil then return false end
	
	if press then
		if key == "enter" and not self.MultiLine then
			if self.OnEnter then
				self:OnEnter(self.markup:GetText())
			end
		else
			self.markup:OnKeyInput(key, press)
		end
		
		if self.OnUnhandledKey then
			self:OnUnhandledKey(key, press)
		end
	end
	
	if self.OnPostKeyInput and self:OnPostKeyInput(key, press) ~= nil then return false end
end

function PANEL:OnCharInput(char)
	self.markup:OnCharInput(char)
end

function PANEL:SetText(str)
	self.markup:SelectAll()
	self.markup:DeleteSelection()
	self.markup:Paste(str)
	
	self.Text = str
end

function PANEL:GetText(b)
	return self.markup:GetText(b)
end

function PANEL:SetContent(str)
	self.Content = str
	self.lines = str:explode("\n")
	
	local w, h = surface.GetTextSize("W")
	
	self.height = #self.lines * h
end

function PANEL:SizeToContents()
	self:SetSize(Vec2(self:GetWidth(), self.markup.height))
end

gui.RegisterPanel(PANEL)