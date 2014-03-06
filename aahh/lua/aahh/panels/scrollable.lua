local PANEL = {}

PANEL.ClassName = "scrollable"

aahh.GetSet(PANEL, "ScrollHeight", 50)
aahh.GetSet(PANEL, "ScrollWidth", 50)
aahh.GetSet(PANEL, "YScroll", true)
aahh.GetSet(PANEL, "XScroll", true)
aahh.GetSet(PANEL, "ScrollFraction", Vec2())

function PANEL:Initialize()	
	self:SetTrapChildren(false)
	
	self:SetXScroll(self:GetXScroll())
	self:SetYScroll(self:GetYScroll())
	
	self:SetAlwaysReceiveMouse(true)
end

function PANEL:SetPanel(pnl)	
	self.container = pnl
	pnl:SetParent(self)
	self:RequestLayout()
end

function PANEL:OnMouseMove(pos, inside)	
	if self.start_mpos then
		if aahh.IsMouseDown("button_1") then
			
			local diff = pos - self.start_mpos	
		
			if self.x_drag and self.x_bar:IsValid() then
				local maxx = self:GetWidth() - self.x_bar:GetWidth()
				diff.x = math.clamp(diff.x, 0, maxx)
				self.x_bar:SetX(diff.x)
				diff.x = diff.x / maxx
			else
				diff.x = self.ScrollFraction.x
			end
				
			if self.y_drag and self.y_bar:IsValid() then
				local maxy = self:GetHeight() - self.y_bar:GetHeight()
				diff.y = math.clamp(diff.y, 0, maxy)
				self.y_bar:SetY(diff.y)
				diff.y = diff.y / maxy
			else
				diff.y = self.ScrollFraction.y
			end
										
			self:SetScrollFraction(diff)
			
			self:OnRequestLayout()
		else
			self.start_mpos = nil
		end
	end
end

PANEL.y_bar = NULL

function PANEL:OnMouseInput(button, press, pos)
	if button == "button_3" then
		self.y_drag = true
		self.x_drag = true
		self.start_mpos = pos
	end
end

function PANEL:SetYScroll(b)
	if b then
		if self.y_bar:IsValid() then self.y_bar:Remove() end
		
		local pnl = aahh.Create("button", self)
		
		pnl:SetCursor(e.IDC_ARROW)
		pnl:SetTrapInsideParent(false)
		pnl:SetObeyMargin(false)
					
		pnl.OnMouseInput = function(s, button, press, pos)
			if button == "button_1" and press then
				self.start_mpos = pos
				self.y_drag = true
				self.x_drag = false
			elseif button == "button_3" then
				self.y_drag = true
				self.x_drag = true
				self.start_mpos = pos
			end
		end
		
		self.y_bar = pnl
		--self:SetMargin(Rect(0,self.x_bar:IsValid() and 10 or 0,self.y_bar:IsValid() and 10 or 0,0))
		self:RequestLayout()
	else
		if self.y_bar:IsValid() then
			self.y_bar:Remove()
		end
	end
end

PANEL.x_bar = NULL

function PANEL:SetXScroll(b)
	if b then
		if self.x_bar:IsValid() then self.x_bar:Remove() end
		
		local pnl = aahh.Create("button", self)
		
		pnl:SetCursor(e.IDC_ARROW)
		pnl:SetTrapInsideParent(false)
		pnl:SetObeyMargin(false)
					
		pnl.OnMouseInput = function(s, button, press, pos)
			if button == "button_1" and press then
				self.start_mpos = pos
				self.y_drag = false
				self.x_drag = true
			elseif button == "button_3" then
				self.y_drag = true
				self.x_drag = true
				self.start_mpos = pos
			end
		end
		
		self.x_bar = pnl
		--self:SetMargin(Rect(0,self.x_bar:IsValid() and 10 or 0,self.y_bar:IsValid() and 10 or 0,0))
		self:RequestLayout()
	else
		if self.x_bar:IsValid() then
			self.x_bar:Remove()
		end
	end
end

function PANEL:SetScrollFraction(vec)
	vec.x = math.clamp(vec.x, 0, 1)
	vec.y = math.clamp(vec.y, 0, 1)
	
	self.ScrollFraction = vec	
	self:RequestLayout(true)
end

function PANEL:OnRequestLayout()	
	if self.container:IsValid() then
								
		local vec = -self.ScrollFraction
		
		self.container:SizeToContents()
		
		local size = self.container:GetSize()
		local huh = -(size - self:GetSize()) + self:GetSize()
		local hm = (self:GetSize() - huh) / size
		
		vec = vec * size * hm
		
		vec.x = math.clamp(vec.x, -size.w + self:GetWidth(), 0)
		vec.y = math.clamp(vec.y, -size.h + self:GetHeight(), 0)
		
		if self:GetHeight() > size.h then
			vec.y = 0
		end
		
		if self:GetWidth() > size.w then
			vec.x = 0
		end
		
		huh.x = math.max(huh.x, 20)
		huh.y = math.max(huh.y, 20)
		
		if self.y_bar:IsValid() then
			self.y_bar:SetPos(Vec2(self:GetWidth() - 10, math.clamp(self.y_bar:GetPos().y, 0, self:GetHeight() - huh.y - (self.x_bar:IsValid() and self.x_bar:GetHeight() or 0))))
		end
		
		if self.x_bar:IsValid() then
			self.x_bar:SetPos(Vec2(math.clamp(self.x_bar:GetPos().x, 0, self:GetWidth() - huh.x - (self.y_bar:IsValid() and self.y_bar:GetWidth() or 0)), self:GetHeight() - 10 ))
		end
		
			
		self.container:SetPos(vec)
		self.container:SetOffset(vec)
				
		if huh.y >= self:GetHeight() then
			self.y_bar:SetVisible(false)
			self.container:SetWidth(self:GetWidth() - vec.x)
		else
			self.container:SetWidth(self:GetWidth() - 10 - vec.x)
			self.y_bar:SetVisible(true)
			self.y_bar:SetSize(Vec2(10, huh.y))
		end
		
		if huh.x >= self:GetWidth() then
			self.x_bar:SetVisible(false)
			self.container:SetHeight(self:GetHeight() - vec.y)
		else
			self.container:SetHeight(self:GetHeight() - 10 - vec.y)
			self.x_bar:SetVisible(true)
			self.x_bar:SetSize(Vec2(huh.x, 10))
		end
		
	end
end

function PANEL:OnMouseInput(key, press)
	if press then
		local offset
		
		if key == "mwheel_down" then
			offset = Vec2(0, 40)
		elseif key == "mwheel_up" then
			offset = Vec2(0, -40)
		end
		
		if offset then
			self.y_bar:SetY(self.y_bar:GetPos().y + offset.y / 2)
			self:SetScrollFraction((self.ScrollFraction * self.container:GetSize() + offset) / self.container:GetSize())
		end
	end
end

aahh.RegisterPanel(PANEL)