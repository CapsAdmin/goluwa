local PANEL = {}

PANEL.ClassName = "draggable"
PANEL.Base = "panel"

PANEL.PrevSize = Vec2(0,0)

aahh.IsSet(PANEL, "Dragging", false)
aahh.IsSet(PANEL, "Resizing", false)

aahh.IsSet(PANEL, "DraggingAllowed", true)
aahh.IsSet(PANEL, "ResizingAllowed", true)

function PANEL:CanDrag(button, press, pos)
	return true
end

function PANEL:CanResize(button, press, pos)
	return true
end

function PANEL:SetResizing(loc)
	self.Resizing = loc
	self.PrevSize = self:GetSize()
	self.PrevPos = self:GetPos()
end

function PANEL:OnMouseInput(button, press, pos)
	local loc = self:DockHelper(pos, self:GetSkinVar("Padding", 2))
	if self:IsResizingAllowed() and self:CanResize(button, press, pos) and loc ~= "Center" then
		self:SetResizing(loc)
	end
		
	if self:IsDraggingAllowed() and self:CanDrag(button, press, pos) then
		self:SetDragging(press and pos)
	end
end

function PANEL:CalcBounds()

end

function PANEL:CalcCursor(pos)		
	local loc = self:DockHelper(pos-self:GetPos(), self:GetSkinVar("Padding", 2))
	
	if not self:CanResize("mouse1", true, pos) then return end
	
	if loc == "Center" then
		self:SetCursor(e.IDC_ARROW)
	elseif loc == "Top" or loc == "bottom" then
		self:SetCursor(e.IDC_SIZENS)
	elseif loc == "Left" or loc == "right" then
		self:SetCursor(e.IDC_SIZEWE)
	elseif loc == "TopLeft" then
		self:SetCursor(e.IDC_SIZENWSE)
	elseif loc == "BottomRight" then
		self:SetCursor(e.IDC_SIZENWSE)
	elseif loc == "TopRight" then
		self:SetCursor(e.IDC_SIZENESW)
	elseif loc == "BottomLeft" then
		self:SetCursor(e.IDC_SIZENESW)
	end
end

function PANEL:OnThink()
	local pos = aahh.GetMousePosition()
	
	self:CalcCursor(pos)
		
	-- ugh
	if input.IsKeyDown("mouse1") then
		if self:IsResizing() then
			local loc = self.Resizing
			if loc ~= "Center" then
				local siz = pos - self:GetWorldPos()

				if loc  == "Right" then
					siz.h = self.PrevSize.h
					self:SetSize(siz)
				end

				if loc  == "Bottom" then
					siz.w = self.PrevSize.w
					self:SetSize(siz)
				end

				if loc  == "Top" then
					pos.x = self.PrevPos.x
					pos.y = math.min(pos.y, (self.PrevPos.y + self.PrevSize.y) - self.MinSize.y)
					self:SetPos(pos)

					siz.w = self.PrevSize.w
					siz.h = self.PrevPos.y - pos.y + self.PrevSize.h
					self:SetSize(siz)
				end

				if loc  == "Left" then
					pos.y = self.PrevPos.y
					pos.x = math.min(pos.x, (self.PrevPos.x + self.PrevSize.x) - self.MinSize.x)
					self:SetPos(pos)

					siz.h = self.PrevSize.h
					siz.w = self.PrevPos.x - pos.x + self.PrevSize.w
					self:SetSize(siz)
				end

				if loc  == "Topleft" then
					pos.x = math.min(pos.x, (self.PrevPos.x + self.PrevSize.x) - self.MinSize.x)
					pos.y = math.min(pos.y, (self.PrevPos.y + self.PrevSize.y) - self.MinSize.y)

					self:SetPos(pos)
					self:SetSize((self.PrevPos - pos) + self.PrevSize)
				end

				if loc  == "BottomRight" then
					self:SetSize((pos - self.PrevPos))
				end

				if loc  == "BottomLeft" then
					pos.x = math.min(pos.x, (self.PrevPos.x + self.PrevSize.x) - self.MinSize.x)
					self:SetPos(Vec2(pos.x, self.PrevPos.y))

					siz = self.PrevSize
					siz = self.PrevPos - pos + self.PrevSize
					siz.h = -siz.h + self.PrevSize.h
					self:SetSize(siz)			end

				if loc  == "TopRight" then
					pos.y = math.min(pos.y, (self.PrevPos.y + self.PrevSize.y) - self.MinSize.y)
					self:SetPos(Vec2(self.PrevPos.x, pos.y))

					siz = self.PrevSize
					siz = self.PrevPos - pos + self.PrevSize
					siz.w = -siz.w + self.PrevSize.w
					self:SetSize(siz)
				end
			end
		elseif self:IsDragging() then
			self:SetWorldPos(pos - self.Dragging)
			self.Resizing = false
		end
		
		self:CalcBounds()
	else
		self.Dragging = false
		self.Resizing = false
		self.PrevSize = nil
		self.PrevPos = nil
	end
end

function PANEL:OnDraw()
	self:DrawHook("PanelDraw")
end

aahh.RegisterPanel(PANEL)