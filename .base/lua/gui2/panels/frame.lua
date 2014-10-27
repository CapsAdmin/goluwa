local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}
PANEL.ClassName = "frame"

function PANEL:Initialize()	
	self:SetDraggable(true)
	self:SetResizable(true) 
	self:SetBringToFrontOnClick(true)
	self:SetCachedRendering(true)
	
	self:SetMargin(Rect(0,10*S,0,0))  
	self:SetStyle("frame")
		
	local bar = gui2.CreatePanel("base", self)
	bar:SetObeyMargin(false)
	bar:Dock("fill_top") 
	bar:SetSendMouseInputToParent(true)
	bar:SetHeight(10*S)
	bar:SetSimpleTexture(true)
	bar:SetStyle("gradient")
	bar:SetColor(ColorBytes(120, 120, 160))
	bar:SetClipping(true)
					
	local close = gui2.CreatePanel("text_button", bar)
	close:SetFont("snow_font_noshadow")  
	close:SetTextColor(ColorBytes(50,50,50))
	close:SetText("X")
	close:SizeToText()
	close:SetStyle("button_rounded_inactive")
	close:SetStyleTranslation("button_active", "button_rounded_active")
	close:SetStyleTranslation("button_inactive", "button_rounded_inactive")
	
	close:Dock("right") 
	
	 --close:SetStyle("button_rounded")
	
	close.OnPress = function() 
		self:Remove()
	end

	self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
	
	self.frame = self
	self.bar = bar
	
	self:SetTitle("no title")
end

function PANEL:SetTitle(str)
	gui2.RemovePanel(self.title)
	local title = gui2.CreatePanel("text", self.bar)
	title:SetHeight(self.bar:GetHeight())
	title:SetFont("snow_font")  
	title:SetTextColor(ColorBytes(200, 200, 200))
	title:SetText(str)
	title:SetPosition(Vec2(2*S,0))
	title:CenterY()
	title:SetColor(Color(0,0,0,0))
	self.title = title
end

function PANEL:OnMouseInput()
	self:MarkCacheDirty()
end

gui2.RegisterPanel(PANEL)  