local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "properties"

function PANEL:Initialize()
	self:SetStack(true)
	self:SetStackRight(false) 
	self:SetSizeStackToWidth(true)  
	self:SetNoDraw(true)    
end

function PANEL:AddGroup(name)
	local group = gui2.CreatePanel("collapsible_category", self)
	group:SetTitle(name)
	local divider = gui2.CreatePanel("horizontal_divider", group)
	divider:Dock("fill")
	
	local left = divider:SetLeft(gui2.CreatePanel("base"))
	left:SetStack(true)
	left:SetStackRight(false)
	left:SetSizeStackToWidth(true)
	left:Dock("fill")
	left:SetNoDraw(true)
	group.left = left
	
	local right = divider:SetRight(gui2.CreatePanel("base"))
	right:SetStack(true)
	right:SetStackRight(false)
	right:SetSizeStackToWidth(true)
	right:Dock("fill")
	right:SetNoDraw(true)
	group.right = right
	
	self.current_group = group
end

function PANEL:AddProperty(key, val)
	if not self.current_group then
		self:AddGroup()
	end
	
	local label = gui2.CreatePanel("text", self.current_group.left) 
	label:SetFont("snow_font")
	label:SetText(key)
	label:SetHeight(16)
	
	local hmm = gui2.CreatePanel("text_edit", self.current_group.right)
	hmm:SetText("woo")
	hmm:SetHeight(16)
	
	self.current_group:SetHeight(100)
end

gui2.RegisterPanel(PANEL)

if RELOAD then
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(300, 300))
	
	local properties = gui2.CreatePanel("properties", frame)
	properties:Dock("fill") 
	properties:AddProperty("test")
	properties:AddProperty("awddaw")
	properties:AddProperty("1234")
	properties:AddProperty("q2523tgwe")
	properties:AddProperty("asda")
end 