local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "collapsible_category"

function PANEL:Initialize()	
	self:SetMargin(Rect(0,10*S,0,0))  
	self:SetStyle("frame")
	
	local bar = gui2.CreatePanel("button", self)
	bar:SetObeyMargin(false)
	bar:Dock("fill_top") 
	bar:SetSendMouseInputToParent(true)
	bar:SetHeight(10*S)
	bar:SetSimpleTexture(true)
	bar:SetClipping(true) 
	bar:SetMode("toggle")
	
	bar.OnStateChanged = function(_, pressed)
		if pressed then
			self.last_height = self.last_height or self:GetHeight()
			self:SetHeight(10*S)
		else		
			self:SetHeight(self.last_height)
			self.last_height = nil 
		end
		if self:HasParent() then
			self:GetParent():Layout()
		end
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
	title:SetNoDraw(true)
	self.title = title
end

gui2.RegisterPanel(PANEL)

if RELOAD then
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(200, 400))
	
	local scroll = gui2.CreatePanel("scroll", frame)
	scroll:Dock("fill")
	
	local list = gui2.CreatePanel("base")
	list:SetStack(true)
	list:SetStackRight(false) 
	list:SetNoDraw(true)  
	
	scroll:SetPanel(list)
	
	local a = gui2.CreatePanel(PANEL.ClassName, list)
	a:SetSize(Vec2(100,100))
	local b = gui2.CreatePanel(PANEL.ClassName, list)
	b:SetSize(Vec2(100,100)) 
	 
	list:SetSize(Vec2(100, 500))   
end  