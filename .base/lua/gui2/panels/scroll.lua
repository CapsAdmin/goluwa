local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local scroll_width = S*8 

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
	self.scroll_area = scroll_area
end

function PANEL:SetPanel(panel)
	gui2.RemovePanel(self.down)
	gui2.RemovePanel(self.up)
	gui2.RemovePanel(self.y_handle)
	gui2.RemovePanel(self.y_track)
	gui2.RemovePanel(self.right)
	gui2.RemovePanel(self.left)
	gui2.RemovePanel(self.x_scroll_bar)
	gui2.RemovePanel(self.x_scroll)

	panel:SetParent(self.scroll_area)
	
	self.panel = panel
	panel:Layout()
	
	local panel = self.scroll_area
	
	if self.YScrollBar then
		local y_track = gui2.CreatePanel("base", self)
		y_track:SetStyle("scroll_vertical_track")
		y_track:SetWidth(scroll_width)

		local up = gui2.CreatePanel("button", y_track)	
		up:SetSize(Vec2(scroll_width, scroll_width))
		up:SetStyle("up_inactive")
		up:SetStyleTranslation("button_active", "up_active")
		up:SetStyleTranslation("button_inactive", "up_inactive")
		
		local down = gui2.CreatePanel("button", y_track)
		down:SetSize(Vec2(scroll_width, scroll_width))
		down:SetStyle("down_inactive")
		down:SetStyleTranslation("button_active", "down_active")
		down:SetStyleTranslation("button_inactive", "down_inactive")
		
		local y_handle = gui2.CreatePanel("button", y_track)
		y_handle:SetDraggable(true)	
		y_handle:SetWidth(scroll_width)
		y_handle:SetStyle("scroll_vertical_handle_inactive")
		y_handle:SetStyleTranslation("button_active", "scroll_vertical_handle_active")
		y_handle:SetStyleTranslation("button_inactive", "scroll_vertical_handle_inactive")
				
		y_handle.OnPositionChanged = function(_, pos)
			if not panel:IsValid() then return end
			
			if panel.scrolling then return end
			
			local frac = math.clamp((pos.y - scroll_width) / (self.y_track:GetHeight() - scroll_width), 0, 1)

			panel:SetScrollFraction(Vec2(panel:GetScrollFraction().x, frac))
	 
			pos.x = y_handle.Parent:GetWidth() - y_handle:GetWidth()
			pos.y = math.clamp(pos.y, scroll_width, y_handle.Parent:GetHeight() - y_handle:GetHeight() - scroll_width)
		end
		
		up.OnPress = function(_, button, press)
			if not panel:IsValid() then return end

			if #panel:GetChildren() == 0 then return end
			
			local h = panel:GetChildren()[1]:GetHeight()
			
			local pos = panel:GetScroll()
			pos.y = pos.y - h
			panel:SetScroll(pos)
		end
		
		down.OnPress = function(_, button, press)
			if not panel:IsValid() then return end
			
			if #panel:GetChildren() == 0 then return end
			
			local h = panel:GetChildren()[1]:GetHeight()
			
			local pos = panel:GetScroll()
			pos.y = pos.y + h
			panel:SetScroll(pos)
		end
		
		self.down = down
		self.up = up
		self.y_handle = y_handle 
		self.y_track = y_track
	end
	
	if self.XScrollBar then
		local x_scroll = gui2.CreatePanel("base", self)
		x_scroll:SetStyle("scroll_horizontal_track")
		x_scroll:SetHeight(scroll_width)
		
		local left = gui2.CreatePanel("text_button", x_scroll)	
		left:SetSize(Vec2(scroll_width, scroll_width))
		left:SetStyle("left_inactive")
		left:SetStyleTranslation("button_active", "left_active")
		left:SetStyleTranslation("button_inactive", "left_inactive")
		
		local right = gui2.CreatePanel("text_button", x_scroll)
		right:SetSize(Vec2(scroll_width, scroll_width))
		right:SetStyle("right_inactive")
		right:SetStyleTranslation("button_active", "right_active")
		right:SetStyleTranslation("button_inactive", "right_inactive")
		
		local x_scroll_bar = gui2.CreatePanel("button", x_scroll)
		x_scroll_bar:SetDraggable(true)
		x_scroll_bar:SetHeight(scroll_width)
		x_scroll_bar:SetStyle("scroll_horizontal_handle_inactive")
		x_scroll_bar:SetStyleTranslation("button_active", "scroll_horizontal_handle_active")
		x_scroll_bar:SetStyleTranslation("button_inactive", "scroll_horizontal_handle_inactive")
		
		x_scroll_bar.OnPositionChanged = function(_, pos)
			if not panel:IsValid() then return end
			
			if panel.scrolling then return end
			local frac = math.clamp((pos.x - scroll_width) / (panel:GetSizeOfChildren().w - scroll_width), 0, 1)
			
			panel:SetScrollFraction(Vec2(frac, panel:GetScrollFraction().y))
	 
			pos.x = math.clamp(pos.x, scroll_width, x_scroll:GetWidth() - x_scroll_bar:GetWidth() - scroll_width)
			pos.y = x_scroll_bar.Parent:GetHeight() - x_scroll_bar:GetHeight()
		end
				
		left.OnPress = function(_, button, press)
			if not panel:IsValid() then return end
			
			if #panel:GetChildren() == 0 then return end
			
			local w = panel:GetChildren()[1]:GetWidth()
			
			local pos = panel:GetScroll()
			pos.x = pos.x - w
			panel:SetScroll(pos)
		end
		
		right.OnPress = function(_, button, press)
			if not panel:IsValid() then return end
			
			if #panel:GetChildren() == 0 then return end
			
			local w = panel:GetChildren()[1]:GetWidth()
			
			local pos = panel:GetScroll()
			pos.x = pos.x + w
			panel:SetScroll(pos)
		end
		
		self.right = right
		self.left = left
		self.x_scroll_bar = x_scroll_bar
		self.x_scroll = x_scroll
	end
			
	panel.OnScroll = function(_, frac)
		panel.scrolling = true
		if self.YScrollBar then
			self.y_handle:SetPosition(Vec2(0, math.clamp(scroll_width + frac.y * (self.y_track:GetHeight() - scroll_width*2), 0, self.scroll_area:GetHeight()-self.y_handle:GetHeight()-scroll_width*2)))
		end
		if self.XScrollBar then
			self.x_scroll_bar:SetPosition(Vec2(math.clamp(scroll_width + frac.x * (self.x_scroll:GetWidth() - scroll_width*2), 0, self.scroll_area:GetWidth()-self.x_scroll_bar:GetWidth()-scroll_width*2), 0))
		end
		panel.scrolling = false
	end
end

function PANEL:OnLayout()
	local panel = self.panel
	
	if not panel:IsValid() then return end
	
	if self.XScrollBar then self.x_scroll_bar:SetPosition(self.x_scroll_bar:GetPosition()) end
	if self.YScrollBar then self.y_handle:SetPosition(self.y_handle:GetPosition()) end
		
	panel:SetSize(panel:GetSizeOfChildren())
	
	if self.YScrollBar then
		local offset = 0
	
		if self.XScrollBar and self.x_scroll:IsVisible() then
			offset = scroll_width
		end
	
		self.y_track:SetHeight(self:GetHeight())
		self.y_track:SetX(self:GetWidth() - self.y_track:GetWidth())
		
		self.y_handle:SetHeight(math.max(self.y_track:GetHeight() - panel:GetHeight() + self.y_track:GetHeight() - self.down:GetHeight() - self.up:GetHeight(), scroll_width))
				
		self.down:SetY(self:GetHeight() - self.down:GetHeight())
		
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
	
		self.x_scroll:SetWidth(self:GetWidth() - scroll_width)
		self.x_scroll:SetY(self:GetHeight() - self.x_scroll:GetHeight())
		
		self.right:SetX(self:GetWidth() - self.right:GetWidth() - offset)
		
		self.x_scroll_bar:SetWidth(math.max(-(panel:GetSizeOfChildren().w - self.x_scroll:GetWidth()) + self.x_scroll:GetWidth() - offset, scroll_width))
					
		if self.scroll_area:GetWidth() > panel:GetSizeOfChildren().w then
			self.x_scroll:SetVisible(false)
		else
			self.x_scroll:SetVisible(true)
		end
	end		

	if self.YScrollBar and self.y_track:IsVisible() then
		self.scroll_area:SetWidth(self:GetWidth() - scroll_width)
	else
		self.scroll_area:SetWidth(self:GetWidth())
	end

	if self.XScrollBar and self.x_scroll:IsVisible() then
		self.scroll_area:SetHeight(self:GetHeight() - scroll_width)
	else
		self.scroll_area:SetHeight(self:GetHeight())
	end
	
end
	
gui2.RegisterPanel(PANEL) 