local gui = ... or _G.gui
local META = {}

META.ClassName = "button"

prototype.GetSet(META, "Mode", "normal")
prototype.GetSet(META, "ResetOnMouseExit", true)
prototype.GetSet(META, "Highlight", false)
prototype.GetSet(META, "ActiveStyle", "button_active")
prototype.GetSet(META, "InactiveStyle", "button_inactive")
prototype.GetSet(META, "HighlightOnMouseEnter", true)
prototype.GetSet(META, "ClicksToActivate", 0)

function META:SetActiveStyle(str)
	self.ActiveStyle = str

	if self:GetState() then
		self:SetStyle(self.ActiveStyle)
	else
		self:SetStyle(self.InactiveStyle)
	end
end

function META:SetInactiveStyle(str)
	self.InactiveStyle = str

	if self:GetState() then
		self:SetStyle(self.ActiveStyle)
	else
		self:SetStyle(self.InactiveStyle)
	end
end

function META:Initialize()
	self:SetStyle("button_inactive")
	self:SetCursor("hand")
	self.button_down = {}
end

function META:Toggle(button)
	return self:SetState(not self:GetState(button), button)
end

function META:SetState(press, button)
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

function META:TieCheckbox(button)
	self.tied_buttons = self.tied_buttons or {}

	table.insert(self.tied_buttons, button)

	for _, button in ipairs(self.tied_buttons) do
		button:SetActiveStyle("rad_check")
		button:SetInactiveStyle("rad_uncheck")
	end

	self:SetActiveStyle("rad_check")
	self:SetInactiveStyle("rad_uncheck")
end

function META:GetState(button)
	button = button or "button_1"
	return self.button_down[button] or false
end

function META:CanPress(button)
	button = button or "button_1"

	self.click_times = self.click_times or {}
	self.click_times[button] = self.click_times[button] or {last_click = 0, times = 0}

	return self.click_times[button].times >= self.ClicksToActivate
end

function META:OnMouseInput(button, press)
	if button == "button_3" or button == "mwheel_up" or button == "mwheel_down" then return end

	self.click_times = self.click_times or {}
	self.click_times[button] = self.click_times[button] or {last_click = 0, times = 0}

	if press then
		if self.click_times[button].last_click < system.GetElapsedTime() then
			self.click_times[button].last_click = 0
			self.click_times[button].times = 0
		end

		self.click_times[button].last_click = system.GetElapsedTime() + 0.2
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
	elseif press then
		if self.Mode == "toggle" then
			if self:Toggle(button) then
				local press = self:GetState(button)
				self:OnStateChanged(press, button)
				if press then
					self:OnPress()
				else
					self:OnRelease()
				end
			end
		elseif self.Mode == "radio" then
			if self:Toggle(button) then
				local press = self:GetState(button)

				self:OnCheck(press)

				if self.tied_buttons and #self.tied_buttons > 0 then
					if press then
						for _, pnl in ipairs(self.tied_buttons) do
							if pnl:IsValid() and pnl ~= self then
								pnl:SetState(not press, button)
							end
						end
					else
						local found = false

						for i, pnl in ipairs(self.tied_buttons) do
							if pnl:IsValid() and pnl == self then
								local next = self.tied_buttons[i + 1]

								if not next or not next:IsValid() then
									next = self.tied_buttons[1]
								end

								next:SetState(true, button)
								found = true
							end
						end

						if not found then
							self:SetState(true, button)
						end
					end
				end

				self:OnStateChanged(press, button)

				if press then
					self:OnPress()
				else
					self:OnRelease()
				end
			end
		end
	end
end

function META:OnGlobalMouseInput(button, press)
	if self.Mode == "normal" and not press and self.button_down[button] and not self.mouse_over then
		self:SetStyle(self.InactiveStyle)
	end
end

function META:OnMouseEnter()
	if self.HighlightOnMouseEnter then
		self:Animate("DrawColor", {Color(1,1,1,1)*0.3, function() return self.Highlight or self:IsMouseOver() end, "from"}, nil, "", 0.25)
	end
end

function META:OnMouseExit()
	if self.Mode ~= "toggle" and self.ResetOnMouseExit then
		self.button_down = {}
	end
end

function META:OnRelease() end
function META:OnPress() end
function META:OnStateChanged(press, button) end

function META:Test()
	local btn = gui.CreatePanel("button")

	btn:SetMode("toggle")
	btn:SetPosition(Vec2()+100)

	return btn
end

gui.RegisterPanel(META)