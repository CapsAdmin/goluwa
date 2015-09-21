menu = menu or {}

menu.panel = menu.panel or NULL

do -- open close  
	function menu.Open()
		if menu.visible then return end
		window.SetMouseTrapped(false) 
		menu.CreateTopBar()
		event.AddListener("PreDrawMenu", "StartupMenu", menu.RenderBackground)
		event.CreateTimer("StartupMenu", 0.025, menu.UpdateBackground)
		menu.visible = true
	end

	function menu.Close()
		if not menu.visible then return end
		window.SetMouseTrapped(true) 
		event.RemoveListener("PreDrawMenu", "StartupMenu")
		event.RemoveTimer("StartupMenu")
		prototype.SafeRemove(menu.panel)
		menu.visible = false
	end
	
	function menu.IsVisible()
		return menu.visible
	end

	function menu.Toggle()
		if menu.visible then
			menu.Close()
		else
			menu.Open()
		end
	end

	function menu.Remake()
		menu.Toggle()
		menu.Toggle()
	end

	input.Bind("escape", "toggle_menu")

	console.AddCommand("toggle_menu", function()
		menu.Toggle()
	end)
	
	event.AddListener("Disconnected", "main_menu", menu.Open)
end

local emitter = ParticleEmitter(800)
emitter:SetPosition(Vec3(50,50,0)) 
--emitter:SetMoveResolution(0.25) 
emitter:SetAdditive(false)

function menu.UpdateBackground()
	emitter:SetScreenRect(Rect(-100, -100, render.GetScreenSize():Unpack()))
	emitter:SetPosition(Vec3(math.random(render.GetWidth() + 100) - 150, -50, 0))
		
	local p = emitter:AddParticle()
	p:SetDrag(1)

	--p:SetStartLength(Vec2(0))
	--p:SetEndLength(Vec2(30, 0))
	p:SetAngle(math.random(360)) 
	 
	p:SetVelocity(Vec3(math.random(100),math.random(40, 80)*2,0))

	p:SetLifeTime(20)

	p:SetStartSize(2 * (1 + math.random() ^ 50))
	p:SetEndSize(2 * (1 + math.random() ^ 50))

	p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
end

local background = ColorBytes(64, 44, 128, 255)
background = background + Color(0.25, 0.25, 0.20) -- hack fix  because the background is black

function menu.RenderBackground(dt)		
	emitter:Update(dt)
	
	render.SetBlendMode("src_color", "src_color", "add")
	surface.SetWhiteTexture()
	surface.SetColor(background)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	render.SetBlendMode("alpha")
		
	emitter:Draw()
end

function menu.CreateTopBar()
	local skin = gui.GetRegisteredSkin("zsnes").skin
	local S = skin:GetScale()
	
	local bar = gui.CreatePanel("base", gui.world, "main_menu_bar") 
	bar:SetSkin(skin)
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetSize(window.GetSize()*1)
	bar:SetCachedRendering(true)
	bar:SetupLayout("layout_children", "size_to_width", "size_to_height")
	
	function bar:OnPreDraw()
		surface.SetWhiteTexture()
		surface.SetColor(0,0,0,0.25)
		surface.DrawRect(11, 11, self.Size.x, self.Size.y)
	end
	
	menu.panel = bar

	local function create_button(text, options)
		local button = bar:CreatePanel("text_button")
		button:SetSizeToTextOnLayout(true)
		button:SetText(text)
		button:SetMargin(Rect(S*3, S*3, S*3, S*2+1))
		button:SetPadding(Rect(S*4, S*2, S*4, S*2))
		button:SetMode("toggle")
		button:SetupLayout("left", "top")
		
		button.OnPress = function()
			local menu = gui.CreateMenu(options, bar)
			function menu:OnPreDraw()
				surface.SetWhiteTexture()
				surface.SetColor(0,0,0,0.25)
				surface.DrawRect(11, 11, self.Size.x, self.Size.y)
			end
			menu:SetPosition(button:GetWorldPosition() + Vec2(0, button:GetHeight() + 2*S), options)
			menu:Animate("DrawScaleOffset", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)
			menu:SetVisible(true)
			menu:CallOnRemove(function() button:SetState(false) end)
		end
	end

	create_button("↓", {
		{"1."},
		{"2."},
		{"3."},
		{"4."},
		{"5."},
		{"6."},
		{"7."},
		{"8."},
		{"9."},
		{"0."},
		{},
		{L"freeze data: off"},
		{L"clear all data"},
	}) 
	create_button(L"game", {
		{L"load", function() 
			local current_dir
			
			local frame = gui.CreatePanel("frame")
			frame:SetSkin(bar:GetSkin())
			frame:SetPosition(Vec2(100, 100))
			frame:SetSize(Vec2(500, 400))
			frame:SetTitle("load lua")
		
			local list = frame:CreatePanel("list")
			list:SetupLayout("fill")
			
			populate = function(dir)
				list:SetupSorted("name"--[[, "modified", "type", "size"]])
				--list:SetupConverters(nil, function(num) return os.date("%c", num) end, nil, utility.FormatFileSize)
			
				current_dir = dir
				
				if utility.GetParentFolder(dir):find("/", nil, true) then
					list:AddEntry("..", 0, "folder", 0).OnSelect = function()
						populate(utility.GetParentFolder(dir))
					end
				end
				
				for name in vfs.Iterate(dir) do 
					local file = vfs.Open(dir .. name)
					local type = "folder"
					local size = 0
					local last_modified = 0
					
					if file then 
						type = name:match(".+%.(.+)")
						size = file:GetSize()
						last_modified = file:GetLastModified()
					end

					if file then
						file:Close()
					end
				
					if type == "folder" then
						local entry = list:AddEntry(name--[[, last_modified, type, size]])
						
						entry.OnSelect = function()
							populate(dir .. name .. "/")
						end
						
						entry:SetIcon("textures/silkicons/folder.png")
					else
						local entry = list:AddEntry(name--[[, last_modified, type, size]])
						
						entry.OnSelect = function()
							tester.Begin(name)
								include(dir .. name)
							tester.End()
						end
						
						entry:SetIcon("textures/silkicons/script.png")
					end
				end
			end
			
			populate("lua/tests/") 
		end},
		{L"run [ESC]", function() menu.Close() end},
		{L"reset", function() console.RunString("restart") end},
		{},
		{L"save state", function()
			if _SAVING then return end
			
			local out = {}
			
			out.entities = {}
			out.camera = render.camera_3d:GetStorableTable()
			
			for k,v in pairs(entities.GetAll()) do
				if not v:HasParent() then
					table.insert(out.entities, v:GetStorableTable())
				end
			end
			
			serializer.WriteFile("luadata", "world.lua", out)
		end},
		{L"open state", function()
			_SAVING = true

			local data = serializer.ReadFile("luadata", "world.lua")

			for k,v in pairs(data.entities) do
				if not prototype.GetObjectByGUID(v.self.GUID):IsValid() then
					local ent = entities.CreateEntity(v.config)
					ent:SetStorableTable(v, true)
				end
			end

			render.camera_3d:SetStorableTable(data.camera)
			
			_SAVING = nil
		end},
		{L"pick state"},
		{},
		{L"quit", function() system.ShutDown() end} 
	})
	create_button(L"config", {
		{L"input"},
		{},
		{L"devices"},
		{L"chip cfg"},
		{},
		{L"options"},
		{L"video"},
		{L"sound"},
		{L"paths"},
		{L"saves"},
		{L"speed"},
	})
	create_button(L"cheat", {
		{L"add code"},
		{L"browse"},
		{L"search"},
	})
	create_button(L"netplay", {
		{L"internet", function()
			local frame = gui.CreatePanel("frame")
			--frame:SetSkin(bar:GetSkin())
			frame:SetPosition(Vec2(100, 100))
			frame:SetSize(Vec2(500, 400))
			frame:SetTitle("servers (fetching public servers..)")
			
			local tab = frame:CreatePanel("tab")
			tab:SetupLayout("fill")
						
			local page = tab:AddTab(L"internet")
		
			local list = page:CreatePanel("list")
			list:SetupLayout("fill")
			list:SetupSorted(L"name", L"players", L"map", L"latency")
			list:SetupConverters(nil, function(num) tostring(num) end)
			
			network.JoinIRCServer()
			
			local function add(info)
				frame:SetTitle("server list")
				list:AddEntry(info.name, info.players, info.map, info.latency).OnSelect = function()
					network.Connect(info.ip, info.port)
				end
			end
			
			for ip, info in pairs(network.GetAvailableServers()) do
				add(info)
			end
			
			event.AddListener("PublicServerFound", "server_list", function(info)
				add(info)
			end)
			
			local page = tab:AddTab(L"favorites")
			local list = page:CreatePanel("list")
			list:SetupLayout("fill")
			list:SetupSorted(L"name", L"players", L"map", L"latency")
			
			local page = tab:AddTab(L"history")
			local list = page:CreatePanel("list")
			list:SetupLayout("fill")
			list:SetupSorted(L"name", L"players", L"map", L"latency")
			
			local page = tab:AddTab(L"lan")
			local list = page:CreatePanel("list")
			list:SetupLayout("fill")
			list:SetupSorted(L"name", L"players", L"map", L"latency")
			
			
			tab:SelectTab(L"internet")
		end},
	})
	create_button(L"misc", {
		{L"misc keys"},
		{L"gui opts"},
		{L"key comb."},
		{L"save cfg"},
		{},
		{L"about"},
	})

	
--	bar:SetupLayout("left", "up", "fill_x", "size_to_width")
end
 
menu.Open()

if RELOAD then 
	menu.Remake() 
end