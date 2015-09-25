local gui = ... or _G.gui
local PANEL = {}

PANEL.ClassName = "button"
	
prototype.GetSet(PANEL, "Mode", "normal")
prototype.GetSet(PANEL, "ResetOnMouseExit", true)
prototype.GetSet(PANEL, "Highlight", false)
prototype.GetSet(PANEL, "ActiveStyle", "button_active")
prototype.GetSet(PANEL, "InactiveStyle", "button_inactive")
prototype.GetSet(PANEL, "HighlightOnMouseEnter", true)
prototype.GetSet(PANEL, "ClicksToActivate", 0)

function PANEL:SetActiveStyle(str)
	self.ActiveStyle = str
	
	if self:GetState() then
		self:SetStyle(self.ActiveStyle)
	else
		self:SetStyle(self.InactiveStyle)
	end
end

function PANEL:SetInactiveStyle(str)
	self.InactiveStyle = str
	
	if self:GetState() then
		self:SetStyle(self.ActiveStyle)
	else
		self:SetStyle(self.InactiveStyle)
	end
end

function PANEL:Initialize()
	self:SetStyle("button_inactive")
	self:SetCursor("hand")
	self.button_down = {}
end

function PANEL:Toggle(button)
	return self:SetState(not self:GetState(button), button)
end

function PANEL:SetState(press, button)
	button = button or "button_1"
	
	if press then
		self.button_down[button] = press
				
		if button == "button_1" then
			self:SetStyle(self.ActiveStyle)
		end
		
		return true
	else--if self.button_down[button] then		
		self.button_down[button] = nil
		
		if button == "button_1" then
			self:SetStyle(self.InactiveStyle)
		end
		
		return true
	end
	
	return false
end

function PANEL:GetState(button)
	button = button or "button_1"
	return self.button_down[button] or false
end

function PANEL:CanPress(button)
	button = button or "button_1"
	
	self.click_times = self.click_times or {}
	self.click_times[button] = self.click_times[button] or {last_click = 0, times = 0}
	
	return self.click_times[button].times >= self.ClicksToActivate
end

function PANEL:OnMouseInput(button, press)
	if button == "button_3" or button == "mwheel_up" or button == "mwheel_down" then return end
	
	self.click_times = self.click_times or {}
	self.click_times[button] = self.click_times[button] or {last_click = 0, times = 0}
	
	if press then		
		if self.click_times[button].last_click < system.GetTime() then
			self.click_times[button].last_click = 0
			self.click_times[button].times = 0
		end
		
		self.click_times[button].last_click = system.GetTime() + 0.2
		self.click_times[button].times = self.click_times[button].times + 1
	end

	if self.Mode == "normal" then
		if press and not self:CanPress(button) then return end

		if self:SetState(press, button) then
			self:OnStateChanged(press, button)
			if button == "button_1" then
				if press then
					self:OnPress()
				else
					self:OnRelease()
				end
			end
		end
	elseif self.Mode == "toggle" and press then
		if self:Toggle(button) then
			local press = self:GetState(button)
			self:OnStateChanged(press, button)
			if press then
				self:OnPress()
			else
				self:OnRelease()
			end
		end
	end
end

function PANEL:OnGlobalMouseInput(button, press)
	if self.Mode == "normal" and not press and self.button_down[button] and not self.mouse_over then
		self:SetStyle(self.InactiveStyle)
	end
end

function PANEL:OnMouseEnter()
	if self.HighlightOnMouseEnter then
		self:Animate("DrawColor", {Color(1,1,1,1)*0.3, function() return self.Highlight or self:IsMouseOver() end, "from"}, duration, "", 0.25)
	end
end

function PANEL:OnMouseExit()
	if self.Mode ~= "toggle" and self.ResetOnMouseExit then
		self.button_down = {}
	end
end

function PANEL:OnRelease() end
function PANEL:OnPress() end
function PANEL:OnStateChanged(press, button) end

function PANEL:Test()		
	local btn = gui.CreatePanel("button")
	
	btn:SetMode("toggle")
	btn:SetPosition(Vec2()+100)
	
	return btn
end

gui.RegisterPanel(PANEL)