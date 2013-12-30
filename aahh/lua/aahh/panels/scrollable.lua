local PANEL = {}

PANEL.ClassName = "scrollable"

aahh.GetSet(PANEL, "ScrollHeight", 50)
aahh.GetSet(PANEL, "ScrollWidth", 50)
aahh.GetSet(PANEL, "YScroll", true)
aahh.GetSet(PANEL, "XScroll", false)
aahh.GetSet(PANEL, "ScrollPos", Vec2())

function PANEL:Initialize()	
	self:SetTrapInsideParent(false)
	self:SetObeyMargin(false)
	
	self:SetXScroll(self:GetXScroll())
	self:SetYScroll(self:GetYScroll())
	
	self:SetAlwaysReceiveMouse(true)
end

PANEL.y_bar = NULL

function PANEL:SetYScroll(b)
	if b then
		local pnl = aahh.Create("draggable", self)
		pnl:SetTrapInsideParent(false)
		pnl:SetObeyMargin(false)
	
		pnl.CalcBounds = function(s)
			local y = s:GetPos().y
			
			s:SetPos(Vec2(self:GetWidth() - 10, y))
			s:SetSize(Vec2(10, self.ScrollHeight))
			
			local delta = y - (self.last_y or 0)
			self:Scroll(Vec2(0, delta))		
			self.last_y = y
		end
		
		local old = pnl.OnMouseInput
		
		pnl.OnMouseInput = function(s, ...) 
			self.OnMouseInput(self, ...)
			old(s, ...)
		end
		
		self.y_bar = pnl
	else
		if self.y_bar:IsValid() then
			self.y_bar:Remove()
		end
	end
end

PANEL.x_bar = NULL

function PANEL:SetXScroll(b)
	if b then
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

function PANEL:IsWorldPosInside(a)
	local b, s = self:GetWorldPos(), self:GetSize()
	
	b = b + self.ScrollPos
	s = s - self.ScrollPos
	
	if
		a.x > b.x and a.x < b.x + s.w and
		a.y > b.y and a.y < b.y + s.h
	then
		return true
	end
	
	return false
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

function PANEL:OnRequestLayout()
	
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