local PANEL = {}

PANEL.ClassName = "draggable"
PANEL.Base = "panel"

gui.IsSet(PANEL, "Dragging", false)
gui.IsSet(PANEL, "Resizing", false)

gui.IsSet(PANEL, "DraggingAllowed", true)
gui.IsSet(PANEL, "ResizingAllowed", true)

function PANEL:CanDrag(button, press, pos)
	return true
end

function PANEL:CanResize(button, press, pos)
	return true
end

function PANEL:SetResizing(loc)
	self.Resizing = loc
	self.prev_size = self:GetSize()
	self.prev_pos = self:GetWorldPos()
end


function PANEL:OnMouseInput(button, press, pos)
	local loc = self:DockHelper(pos, self:GetSkinVar("Padding", 2) * 2)
	
	if self:IsResizingAllowed() and self:CanResize(button, press, pos) and loc ~= "Center" then
		self:SetResizing(loc)
		self.lpos = pos
	end
		
	if self:IsDraggingAllowed() and self:CanDrag(button, press, pos) then
		self:SetDragging(press)
		self.lpos = pos
	end
end

function PANEL:CalcBounds()

end

function PANEL:CalcCursor(pos)		
	local loc = self:DockHelper(pos, self:GetSkinVar("Padding", 2)*2)
	
	if not self:CanResize("button_1", true, pos) then return end
	
	if loc == "Center" then
		self:SetCursor("arrow")
	elseif loc == "Top" or loc == "Bottom" then
		self:SetCursor("sizens")
	elseif loc == "Left" or loc == "Right" then
		self:SetCursor("sizewe")
	elseif loc == "TopLeft" then
		self:SetCursor("sizenwse")
	elseif loc == "BottomRight" then
		self:SetCursor("sizenwse")
	elseif loc == "TopRight" then
		self:SetCursor("sizenesw")
	elseif loc == "BottomLeft" then
		self:SetCursor("sizenesw")
	end
end

function PANEL:OnMouseMove(lpos, inside)

	pos = gui.GetMousePos()
		
	self:CalcCursor(pos - self:GetWorldPos())
		
	-- ugh
	if gui.IsMouseDown("button_1") then
		if self:IsResizing() then
			local loc = self.Resizing
			if loc ~= "Center" then
				
				local prev_size = self.prev_size
				local prev_pos = self.prev_pos
				
				local siz = pos * 1
				siz = siz + self:GetSkinVar("Padding", 2)
								
				if loc  == "Right" then
					self:SetWidth(lpos.x)
				end

				if loc  == "Bottom" then
					self:SetHeight(lpos.y)
				end

				if loc  == "Top" then
					pos.x = prev_pos.x
					pos.y = math.min(pos.y, (prev_pos.y + prev_size.y) - self.MinSize.y)
					self:SetWorldPos(pos)

					siz.w = prev_size.w
					siz.h = prev_pos.y - pos.y + prev_size.h 
					self:SetSize(siz)
				end

				if loc  == "Left" then
					pos.y = prev_pos.y
					pos.x = math.min(pos.x, (prev_pos.x + prev_size.x) - self.MinSize.x)
					self:SetWorldPos(pos)

					siz.h = prev_size.h
					siz.w = prev_pos.x - pos.x + prev_size.w
					self:SetSize(siz)
				end

				if loc  == "Topleft" then
					pos.x = math.min(pos.x, (prev_pos.x + prev_size.x) - self.MinSize.x)
					pos.y = math.min(pos.y, (prev_pos.y + prev_size.y) - self.MinSize.y)

					self:SetWorldPos(pos)
					self:SetSize((prev_pos - pos) + prev_size)
				end

				if loc  == "BottomRight" then
					self:SetSize((pos - prev_pos))
				end

				if loc  == "BottomLeft" then
					pos.x = math.min(pos.x, (prev_pos.x + prev_size.x) - self.MinSize.x)
					self:SetWorldPos(Vec2(pos.x, prev_pos.y))

					siz = prev_size
					siz = prev_pos - pos + prev_size
					siz.h = -siz.h + prev_size.h
					self:SetSize(siz)			end

				if loc  == "TopRight" then
					pos.y = math.min(pos.y, (prev_pos.y + prev_size.y) - self.MinSize.y)
					self:SetWorldPos(Vec2(prev_pos.x, pos.y))

					siz = prev_size
					siz = prev_pos - pos + prev_size
					siz.w = -siz.w + prev_size.w
					self:SetSize(siz)
				end
				
				self:RequestParentLayout(true)
			end
		elseif self:IsDragging() then
			self:SetWorldPos(pos - self.lpos)
			self:SetResizing(false)
			self:RequestParentLayout(true)
		end
		
		self:CalcBounds()
	else
		self.Dragging = false
		self.Resizing = false
		self.prev_size = nil
		self.prev_pos = nil
		self.lpos = nil
	end
	
end

function PANEL:OnDraw()
	self:DrawHook("PanelDraw")
end

gui.RegisterPanel(PANEL)