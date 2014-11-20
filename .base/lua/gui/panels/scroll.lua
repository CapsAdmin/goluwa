local gui = ... or _G.gui

local PANEL = {}
PANEL.ClassName = "scroll"

PANEL.panel = NULL

prototype.GetSet(PANEL, "XScrollBar", true)
prototype.GetSet(PANEL, "YScrollBar", true)
prototype.GetSet(PANEL, "ScrollWidth", 8)

function PANEL:Initialize()
	self:SetNoDraw(true)
	
	local scroll_area = self:CreatePanel("base", "scroll_area")
	scroll_area:SetClipping(true)
	scroll_area:SetNoDraw(true)
	scroll_area:SetAlwaysReceiveMouseInput(true)
	scroll_area:SetMargin(Rect())
	scroll_area:SetScrollable(true)
end

function PANEL:SetPanel(panel)
	gui.RemovePanel(self.y_handle)
	gui.RemovePanel(self.y_track)
	gui.RemovePanel(self.x_handle)
	gui.RemovePanel(self.x_track)

	panel:SetParent(self.scroll_area)
	
	self.panel = panel
	panel:Layout()
	
	local area = self.scroll_area
	
	if self.YScrollBar then
		local y_track = self:CreatePanel("base", "y_track")
		y_track:SetStyle("scroll_vertical_track")

		
		local y_handle = y_track:CreatePanel("button")
		y_handle:SetDraggable(true)	
		y_handle:SetStyle("scroll_vertical_handle_inactive")
		y_handle:SetStyleTranslation("button_active", "scroll_vertical_handle_active")
		y_handle:SetStyleTranslation("button_inactive", "scroll_vertical_handle_inactive")
				
		y_handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end
			
			if area.scrolling then return end
			area.scrolling = true
			
			local h = area:GetSizeOfChildren().h
			local frac = math.clamp(pos.y / h, 0, 1)

			area:SetScrollFraction(Vec2(area:GetScrollFraction().x, frac))
	 
			pos.x = y_handle.Parent:GetWidth() - y_handle:GetWidth()
			pos.y = math.clamp(pos.y, 0, y_handle.Parent:GetHeight() - y_handle:GetHeight())
			
			area.scrolling = false
		end
		
		self.y_handle = y_handle 
		self.y_track = y_track
	end
	
	if self.XScrollBar then
		local x_track = self:CreatePanel("base", "x_track")
		x_track:SetStyle("scroll_horizontal_track")
		
		local x_handle = x_track:CreatePanel("button")
		x_handle:SetDraggable(true)
		x_handle:SetStyle("scroll_horizontal_handle_inactive")
		x_handle:SetStyleTranslation("button_active", "scroll_horizontal_handle_active")
		x_handle:SetStyleTranslation("button_inactive", "scroll_horizontal_handle_inactive")
		
		x_handle.OnPositionChanged = function(_, pos)
			if not area:IsValid() then return end
			
			if area.scrolling then return end
			local frac = math.clamp(pos.x / area:GetSizeOfChildren().w, 0, 1)
			
			area.scrolling = true
			area:SetScrollFraction(Vec2(frac, area:GetScrollFraction().y))
			pos.x = math.clamp(pos.x, 0, x_track:GetWidth() - x_handle:GetWidth())
			pos.y = x_handle.Parent:GetHeight() - x_handle:GetHeight()
			area.scrolling = false
		end
		
		self.x_handle = x_handle
	end
			
	area.OnScroll = function(_, frac)
		area.scrolling = true
		if self.YScrollBar then
			self.y_handle:SetPosition(Vec2(0, math.clamp(self.ScrollWidth + frac.y * (self.y_track:GetHeight() - self.ScrollWidth*2), 0, self.scroll_area:GetHeight()-self.y_handle:GetHeight()-self.ScrollWidth*2)))
		end
		if self.XScrollBar then
			self.x_handle:SetPosition(Vec2(math.clamp(self.ScrollWidth + frac.x * (self.x_track:GetWidth() - self.ScrollWidth*2), 0, self.scroll_area:GetWidth()-self.x_handle:GetWidth()-self.ScrollWidth*2), 0))
		end
		area.scrolling = false
	end
	
	self:SetScrollWidth(self.ScrollWidth)
	
	self:Layout()
	
	return panel
end

function PANEL:SetScrollWidth(num)
	if self.x_track then
		self.x_track:SetHeight(num)
		self.y_track:SetWidth(num)
		
		self.x_handle:SetHeight(num)
		self.y_handle:SetWidth(num)
	end
	
	self.ScrollWidth = num
end

function PANEL:OnLayout(S)
	self:SetScrollWidth(S*4)
	
	local panel = self.panel
	
	if not panel:IsValid() then return end
	
	self.scroll_area.scrolling = true
	
	if self.XScrollBar then self.x_handle:SetPosition(self.x_handle:GetPosition()) end
	if self.YScrollBar then self.y_handle:SetPosition(self.y_handle:GetPosition()) end
		
	
	local children_size = self.scroll_area:GetSizeOfChildren()
	panel:SetSize(children_size)
				
	local y_offset = 0
	
	if self.XScrollBar and self.x_track:IsVisible() and children_size.h < children_size.w then
		y_offset = self.ScrollWidth
	end
		
	local x_offset = 0

	if self.YScrollBar and self.y_track:IsVisible() and children_size.w < children_size.h then
		x_offset = self.ScrollWidth
	end	
	
	if self.YScrollBar then
		if self.scroll_area:GetHeight() > children_size.h + self.ScrollWidth then
			self.y_track:SetVisible(false)
		else
			self.y_track:SetVisible(true)
		end
	end
	
	if self.XScrollBar then					
		if self.scroll_area:GetWidth() > children_size.w + self.ScrollWidth then
			self.x_track:SetVisible(false)
		else
			self.x_track:SetVisible(true)
		end
	end
	
	if self.YScrollBar then
		self.y_track:SetHeight(self:GetHeight() - y_offset)
		self.y_track:SetX(self:GetWidth() - self.y_track:GetWidth())
		
		self.y_handle:SetHeight(math.clamp(-(children_size.h - self.y_track:GetHeight()) + self.y_track:GetHeight(), self.ScrollWidth*2, self.y_track:GetHeight()))
	end
	
	if self.XScrollBar then	
		self.x_track:SetWidth(self:GetWidth() - x_offset)
		self.x_track:SetY(self:GetHeight() - self.x_track:GetHeight())

		self.x_handle:SetWidth(math.clamp(-(children_size.w - self.x_track:GetWidth()) + self.x_track:GetWidth() - self.ScrollWidth - x_offset, self.ScrollWidth*2, self.x_track:GetWidth()))
	end
	
	if self.YScrollBar and self.y_track:IsVisible() then
		x_offset = self.ScrollWidth
	end

	self.scroll_area:SetWidth(self:GetWidth() - x_offset)
	self.scroll_area:SetHeight(self:GetHeight() - y_offset)
	
	self.scroll_area.scrolling = false
end
	
gui.RegisterPanel(PANEL) 