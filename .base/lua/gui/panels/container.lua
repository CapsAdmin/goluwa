local PANEL = {}

PANEL.Base = "grid"
PANEL.ClassName = "container"

gui.GetSet(PANEL, "Collapse", false)

function PANEL:Initialize()
	self.btn = gui.Create("text_button", self)
	self.btn.OnPress = function()
		self:SetCollapse(not self.Collapse)
	end
	self:SetMargin(Rect(0,16,0,0))
	
	lol = self
end

function PANEL:SetCollapse(b)
	self.Collapse = b
	
	if b then		
		self:SetHeight(16)
	else	
		self:SizeToContents()
	end
end

function PANEL:SetText(...)
	self.btn:SetText(...)
end

gui.RegisterPanel(PANEL)
