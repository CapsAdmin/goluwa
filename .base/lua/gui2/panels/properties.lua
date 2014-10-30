local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "properties"

PANEL.current_edit = NULL

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
	       
	local label = gui2.CreatePanel("text_button", self.current_group.left) 
	label:SetTextColor(ColorBytes(200, 200, 200))
	label:SetFont("snow_font") 
	label:SetText(key)   
	label:SetHeight(16) 
	
	local value = gui2.CreatePanel("text_button", self.current_group.right)
	value:SetTextColor(ColorBytes(200, 200, 200))
	value:SetFont("snow_font")
	value:SetText("woo")
	value:SetHeight(16)
	
	value.OnPress = function()
		if self.current_edit:IsValid() then
			local edit = self.current_edit
			local value = edit.value
			value:SetText(edit:GetText()) 
			edit:Remove() 
		end
		local edit = gui2.CreatePanel("text_edit", value)
		edit:Dock("fill")
		edit:SetTextColor(ColorBytes(0, 255, 0))
		edit:SetFont("snow_font")
		edit:SetHeight(16)
		edit:SetText(value:GetText())
		edit.OnEnter = function()  
			value:SetText(edit:GetText()) 
			edit:Remove()
		end
		edit:RequestFocus()
		edit.value = value
		self.current_edit = edit
	end
	 
	self.current_group.left:Layout(true)
	   
	self.current_group:SetHeight(self.current_group.left:GetSizeOfChildren().h + 16)
end

gui2.RegisterPanel(PANEL) 
 
if RELOAD then
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(300, 300))
	 
	local properties = gui2.CreatePanel("properties", frame)
	properties:Dock("fill")
	properties:AddGroup("orientation")
	properties:AddProperty("bone")
	properties:AddProperty("position")
	properties:AddProperty("angles")
	properties:AddProperty("eye angles") 
	properties:AddProperty("size")
	properties:AddProperty("scale")  
end  