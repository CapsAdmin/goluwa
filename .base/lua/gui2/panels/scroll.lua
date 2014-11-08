local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local scroll_width = S*4

local PANEL = {}
PANEL.ClassName = "scroll"

PANEL.panel = NULL

prototype.GetSet(PANEL, "XScrollBar", true)
prototype.GetSet(PANEL, "YScrollBar", true)

function PANEL:Initialize()
	self:SetNoDraw(true)
	
	local scroll_area = gui2.CreatePanel("base", self)
	scroll_area:SetClipping(true)
	scroll_area:SetNoDraw(true)
	scroll_area:SetAlwaysReceiveMouseInput(true)
	scroll_area:SetMargin(Rect())
	self.scroll_area = scroll_area
end

function PANEL:SetPanel(panel)
	gui2.RemovePanel(self.y_handle)
	gui2.RemovePanel(self.y_track)
	gui2.RemovePanel(self.x_handle)
	gui2.RemovePanel(self.x_track)

	panel:SetParent(self.scroll_area)
	
	self.panel = panel
	panel:Layout()
	
	local panel = self.scroll_area
	
	if self.YScrollBar then
		local y_track = gui2.CreatePanel("base", self)
		y_track:SetStyle("scroll_vertical_track")
		y_track:SetWidth(scroll_width)

		local y_handle = gui2.CreatePanel("button", y_track)
		y_handle:SetDraggable(true)	
		y_handle:SetWidth(scroll_width)
		y_handle:SetStyle("scroll_vertical_handle_inactive")
		y_handle:SetStyleTranslation("button_active", "scroll_vertical_handle_active")
		y_handle:SetStyleTranslation("button_inactive", "scroll_vertical_handle_inactive")
				
		y_handle.OnPositionChanged = function(_, pos)
			if not panel:IsValid() then return end
			
			if panel.scrolling then return end
			
			local h = panel:GetSizeOfChildren().h
			local frac = math.clamp(pos.y / h, 0, 1)

			panel:SetScrollFraction(Vec2(panel:GetScrollFraction().x, frac))
	 
			pos.x = y_handle.Parent:GetWidth() - y_handle:GetWidth()
			pos.y = math.clamp(pos.y, 0, y_handle.Parent:GetHeight() - y_handle:GetHeight())
		end
		
		self.y_handle = y_handle 
		self.y_track = y_track
	end
	
	if self.XScrollBar then
		local x_track = gui2.CreatePanel("base", self)
		x_track:SetStyle("scroll_horizontal_track")
		x_track:SetHeight(scroll_width)
		
		local x_handle = gui2.CreatePanel("button", x_track)
		x_handle:SetDraggable(true)
		x_handle:SetHeight(scroll_width)
		x_handle:SetStyle("scroll_horizontal_handle_inactive")
		x_handle:SetStyleTranslation("button_active", "scroll_horizontal_handle_active")
		x_handle:SetStyleTranslation("button_inactive", "scroll_horizontal_handle_inactive")
		
		x_handle.OnPositionChanged = function(_, pos)
			if not panel:IsValid() then return end
			
			if panel.scrolling then return end
			local frac = math.clamp(pos.x / panel:GetSizeOfChildren().w, 0, 1)
			
			panel:SetScrollFraction(Vec2(frac, panel:GetScrollFraction().y))
	 
			pos.x = math.clamp(pos.x, 0, x_track:GetWidth() - x_handle:GetWidth())
			pos.y = x_handle.Parent:GetHeight() - x_handle:GetHeight()
		end
		
		self.x_handle = x_handle
		self.x_track = x_track
	end
			
	panel.OnScroll = function(_, frac)
		panel.scrolling = true
		if self.YScrollBar then
			self.y_handle:SetPosition(Vec2(0, math.clamp(scroll_width + frac.y * (self.y_track:GetHeight() - scroll_width*2), 0, self.scroll_area:GetHeight()-self.y_handle:GetHeight()-scroll_width*2)))
		end
		if self.XScrollBar then
			self.x_handle:SetPosition(Vec2(math.clamp(scroll_width + frac.x * (self.x_track:GetWidth() - scroll_width*2), 0, self.scroll_area:GetWidth()-self.x_handle:GetWidth()-scroll_width*2), 0))
		end
		panel.scrolling = false
	end
	
	self:Layout()
end

function PANEL:OnLayout()
	local panel = self.panel
	
	if not panel:IsValid() then return end
	
	if self.XScrollBar then self.x_handle:SetPosition(self.x_handle:GetPosition()) end
	if self.YScrollBar then self.y_handle:SetPosition(self.y_handle:GetPosition()) end
		
	panel:SetSize(panel:GetSizeOfChildren())
	
	if self.YScrollBar then
		local offset = 0
	
		if self.XScrollBar and self.x_track:IsVisible() then
			offset = scroll_width
		end
	
		self.y_track:SetHeight(self:GetHeight() - scroll_width)
		self.y_track:SetX(self:GetWidth() - self.y_track:GetWidth())
		
		self.y_handle:SetHeight(math.max(-(panel:GetSizeOfChildren().h - self.y_track:GetHeight()) + self.y_track:GetHeight(), scroll_width))
						
		if self.scroll_area:GetHeight() > panel:GetSizeOfChildren().h then
			self.y_track:SetVisible(false)
		else
			self.y_track:SetVisible(true)
		end
	end
	
	if self.XScrollBar then
		local offset = 0
	
		if self.YScrollBar and self.y_track:IsVisible() then
			offset = scroll_width
		end	
	
		self.x_track:SetWidth(self:GetWidth() - scroll_width)
		self.x_track:SetY(self:GetHeight() - self.x_track:GetHeight())
		
		--self.right:SetX(self:GetWidth() - self.right:GetWidth() - offset)
		
		self.x_handle:SetWidth(math.max(-(panel:GetSizeOfChildren().w - self.x_track:GetWidth()) + self.x_track:GetWidth(), scroll_width))
					
		if self.scroll_area:GetWidth() > panel:GetSizeOfChildren().w then
			self.x_track:SetVisible(false)
		else
			self.x_track:SetVisible(true)
		end
	end		

	if self.YScrollBar and self.y_track:IsVisible() then
		self.scroll_area:SetWidth(self:GetWidth() - scroll_width)
	else
		self.scroll_area:SetWidth(self:GetWidth())
	end

	if self.XScrollBar and self.x_track:IsVisible() then
		self.scroll_area:SetHeight(self:GetHeight() - scroll_width)
	else
		self.scroll_area:SetHeight(self:GetHeight())
	end	
end
	
gui2.RegisterPanel(PANEL) 