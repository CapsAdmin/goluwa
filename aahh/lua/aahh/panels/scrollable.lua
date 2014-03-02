local PANEL = {}

PANEL.ClassName = "scrollable"

aahh.GetSet(PANEL, "ScrollHeight", 50)
aahh.GetSet(PANEL, "ScrollWidth", 50)
aahh.GetSet(PANEL, "YScroll", true)
aahh.GetSet(PANEL, "XScroll", false)
aahh.GetSet(PANEL, "ScrollPos", Vec2())
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
	if self.start_y then
		if aahh.IsMouseDown("button_1") then
			
			local y = pos.y - self.start_y.y
			local max = self:GetHeight() - self.y_bar:GetHeight()
			y = math.clamp(y, 0, max)
			
			self.y_bar:SetY(y)
			y = y / max
						
			self:SetScrollFraction(Vec2(0, -y))
			
			self:OnRequestLayout()
		else
			self.start_y = nil
		end
	end
end

PANEL.y_bar = NULL

function PANEL:SetYScroll(b)
	if b then
		if self.y_bar:IsValid() then self.y_bar.Remove() end
		
		local pnl = aahh.Create("button", self)
		
		
		pnl:SetCursor(e.IDC_ARROW)
		pnl:SetTrapInsideParent(false)
		pnl:SetObeyMargin(false)
					
		pnl.OnMouseInput = function(s, button, press, pos)
			if button == "button_1" and press then
				self.start_y = pos
			end
		end
		
		self.y_bar = pnl
		self:SetMargin(Rect(0,0,10,0))
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
		if self.x_bar:IsValid() then self.x_bar.Remove() end
		
		local pnl = aahh.Create("draggable", self)
		pnl:SetTrapInsideParent(false)
		pnl:SetObeyMargin(false)
		
		pnl.CalcBounds = function(s)
			local x = s:GetPos()
			
			s:SetPos(Vec2(x, self:GetHeight() - 10))
			s:SetSize(Vec2(self.ScrollWidth, 10))
			
			local delta = x - (self.last_x or 0)
			self:Scroll(Vec2(delta, 0))		
			self.last_x = x
		end
		
		local old = pnl.OnMouseInput
		
		pnl.OnMouseInput = function(s, ...) 
			self.OnMouseInput(self, ...)
			old(s, ...)
		end
		
		self.x_bar = pnl
	else
		if self.x_bar:IsValid() then
			self.x_bar:Remove()
		end
	end
end

function PANEL:Scroll(vec)
	
	if self.y_bar:IsValid() then self.y_bar:SetPos(self.y_bar:GetPos() + vec) end
	if self.x_bar:IsValid() then self.x_bar:SetPos(self.x_bar:GetPos() + vec) end

	local pos = self:GetPos()
	local siz = self:GetSize()
	
	pos = pos - vec
	siz = siz + vec
		
	self:SetSize(siz)
	self:SetPos(pos)
	
	self.ScrollPos = self.ScrollPos + vec
end

function PANEL:SetScrollFraction(vec)
	self.ScrollFraction = vec	
	self.ScrollPos = vec
	self:RequestLayout(true)
end

function PANEL:OnRequestLayout()	
	if self.container:IsValid() then
		self.container:SizeToContents()	
		
		local vec = self.ScrollFraction
		self.container:SizeToContents()
		local size = self.container:GetSize()
		local h = -(size.h - self:GetHeight()) + self:GetHeight()
		local hm = Vec2(1, (self:GetHeight()-h) / size.h)
		vec = vec * size * hm

		vec.y = math.clamp(vec.y, -size.h + self:GetHeight(), 0)
		
		if self:GetHeight() > size.h then
			vec.y = 0
		end
		
		h = math.max(h, 20)
		
		if self.y_bar:IsValid() then
			self.y_bar:SetPos(Vec2(self:GetWidth() - 10, math.clamp(self.y_bar:GetPos().y, 0, self:GetHeight() - h)))
		end
			
		self.container:SetPos(vec)
		self.container:SetOffset(vec)
				
		if h >= self:GetHeight() then
			self.y_bar:SetVisible(false)
			self.container:SetWidth(self:GetWidth())
		else
			self.container:SetWidth(self:GetWidth() - 10)
			self.y_bar:SetVisible(true)
			self.y_bar:SetSize(Vec2(10, h))
		end
		
	end
end

function PANEL:OnMouseInput(key, press)
	if press then
		if key == "mwheel_down" then
			self:Scroll(Vec2(0, 1) * 10)
		elseif key == "mwheel_up" then
			self:Scroll(Vec2(0, -1) * 10)
		end
	end
end

aahh.RegisterPanel(PANEL)