local PANEL = {}

PANEL.ClassName = "textbutton"
PANEL.Base = "button"

function PANEL:Initialize()
	self.BaseClass.Initialize(self)
	
	self.lbl = aahh.Create("label", self)
	self.lbl:SetIgnoreMouse(true)
		
	self:SetCursor(e.IDC_HAND)
end

function PANEL:GetLabel()
	return self.lbl or NULL
end

function PANEL:SetTextOffset(...)
	self.lbl:SetTextOffset(...)
end

function PANEL:SetAlignNormal(...)
	self.lbl:SetAlignNormal(...)
end

function PANEL:SetText(str)
	self.lbl:SetText(str)
	self.lbl:SizeToText()
	local pad = self:GetSkinVar("Padding", 1) * 2
	
	self:SetSize(self.lbl:GetSize() + pad)
	self:RequestLayout()
end

function PANEL:SetFont(name)
	self.lbl:SetFont(name)
end

function PANEL:SetTextSize(siz)
	self.lbl:SetTextSize(siz)
end

function PANEL:OnDraw()
	self:DrawHook("ButtonDraw")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("ButtonTextLayout")
end

aahh.RegisterPanel(PANEL)