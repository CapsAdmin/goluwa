editor = _G.editor or {}

editor.frame = editor.frame or NULL
editor.tree = editor.tree or NULL
editor.properties = editor.properties or NULL
editor.selected_ent = editor.selected_ent or NULL

local icons = {
	copy = "textures/silkicons/page_white_text.png",
	uniqueid = "textures/silkicons/vcard.png",
	paste = "textures/silkicons/paste_plain.png",
	clone = "textures/silkicons/page_copy.png",
	new = "textures/silkicons/add.png",
	autoload = "textures/silkicons/transmit_go.png",
	url = "textures/silkicons/server_go.png",
	outfit = "textures/silkicons/group.png",
	clear = "textures/silkicons/cross.png",
	language = "textures/silkicons/user_comment.png",
	font = "textures/silkicons/text_smallcaps.png",
	load = "textures/silkicons/folder.png",
	save = "textures/silkicons/disk.png",
	exit = "textures/silkicons/cancel.png",
	wear = "textures/silkicons/transmit.png",
	help = "textures/silkicons/information.png",
	edit = "textures/silkicons/table_edit.png",
	revert = "textures/silkicons/table_delete.png",
	about = "textures/silkicons/star.png",
	appearance = "textures/silkicons/paintcan.png",
	orientation = "textures/silkicons/shape_handles.png",

	text = "textures/silkicons/text_align_center.png",
	bone = "widgets/bone_small.png",
	clip = "textures/silkicons/cut.png",
	light = "textures/silkicons/lightbulb.png",
	sprite = "textures/silkicons/layers.png",
	bone = "textures/silkicons/connect.png",
	effect = "textures/silkicons/wand.png",
	model = "textures/silkicons/shape_square.png",
	animation = "textures/silkicons/eye.png",
	holdtype = "textures/silkicons/user_edit.png",
	entity = "textures/silkicons/brick.png",
	group = "textures/silkicons/world.png",
	trail = "textures/silkicons/arrow_undo.png",
	event = "textures/silkicons/clock.png",
	sunbeams = "textures/silkicons/weather_sun.png",
	jiggle = "textures/silkicons/chart_line.png",
	sound = "textures/silkicons/sound.png",
	command = "textures/silkicons/application_xp_terminal.png",
	material = "textures/silkicons/paintcan.png",
	proxy = "textures/silkicons/calculator.png",
	particles = "textures/silkicons/water.png",
	woohoo = "textures/silkicons/webcam_delete.png",
	halo = "textures/silkicons/shading.png",
	poseparameter = "textures/silkicons/disconnect.png",
	fog = "textures/silkicons/weather_clouds.png",
		physics = "textures/silkicons/shape_handles.png",
		beam = "textures/silkicons/vector.png",
	projectile = "textures/silkicons/bomb.png",
	shake = "textures/silkicons/transmit.png",
	ogg = "textures/silkicons/music.png",
	webaudio = "textures/silkicons/sound_add.png",
	script = "textures/silkicons/page_white_gear.png",
	info = "textures/silkicons/help.png",
	bodygroup = "textures/silkicons/user.png",
	camera = "textures/silkicons/camera.png",
	custom_animation = "textures/silkicons/film.png",
}

function editor.Open()
	gui2.RemovePanel(editor.frame)
	
	local frame = gui2.CreatePanel("frame")
	frame:SetSize(Vec2(300, gui2.world:GetHeight()))
	frame:SetTitle("editor")
	editor.frame = frame
	
	local div = gui2.CreatePanel("divider", frame)
	div:Dock("fill")
	div:SetHideDivider(true)
	
	local scroll = div:SetTop(gui2.CreatePanel("scroll"))
	
	local tree
	
	local function show_tooltip(node, entered, x, y)
		local ent = node.ent
		
		if entered then
			local tooltip = gui2.CreatePanel("text_button")
			tooltip:SetPosition(Vec2(surface.GetMousePosition()))
			tooltip:SetMargin(Rect()+4)
			tooltip:SetText(ent:GetDebugTrace())
			tooltip:SizeToText()
			tooltip:Layout(true)
			node.tooltip = tooltip
		else
			gui2.RemovePanel(node.tooltip)
		end
	end
		
	local function right_click_node(node)
		if node then tree:SelectNode(node) end
		
		local options = {}
		
		local function add(...)
			table.insert(options, {...})
		end
		
		--add("wear", nil, icons.wear)
		
		if node then
			add("copy", function()
				system.SetClipboard(serializer.Encode("luadata", node.ent:GetStorableTable()))
			end, icons.copy)
			add("paste", function()
				node.ent:SetStorableTable(serializer.Decode("luadata", system.GetClipboard()))
			end, icons.paste)
			add("clone", function()
				local ent = entities.CreateEntity(node.ent.config)
				ent:SetParent(node.ent:GetParent())
				ent:SetStorableTable(node.ent:GetStorableTable())
			end, icons.clone)
		end
		
		add()
		
		for k,v in pairs(prototype.component_configurations) do
			add(k, function() local ent = entities.CreateEntity(k, node.ent) ent:SetPosition(render.GetCameraPosition()) end, v.icon)
		end		
	
		add()
		--add("help", nil, icons.help)
		add("save", nil, icons.save)
		add("load", nil, icons.load)
		
		if node then
			add()
			add("remove", function() 
				local node = tree:GetSelectedNode()
				if node:IsValid() and node.ent:IsValid() then
					node.ent:Remove()
				end
			end, icons.clear)
		end
		
		gui2.CreateMenu(options, frame)
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
			--node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
			fill(ent:GetChildren(), node)
		end  
	end
	
	local function repopulate()
		if not frame:IsValid() then return end
		
		gui2.RemovePanel(tree)
		
		tree = gui2.CreatePanel("tree")
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
	tree:SetWidth(frame:GetWidth())
	
	frame.OnRightClick = function() right_click_node() end
	
	local scroll = div:SetBottom(gui2.CreatePanel("scroll"))
	
	local properties
	
	tree.OnNodeSelect = function(_, node)
		gui2.RemovePanel(properties)
		
		properties = gui2.CreatePanel("properties")
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
	
	div:SetDividerPosition(gui2.world:GetHeight()/2) 
	
	if editor.selected_ent:IsValid() then
		editor.SelectEntity(editor.selected_ent)
	elseif tree:GetChildren()[1] then 
		tree:SelectNode(tree:GetChildren()[1])
	end
		
	window.SetMouseTrapped(false) 
end

function editor.Close()
	gui2.RemovePanel(editor.frame)
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