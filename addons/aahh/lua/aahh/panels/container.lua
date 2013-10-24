local PANEL = {}

PANEL.Base = "panel"
PANEL.ClassName = "container"

aahh.GetSet(PANEL, "Collapse", false)
aahh.GetSet(PANEL, "SizeToContent", false)

function PANEL:Initialize()
	self.btn = aahh.Create("textbutton", self)
	self.btn.OnPress = function()
		self:SetCollapse(not self.Collapse)
	end
	self:SetMargin(Rect(0,16,0,0))
	
	lol = self
end

function PANEL:SetCollapse(b)
	self.Collapse = b
	
	if b then		
		self.last_height = self:GetHeight()
		self:SetHeight(16)
	else
		if self.SizeToContent then
			local h = 16
		
			for _, pnl in pairs(self:GetChildren()) do
				h = h + pnl:GetHeight()
			end
			
			self:SetHeight(h)
		elseif self.last_height then
				self:SetHeight(self.last_height)
				self.last_height = nil
			end
	end

	self:RequestLayout()
end

function PANEL:SetText(...)
	self.btn:SetText(...)
end

function PANEL:OnRequestLayout()
	self.btn:SetSize(Vec2(self:GetWidth(), 16))
end

aahh.RegisterPanel(PANEL)
