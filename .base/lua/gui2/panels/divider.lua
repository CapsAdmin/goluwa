local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "divider"

prototype.GetSet(PANEL, "DividerHeight", 0)
prototype.GetSet(PANEL, "DividerWidth", S*2)

local function create_horizontal_divider(self)
	if self.horizontal_divider then return end
	local divider = gui2.CreatePanel("button", self)
	divider:SetX(self:GetWidth() - self.DividerWidth/2)
	divider:SetCursor("sizewe")
	divider:SetDraggable(true)
	divider.OnPositionChanged = function(_, pos)
		pos.x = math.clamp(pos.x, 0, self:GetWidth() - self.DividerWidth)
		pos.y = 0
		self:Layout()
	end
	self.horizontal_divider = divider
end

local function create_vertical_divider(self)
	if self.vertical_divider then return end
	local divider = gui2.CreatePanel("button", self)
	divider:SetY(self:GetHeight() - self.DividerWidth/2)
	divider:SetCursor("sizens")
	divider:SetDraggable(true)
	divider.OnPositionChanged = function(_, pos)
		pos.x = 0
		pos.y = math.clamp(pos.y, 0, self:GetHeight() - self.DividerWidth)
		self:Layout()
	end
	self.vertical_divider = divider
end

function PANEL:Initialize()
	self:SetNoDraw(true)
end

function PANEL:OnLayout()
	if self.horizontal_divider then
		self.horizontal_divider:SetSize(Vec2(self.DividerWidth, self.DividerHeight == 0 and self:GetHeight() or self.DividerHeight))
		
		if self.left then
			self.left:SetSize(Vec2(self.horizontal_divider:GetPosition().x, self:GetHeight()))
		end
		
		if self.right then
			self.right:SetX(self.horizontal_divider:GetPosition().x + self.DividerWidth)
			self.right:SetSize(Vec2(self:GetWidth() - self.horizontal_divider:GetPosition().x - self.DividerWidth,  self:GetHeight()))
		end
	end
	
	if self.vertical_divider then
		self.vertical_divider:SetSize(Vec2(self.DividerHeight == 0 and self:GetWidth() or self.DividerHeight, self.DividerWidth))
		
		if self.top then
			self.top:SetSize(Vec2(self:GetWidth(), self.vertical_divider:GetPosition().y))
		end
		
		if self.bottom then
			self.bottom:SetY(self.vertical_divider:GetPosition().y + self.DividerWidth)
			self.bottom:SetSize(Vec2(self:GetWidth(), self:GetHeight() - self.vertical_divider:GetPosition().y - self.DividerWidth))
		end
	end
end

function PANEL:SetLeft(pnl)
	create_horizontal_divider(self)
	pnl:SetParent(self)
	self.left = pnl
	self:Layout()
	return pnl
end

function PANEL:SetRight(pnl)
	create_horizontal_divider(self)
	pnl:SetParent(self)
	self.right = pnl
	self:Layout()
	return pnl
end

function PANEL:SetTop(pnl)
	create_vertical_divider(self)
	pnl:SetParent(self)
	self.top = pnl
	self:Layout()
	return pnl
end

function PANEL:SetBottom(pnl)
	create_vertical_divider(self)
	pnl:SetParent(self)
	self.bottom = pnl
	self:Layout()
	return pnl
end

function PANEL:SetDividerPosition(x, y)
	if self.horizontal_divider then self.horizontal_divider:SetX(x) end
	if self.vertical_divider then self.vertical_divider:SetY(y) end
end

function PANEL:GetDividerPosition()
	local x, y = 0, 0
	if self.horizontal_divider then x = self.horizontal_divider:GetX() end
	if self.vertical_divider then y = self.vertical_divider:GetX() end
	return x, y
end

gui2.RegisterPanel(PANEL)