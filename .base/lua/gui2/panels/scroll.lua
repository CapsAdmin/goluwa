local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local scroll_width = S*8 

local PANEL = {}
PANEL.ClassName = "scroll"

PANEL.panel = NULL

prototype.GetSet(PANEL, "XScrollBar", true)
prototype.GetSet(PANEL, "YScrollBar", true)

function PANEL:Initialize()
	self:SetColor(Color(0,0,0,0))
end

function PANEL:SetPanel(panel)
	panel:SetParent(self)
	
	self.panel = panel
	
	if self.YScrollBar then
		local y_scroll = gui2.CreatePanel("base", self)
		y_scroll:SetSimpleTexture(true)
		y_scroll:SetStyle("gradient2")

		local up = gui2.CreatePanel("text_button", y_scroll)				
		local down = gui2.CreatePanel("text_button", y_scroll)

		local y_scroll_bar = gui2.CreatePanel("button", y_scroll)
		y_scroll_bar:SetDraggable(true)	
				
		y_scroll_bar.OnPositionChanged = function(_, pos)
			if not panel:IsValid() then return end
			
			if panel.scrolling then return end
			
			local frac = math.clamp((pos.y - scroll_width) / (panel:GetSizeOfChildren().h - scroll_width), 0, 1)
			
			panel:SetScrollFraction(Vec2(panel:GetScrollFraction().x, frac))
	 
			pos.x = y_scroll_bar.Parent:GetWidth() - y_scroll_bar:GetWidth()
			pos.y = math.clamp(pos.y, scroll_width, y_scroll_bar.Parent:GetHeight() - y_scroll_bar:GetHeight() - scroll_width)
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
		self.y_scroll_bar = y_scroll_bar 
		self.y_scroll = y_scroll
	end
	
	if self.XScrollBar then
		local x_scroll = gui2.CreatePanel("base", self)
		x_scroll:SetSimpleTexture(true)
		x_scroll:SetStyle("gradient3")

		local left = gui2.CreatePanel("text_button", x_scroll)				
		local right = gui2.CreatePanel("text_button", x_scroll)

		local x_scroll_bar = gui2.CreatePanel("button", x_scroll)
		x_scroll_bar:SetDraggable(true)
		
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
			self.y_scroll_bar:SetPosition(Vec2(0, math.clamp(scroll_width + frac.y * (self.y_scroll:GetHeight() - scroll_width*2), 0, self:GetHeight()-self.y_scroll_bar:GetHeight()-scroll_width*2)))
		end
		if self.XScrollBar then
			self.x_scroll_bar:SetPosition(Vec2(math.clamp(scroll_width + frac.x * (self.x_scroll:GetWidth() - scroll_width*2), 0, self:GetWidth()-self.x_scroll_bar:GetWidth()-scroll_width*2), 0))
		end
		panel.scrolling = false
	end
end

function PANEL:OnLayout()
	local panel = self.panel
	
	if not panel:IsValid() then return end
	
	self.x_scroll_bar:SetPosition(self.x_scroll_bar:GetPosition())
	self.y_scroll_bar:SetPosition(self.y_scroll_bar:GetPosition())
	
	panel:SetSize(panel:GetSizeOfChildren())
	
	if self.YScrollBar then
		self.y_scroll:SetSize(Vec2(scroll_width, self:GetHeight() - scroll_width))
		self.y_scroll:SetPosition(Vec2(self:GetWidth() - scroll_width, 0))
		
		self.down:SetSize(Vec2(scroll_width, scroll_width))
		self.down:SetPosition(Vec2(0, self:GetHeight() - self.down:GetHeight() - scroll_width))
		
		self.y_scroll_bar:SetSize(Vec2(scroll_width, math.max(-(panel:GetSizeOfChildren().h - self.y_scroll:GetHeight()) + self.y_scroll:GetHeight() - scroll_width, scroll_width)))
		
		self.up:SetSize(Vec2(scroll_width, scroll_width))
			
		if self:GetHeight() > panel:GetSizeOfChildren().h then
			self.y_scroll:SetVisible(false)
		else
			self.y_scroll:SetVisible(true)
		end
	end
	
	if self.XScrollBar then
		self.x_scroll:SetSize(Vec2(self:GetWidth() - scroll_width, scroll_width))
		self.x_scroll:SetPosition(Vec2(0, self:GetHeight() - scroll_width))
		
		self.right:SetSize(Vec2(scroll_width, scroll_width))
		self.right:SetPosition(Vec2(self:GetWidth() - self.right:GetWidth() - scroll_width, 0))
		
		self.x_scroll_bar:SetSize(Vec2(math.max(-(panel:GetSizeOfChildren().w - self.x_scroll:GetWidth()) + self.x_scroll:GetWidth() - scroll_width, scroll_width), scroll_width))
		
		self.left:SetSize(Vec2(scroll_width, scroll_width))
			
		if self:GetWidth() > panel:GetSizeOfChildren().w then
			self.x_scroll:SetVisible(false)
		else
			self.x_scroll:SetVisible(true)
		end
	end		

	if self.YScrollBar and self.y_scroll:IsVisible() then
		panel:SetWidth(self:GetWidth() - scroll_width)
	else
		panel:SetWidth(self:GetWidth())
	end

	if self.XScrollBar and self.x_scroll:IsVisible() then
		panel:SetHeight(self:GetHeight() - scroll_width)
	else
		panel:SetHeight(self:GetHeight())
	end
	
end
	
gui2.RegisterPanel(PANEL) 