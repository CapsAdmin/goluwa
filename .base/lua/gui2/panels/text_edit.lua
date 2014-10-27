local gui2 = ... or _G.gui2
local PANEL = {}

PANEL.ClassName = "text_edit"

prototype.GetSetDelegate(PANEL, "Text", "", "label")
prototype.GetSetDelegate(PANEL, "ParseTags", false, "label")
prototype.GetSetDelegate(PANEL, "Font", "default", "label")
prototype.GetSetDelegate(PANEL, "TextColor", Color(1,1,1), "label")
prototype.GetSetDelegate(PANEL, "TextWrap", false, "label")

prototype.Delegate(PANEL, "label", "CenterText", "Center")
prototype.Delegate(PANEL, "label", "CenterTextY", "CenterY")
prototype.Delegate(PANEL, "label", "CenterTextX", "CenterX")
prototype.Delegate(PANEL, "label", "GetTextSize", "GetSize")

function PANEL:Initialize()	
	self:SetColor(Color(0,0,0,1))
	self.BaseClass.Initialize(self)
	
	local label = gui2.CreatePanel("text")
	label:SetTextColor(Color(0,1,0,1))
	label:SetFont("snow_font")
	label:SetEditable(true)
	label:SetClipping(true)
	self.label = label
	
	local scroll = gui2.CreatePanel("scroll", self)
	scroll:SetPanel(label)
	scroll:Dock("fill")
	self.scroll = scroll
end

function PANEL:SizeToText()
	local marg = self:GetMargin()
		
	self.label:SetPosition(marg:GetPosition())
	self:SetSize(self.label:GetSize() + marg:GetSize()*2)
end

function PANEL:OnKeyInput(...)
	self.label:OnKeyInput(...)
end

function PANEL:OnCharInput(...)
	self.label:OnCharInput(...)
end

function PANEL:OnMouseInput()
	--self:SizeToText() 
end
	
gui2.RegisterPanel(PANEL)