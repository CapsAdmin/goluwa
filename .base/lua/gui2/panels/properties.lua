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
	local divider = gui2.CreatePanel("divider", group)
	divider:Dock("fill")
	group.divider = divider
	
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
 
function PANEL:AddProperty(key, default, callback)
	callback = callback or print
	
	local t = type(default)
	
	if not self.current_group then
		self:AddGroup()
	end 
	       
	local left = gui2.CreatePanel("text_button", self.current_group.left) 
	left:SetText(key)   
	left:SizeToText()
	
	local right
	
	if t == "boolean" then
		right = gui2.CreatePanel("button", self.current_group.right)
		right:SetHeight(S*10)
		right:SetMode("toggle")
		right:SetState(default)
		right.OnStateChanged = function(_, b) callback(b) end
	else		
		right = gui2.CreatePanel("text_button", self.current_group.right)
		if t == "string" then
			right:SetText(default)
		else
			right:SetText(serializer.Encode("luadata", default))
		end
		right:SizeToText()
		
		right.OnPress = function()
			if self.current_edit:IsValid() then
				self.current_edit:OnEnter()
			end
			
			local edit = gui2.CreatePanel("text_edit", right)
			edit:Dock("fill")
			edit:SetTextColor(Color(0, 1, 0))
			edit:SetText(right:GetText())
			edit:SizeToText()
			edit.OnEnter = function()  
				local str = edit:GetText()
				local val
				
				if t == "string" then
					val = str
				else
					val = serializer.Decode("luadata", str)[1]
					
					if type(val) ~= t then
						val = default
					end

					str = serializer.Encode("luadata", val)
				end
				
				right:SetText(str) 
				edit:Remove()
				callback(val)
				self.current_edit = NULL
			end
			
			edit:RequestFocus()
			edit.right = right
			self.current_edit = edit
		end
	end
	
	left:SetHeight(S*10)
	right:SetHeight(S*10) 
	
	self.left_max_width = math.max((self.left_max_width or 0), left:GetWidth())
	self.right_max_width = math.max((self.right_max_width or 0), right:GetWidth())
	
	self:Layout()
end

function PANEL:OnLayout()
	for i, group in ipairs(self:GetChildren()) do			
		group:SetHeight(group.left:GetSizeOfChildren().h + S*10)
		group:SetWidth(self.left_max_width + self.right_max_width) 
		group.divider:SetWidth(self.left_max_width + self.right_max_width) 
		group.divider:SetDividerPosition(self.left_max_width) 
	end
end

function PANEL:AddPropertiesFromObject(obj)
	for k, v in pairs(getmetatable(obj) or obj) do
		if type(v) == "function" and k:sub(0, 3) == "Get" then
			local field = k:sub(4)
			
			local get = v 
			local set = obj["Set" .. field]
			local def = get(obj)
			
			if get and set and obj[field] then
				self:AddProperty(field:gsub("%u", " %1"):lower():sub(2), def, function(val)
					if not obj:IsValid() then return end
					
					set(obj, val)
				end)
			end
		end
	end
end

gui2.RegisterPanel(PANEL) 
 
if RELOAD then
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(300, gui2.world:GetHeight()))
	
	local div = gui2.CreatePanel("divider", frame)
	div:Dock("fill")
	
	local tree = div:SetTop(gui2.CreatePanel("tree"))
	
	local function fill(entities, node)
		for key, ent in ipairs(entities) do
			local node = node:AddNode(ent.config)
			node.ent = ent
			--node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
			fill(ent:GetChildren(), node)
		end  
	end 
	
	fill(entities.GetAll(), tree)
		
	local scroll = div:SetBottom(gui2.CreatePanel("scroll"))
	
	local properties
	
	tree.OnNodeSelect = function(_, node)
		gui2.RemovePanel(properties)
		
		properties = gui2.CreatePanel("properties")
		
		for k, v in pairs(node.ent:GetComponents()) do
			for k,v in pairs(v) do
				properties:AddGroup(v.ClassName)
				properties:AddPropertiesFromObject(v)
			end
		end
		
		scroll:SetPanel(properties)
	end
end  