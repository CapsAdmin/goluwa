local PANEL = {}

PANEL.ClassName = "button"

function PANEL:Initialize()
	self:SetCursor(e.IDC_HAND)
	self.button_down = {}
end

function PANEL:OnMouseInput(key, press)
	if press then
		self.button_down[key] = press
		return
	end
	
	if not press and self.button_down[key] then
		self.button_down[key] = nil
		
		if key == "button_1" then
			return self:OnPress()
		else
			return self:OnOtherKeyPress(key)
		end
	end
end

function PANEL:IsDown()
	if self.is_down and not aahh.IsMouseDown("button_1") then
		self.is_down = false
	end
	
	return self.is_down
end

function PANEL:IsMouseOver()
	return self:IsWorldPosInside(aahh.GetMousePos())
end

function PANEL:OnOtherKeyPress(key) end
function PANEL:OnPress(key) end
function PANEL:OnRelease(key) end

function PANEL:OnDraw()
	self:DrawHook("ButtonDraw")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("ButtonLayout")
end

aahh.RegisterPanel(PANEL)