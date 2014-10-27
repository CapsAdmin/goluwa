local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "button"
	
prototype.GetSet(PANEL, "Mode", "normal")
prototype.GetSet(PANEL, "ResetOnMouseExit", true)
prototype.GetSet(PANEL, "Highlight", false)

function PANEL:Initialize()
	self:SetStyle("button_inactive")
	self:SetCursor("hand")
	self.button_down = {}
end

function PANEL:Toggle(button)
	self:SetState(not self:GetState(button), button)
end

function PANEL:SetState(pressed, button)
	button = button or "button_1"

	if pressed then
		self:OnStateChanged(pressed, button)
		
		self.button_down[button] = pressed
		
		if button == "button_1" then
			self:SetStyle("button_active")
			self:OnRelease() 
		end
		
		
	elseif self.button_down[button] then
		self:OnStateChanged(pressed, button)
		
		self.button_down[button] = nil
		
		if button == "button_1" then
			self:SetStyle("button_inactive")
			self:OnPress()
		end
		
		self:OnOtherButtonPress(button)
	end
end

function PANEL:GetState(button)
	button = button or "button_1"
	return self.button_down[button]
end

function PANEL:OnMouseInput(button, press)
	if self.Mode == "normal" then
		self:SetState(press, button)
	elseif self.Mode == "toggle" and press then
		self:Toggle(button)
	elseif self.Mode == "double" and press then
		--self:SetState(press, button)
	end
end

function PANEL:OnMouseEnter()
	self:Animate("DrawColor", {Color(1,1,1,1)*0.3, function() return self.Highlight or self:IsMouseOver() end, "from"}, duration, "", 0.25)
end

function PANEL:OnMouseExit()
	if self.Mode ~= "toggle" and self.ResetOnMouseExit then
		self.button_down = {}
		self:SetStyle("button_inactive")
	end
end

function PANEL:OnPress() end
function PANEL:OnRelease() end
function PANEL:OnOtherButtonPress(button) end
function PANEL:OnStateChanged(press, button) end

function PANEL:Test()		
	local btn = gui2.CreatePanel("button")
	
	btn:SetMode("toggle")
	btn:SetPosition(Vec2()+100)
	
	return btn
end

gui2.RegisterPanel(PANEL)