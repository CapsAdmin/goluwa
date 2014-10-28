local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "horizontal_divider"

prototype.GetSet(PANEL, "DividerHeight", 0)
prototype.GetSet(PANEL, "DividerWidth", S*4)

function PANEL:Initialize()
	self:SetNoDraw(true)
	local divider = gui2.CreatePanel("button", self)
	divider:SetX(self:GetWidth() - self.DividerWidth/2)
	divider:SetCursor("sizewe")
	divider:SetDraggable(true)
	divider.OnPositionChanged = function(_, pos)
		pos.x = math.clamp(pos.x, 0, self:GetWidth() - self.DividerWidth)
		pos.y = 0
		self:Layout()
	end
	self.divider = divider
end

function PANEL:OnLayout()
	self.divider:SetSize(Vec2(self.DividerWidth, self.DividerHeight == 0 and self:GetHeight() or self.DividerHeight))
	
	if self.left then
		self.left:SetPosition(Vec2(0, 0))
		self.left:SetSize(Vec2(self.divider:GetPosition().x, self:GetHeight()))
	end
	
	if self.right then
		self.right:SetPosition(Vec2(self.divider:GetPosition().x + self.DividerWidth, 0))
		self.right:SetSize(Vec2(self:GetWidth() - self.divider:GetPosition().x - self.DividerWidth,  self:GetHeight()))
	end
end

function PANEL:SetLeft(pnl)
	pnl:SetParent(self)
	self.left = pnl
	self:Layout()
	return pnl
end

function PANEL:SetRight(pnl)
	pnl:SetParent(self)
	self.right = pnl
	self:Layout()
	return pnl
end

function PANEL:SetDividerPosition(num)
	self.divider:SetPosition(Vec2(num, 0))
end

function PANEL:GetDividerPosition()
	return self.divider:GetPosition().x
end

gui2.RegisterPanel(PANEL)