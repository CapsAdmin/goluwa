local editor

console.AddCommand("editor", function()
	gui2.RemovePanel(editor)
	
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(300, gui2.world:GetHeight()))
	editor = frame
	
	local div = gui2.CreatePanel("divider", frame)
	div:Dock("fill")
	div:SetHideDivider(true)
	
	local scroll = div:SetTop(gui2.CreatePanel("scroll"))
	local tree = gui2.CreatePanel("tree")
	scroll:SetPanel(tree)
	
	local function fill(entities, node)
		for key, ent in pairs(entities) do
			local node = node:AddNode(ent.config, ent:GetPropertyIcon())
			node.ent = ent
			--node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
			fill(ent:GetChildren(), node)
		end  
	end
	
	event.AddListener("EntityCreate", "asdf", function(ent)
		gui2.RemovePanel(tree)
		
		tree = gui2.CreatePanel("tree")
		scroll:SetPanel(tree)
		
		fill(entities.GetAll(), tree)
		tree:SetSize(tree:GetSizeOfChildren())
		tree:SetWidth(frame:GetWidth())
	end)
	
	event.AddListener("EntityRemove", "asdf", function(ent)
		gui2.RemovePanel(tree)
		
		tree = div:SetTop(gui2.CreatePanel("tree"))
		
		fill(entities.GetAll(), tree)
		tree:SetSize(tree:GetSizeOfChildren())
		tree:SetWidth(frame:GetWidth())
	end)
	
	fill(entities.GetAll(), tree)
	tree:SetSize(tree:GetSizeOfChildren())
	tree:SetWidth(frame:GetWidth())
	
	local scroll = div:SetBottom(gui2.CreatePanel("scroll"))
	
	local properties
	
	tree.OnNodeSelect = function(_, node)
		gui2.RemovePanel(properties)
		
		properties = gui2.CreatePanel("properties")
		--properties:SetStretchToPanelWidth(frame)
		
		for k, v in pairs(node.ent:GetComponents()) do
			for k,v in pairs(v) do
				properties:AddGroup(v.ClassName)
				properties:AddPropertiesFromObject(v)
			end
		end
		
		scroll:SetPanel(properties)
	end
	
	div:SetDividerPosition(gui2.world:GetHeight()/2) 
	
	tree:SelectNode(tree:GetChildren()[1])  
end)