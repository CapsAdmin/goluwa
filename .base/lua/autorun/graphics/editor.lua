editor = _G.editor or {}

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL

function editor.Open()
	gui.RemovePanel(editor.frame)
	
	local frame = gui.CreatePanel("frame")
	frame:SetWidth(300)
	frame:SetTitle(L"editor")
	frame:SetupLayout("left", "fill_y")
	editor.frame = frame
	
	local div = gui.CreatePanel("divider", frame)
	div:SetupLayout("fill_x", "fill_y")
	div:SetHideDivider(true)
	
	editor.top_scroll = div:SetTop(gui.CreatePanel("scroll"))
	editor.bottom_scroll = div:SetBottom(gui.CreatePanel("scroll"))
	
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
		
		--add("wear", nil, frame:GetSkin().icons.wear)
		
		if node then
			add(L"copy", function()
				system.SetClipboard(assert(serializer.Encode("luadata", node.ent:GetStorableTable())))
			end, frame:GetSkin().icons.copy)
			add(L"paste", function()
				node.ent:SetStorableTable(assert(serializer.Decode("luadata", system.GetClipboard())))
			end, frame:GetSkin().icons.paste)
			add(L"clone", function()
				local ent = entities.CreateEntity(node.ent.config)
				ent:SetParent(node.ent:GetParent())
				ent:SetStorableTable(node.ent:GetStorableTable())
			end, frame:GetSkin().icons.clone)
			
			if node.ent:HasComponent("transform") then
				add(L"goto", function()
					render.SetCameraPosition(node.ent:GetPosition())
				end, "textures/silkicons/brick_go.png")
			end
		end
		
		add()
		
		
		local groups = {}
		
		for config_name, info in pairs(prototype.GetConfigurations()) do
			local group
			
			local meta = #info.components == 1 and prototype.GetRegistered("component", info.components[1])
			
			if meta and meta.Base then		
				groups[meta.Base] = groups[meta.Base] or {configs = {}}
				groups[meta.Base].configs[config_name] = info
			else			
				groups.default = groups.default or {configs = {}}
				groups.default.configs[config_name] = info
			end
		end
				
		for group_name, group in pairs(groups) do
			local tbl = {}
			for config_name, info in pairs(group.configs) do		
				table.insert(tbl, {L(info.name), function() 
					local ent = entities.CreateEntity(config_name, node and node.ent) 
					if ent.SetPosition then 
						ent:SetPosition(render.GetCameraPosition())
					end
				end, info.icon})				
			end
			add(L(group_name), tbl, group.icon) -- FIX ME
		end
	
		add()
		--add("help", nil, frame:GetSkin().icons.help)
		add(L"save", nil, frame:GetSkin().icons.save)
		add(L"load", nil, frame:GetSkin().icons.load)
		
		if node then
			add()
			add(L"remove", function() 
				local node = tree:GetSelectedNode()
				if node:IsValid() and node.ent:IsValid() then
					node.ent:Remove()
				end
			end, frame:GetSkin().icons.clear)
		end
		
		gui.CreateMenu(options, frame)
	end
	
	local function fill(entities, node)
		for key, ent in pairs(entities) do
			if not ent:GetHideFromEditor() then
				local name = ent:GetName()
				if name == "" then
					name = ent.config
				end
				local node = node:AddNode(name, ent:GetPropertyIcon())
				node.OnRightClick = right_click_node
				--node.OnMouseHoverTrigger = show_tooltip
				node.ent = ent
				ent.editor_node = node
				--node:SetIcon(Texture("textures/" .. frame:GetSkin().icons[val.self.ClassName]))
				fill(ent:GetChildren(), node)
			end
		end  
	end
	
	local function repopulate()
		if not frame:IsValid() then return end
				
		gui.RemovePanel(tree)
		
		tree = gui.CreatePanel("tree")
		editor.top_scroll:SetPanel(tree)
		
		local ents = {}
		for k,v in pairs(entities.GetAll()) do
			if not v:HasParent() then 
				table.insert(ents, v) 
			end 
		end
		fill(ents, tree)
		tree:SetSize(tree:GetSizeOfChildren())
		tree:SetWidth(frame:GetWidth())
		
		editor.top_scroll:SetAlwaysReceiveMouseInput(true)
		
		tree.OnNodeSelect = function(_, node)
			gui.RemovePanel(editor.properties)
			
			local properties = gui.CreatePanel("properties")
			
			local found_anything = false
			
			for k, v in pairs(node.ent:GetComponents()) do
				if next(prototype.GetStorableVariables(v)) then
					properties:AddGroup(L(v.ClassName))
					properties:AddPropertiesFromObject(v)
					found_anything = true
				end
			end
			
			editor.bottom_scroll:SetPanel(properties)
			
			editor.properties = properties
			
			event.Call("EditorSelectEentity", node.ent)
			editor.selected_ent = node.ent
		end
		
		editor.tree = tree
	end
	
	--editor.top_scroll.OnRightClick = function() right_click_node() end
	
	event.AddListener("EntityCreate", "editor", function() event.Delay(0.1, repopulate) end)
	event.AddListener("EntityRemoved", "editor", repopulate)	
	repopulate()
	
	tree:SetSize(tree:GetSizeOfChildren())
	tree:SetWidth(frame:GetWidth()-20)
	
	frame.OnRightClick = function() right_click_node() end
	
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