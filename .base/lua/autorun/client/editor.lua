editor = _G.editor or {}

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL

function editor.Open()
	gui.RemovePanel(editor.frame)
	
	local frame = gui.CreatePanel("frame")
	frame:SetWidth(300)
	frame:SetTitle("editor")
	frame:SetupLayoutChain("left", "fill_y")
	editor.frame = frame
	
	local div = gui.CreatePanel("divider", frame)
	div:SetupLayoutChain("fill_x", "fill_y")
	div:SetHideDivider(true)
	
	local scroll = div:SetTop(gui.CreatePanel("scroll"))
	
	local tree
	
	local function show_tooltip(node, entered, x, y)
		local ent = node.ent
		
		if entered then
			local tooltip = gui.CreatePanel("text_button")
			tooltip:SetPosition(Vec2(surface.GetMousePosition()))
			tooltip:SetMargin(Rect()+4)
			tooltip:SetText(ent:GetDebugTrace())
			tooltip:SizeToText()
			tooltip:Layout(true)
			node.tooltip = tooltip
		else
			gui.RemovePanel(node.tooltip)
		end
	end
		
	local function right_click_node(node)
		if node then tree:SelectNode(node) end
		
		local options = {}
		
		local function add(...)
			table.insert(options, {...})
		end
		
		--add("wear", nil, node:GetSkin().icons.wear)
		
		if node then
			add("copy", function()
				system.SetClipboard(assert(serializer.Encode("luadata", node.ent:GetStorableTable())))
			end, node:GetSkin().icons.copy)
			add("paste", function()
				node.ent:SetStorableTable(assert(serializer.Decode("luadata", system.GetClipboard())))
			end, node:GetSkin().icons.paste)
			add("clone", function()
				local ent = entities.CreateEntity(node.ent.config)
				ent:SetParent(node.ent:GetParent())
				ent:SetStorableTable(node.ent:GetStorableTable())
			end, node:GetSkin().icons.clone)
			
			if node.ent:HasComponent("transform") then
				add("goto", function()
					render.SetCameraPosition(node.ent:GetPosition())
				end, "textures/silkicons/brick_go.png")
			end
		end
		
		add()
		
		for k,v in pairs(prototype.component_configurations) do
			add(k, function() local ent = entities.CreateEntity(k, node.ent) ent:SetPosition(render.GetCameraPosition()) end, v.icon)
		end		
	
		add()
		--add("help", nil, node:GetSkin().icons.help)
		add("save", nil, node:GetSkin().icons.save)
		add("load", nil, node:GetSkin().icons.load)
		
		if node then
			add()
			add("remove", function() 
				local node = tree:GetSelectedNode()
				if node:IsValid() and node.ent:IsValid() then
					node.ent:Remove()
				end
			end, node:GetSkin().icons.clear)
		end
		
		gui.CreateMenu(options, frame)
	end
	
	local function fill(entities, node)
		for key, ent in pairs(entities) do
			local name = ent:GetName()
			if name == "" then
				name = ent.config
			end
			local node = node:AddNode(name, ent:GetPropertyIcon())
			node.OnRightClick = right_click_node
			node.OnMouseHoverTrigger = show_tooltip
			node.ent = ent
			--node:SetIcon(Texture("textures/" .. node:GetSkin().icons[val.self.ClassName]))
			fill(ent:GetChildren(), node)
		end  
	end
	
	local function repopulate()
		if not frame:IsValid() then return end
		
		gui.RemovePanel(tree)
		
		tree = gui.CreatePanel("tree")
		scroll:SetPanel(tree)
		
		local ents = {}
		for k,v in pairs(entities.GetAll()) do if not v:HasParent() then table.insert(ents, v) end end
		fill(ents, tree)
		tree:SetSize(tree:GetSizeOfChildren())
		tree:SetWidth(frame:GetWidth())
		
		scroll:SetAlwaysReceiveMouseInput(true)
		
		editor.tree = tree
	end
	
	event.AddListener("EntityCreate", "editor", repopulate)
	event.AddListener("EntityRemoved", "editor", repopulate)	
	repopulate()
	
	tree:SetSize(tree:GetSizeOfChildren())
	tree:SetWidth(frame:GetWidth()-20)
	
	frame.OnRightClick = function() right_click_node() end
	
	local scroll = div:SetBottom(gui.CreatePanel("scroll"))
	
	local properties
	
	tree.OnNodeSelect = function(_, node)
		gui.RemovePanel(properties)
		
		properties = gui.CreatePanel("properties")
		--properties:SetStretchToPanelWidth(frame)
		
		for k, v in pairs(node.ent:GetComponents()) do
			properties:AddGroup(v.ClassName)
			properties:AddPropertiesFromObject(v)
		end
		
		scroll:SetPanel(properties)
		
		editor.properties = properties
		
		event.Call("EditorSelectEentity", node.ent)
		editor.selected_ent = node.ent
	end
	
	div:SetDividerPosition(gui.world:GetHeight()/2) 
	
	if editor.selected_ent:IsValid() then
		editor.SelectEntity(editor.selected_ent)
	elseif tree:GetChildren()[1] then 
		tree:SelectNode(tree:GetChildren()[1])
	end
		
	window.SetMouseTrapped(false) 
end

function editor.Close()
	gui.RemovePanel(editor.frame)
	window.SetMouseTrapped(false) 
end

function editor.Toggle()
	if editor.frame:IsValid() then
		if editor.frame:IsMinimized() then
			editor.frame:Minimize(false)
			window.SetMouseTrapped(true)
		else
			editor.frame:Minimize(true)
			window.SetMouseTrapped(false) 
		end
	else
		editor.Open()
	end
end

function editor.SelectEntity(ent)
	editor.selected_ent = ent

	if not editor.frame:IsValid() then return end
	
	for i, v in ipairs(editor.tree:GetChildren()) do
		if v.ent == ent then
			editor.tree:SelectNode(v)
			return v
		end
	end
end

input.Bind("e+left_control", "toggle_editor")

console.AddCommand("close_editor", editor.Close)
console.AddCommand("toggle_editor", editor.Toggle)
console.AddCommand("open_editor", editor.Open)