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

function menu.RenderBackground(dt)		
	emitter:Update(dt)
	
	render.SetBlendMode2("src_color", "src_color", "add")
	surface.SetWhiteTexture()
	surface.SetColor(background)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	render.SetBlendMode("alpha")
		
	emitter:Draw()
end

local skin = gui.GetRegisteredSkin("zsnes")
local S = skin.Scale
local skin = skin.skin

function menu.CreateTopBar()
	local padding = 5 * S

	local bar = gui.CreatePanel("base", gui.world, "main_menu_bar") 
	bar:SetSkin(skin)
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetSize(Vec2(window.GetSize().w, 15*S))
	bar:SetCachedRendering(true)
	
	bar:MoveLeft()
	bar:MoveUp()
	
	bar:SetPadding(Rect()+S*4)
	
	menu.panel = bar

	local function create_button(text, options)
		local button = gui.CreatePanel("text_button", bar)
		button:SetSizeToTextOnLayout(true)
		button:SetText(text)
		button:SetMargin(Rect(S*3, S*3, S*3, S*2+1))
		button:SetPadding(Rect()+S*4)
		button:SetMode("toggle")
		button:SetupLayout("left", "center_y_simple")
		
		button.OnPress = function()
			local menu = gui.CreateMenu(options, bar)
			menu:SetSkin(skin)
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
			frame:SetSkin(skin)

			frame:SetPosition(Vec2(100, 100))
			frame:SetSize(Vec2(500, 400))
			frame:SetTitle("load lua")
		
			local label = gui.CreatePanel("text", frame)
			label:SetPadding(Rect()+10)
			label:SetText("filename")
			label:SetupLayout("left", "top")
					
			local label = gui.CreatePanel("text", frame)
			label:SetPadding(Rect()+10)
			label:SetText("directory")
			label:SetupLayout("right", "top")
			
			local folders = gui.CreatePanel("list", frame)
			folders:SetPadding(Rect()+10)
			folders:SetSize(Vec2(160, 225))
			folders:SetupLayout("right", "top")
			
					
			local files = gui.CreatePanel("list", frame)
			files:SetPadding(Rect()+10)
			files:SetSize(Vec2(300, 225))
			files:SetupLayout("left", "top", "fill_x")
						
			local label = gui.CreatePanel("text", frame)
			label:SetPadding(Rect(10,2,10,2))
			label:SetText("D:\\")
			label:SetupLayout("no_collide", "bottom", "collide", "left", "top")
			
			local edit = gui.CreatePanel("text_edit", frame)
			edit:SetPadding(Rect(30,2,10,2))
			edit:SetHeight(20)
			edit:SetupLayout("no_collide", "bottom", "collide", "left", "top", "fill_x")
			edit.label:SetPosition(Vec2()+4)
			
			local name_label = gui.CreatePanel("text", frame)
			name_label:SetPadding(Rect(10,5,10,5))
			name_label:SetText("nil")
			name_label:SetupLayout("no_collide", "bottom", "collide", "left", "top")
			
			do
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetPadding(Rect(15,1,15,1))
				label:SetMargin(Rect()+5)
				label:SetText("long filename")
				label:SetupLayout("no_collide", "bottom", "collide", "left", "top")
				label:SizeToText()
				local other = label
				
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetPadding(Rect(15,1,15,1))
				label:SetMargin(Rect()+5)
				label:SetText("snes header name")
				label:SetupLayout("no_collide", "bottom", "collide", "left", "top")
				label:SizeToText()
				label:TieCheckbox(other)
			end
			
			local populate
			
			local all_extensions = gui.CreatePanel("checkbox_label", frame)
			all_extensions:SetPadding(Rect(15,2,15,1))
			all_extensions:SetMargin(Rect()+5)
			all_extensions:SetText("show all extensions")
			all_extensions:SetupLayout("no_collide", "bottom", "collide", "left")
			all_extensions:SizeToText()
			all_extensions.OnCheck = function()
				populate(current_dir)
			end
			
			do
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetCollisionGroup("load_area")
				label:SetPadding(Rect(25,2,5,5))
				label:SetMargin(Rect()+5)
				label:SetText("hirom")
				label:SetupLayout("bottom", "right")
				label:SizeToText()
				
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetCollisionGroup("load_area")
				label:SetPadding(Rect(25,2,5,2))
				label:SetMargin(Rect()+5)
				label:SetText("lorom")
				label:SetupLayout("right", "bottom")
				label:SizeToText()
				
				local button = gui.CreatePanel("text_button", frame)
				button:SetCollisionGroup("load_area")
				button:SetText("load")
				button:SetPadding(Rect(25,3,5,3))
				button:SetMargin(Rect()+6)
				button:SizeToText()
				button:SetWidth(90)
				button:SetupLayout("right", "bottom")
				
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetCollisionGroup("load_area")
				label:SetPadding(Rect(5,3,5,3))
				label:SetMargin(Rect()+5)
				label:SetText("pal")
				label:SetupLayout("no_collide", "bottom", "collide", "right")
				label:SizeToText()
				
				local label = gui.CreatePanel("checkbox_label", frame)
				label:SetCollisionGroup("load_area")
				label:SetPadding(Rect(5,2,5,1))
				label:SetMargin(Rect()+5)
				label:SetText("ntsc")
				label:SetupLayout("no_collide", "bottom", "collide", "right")
				label:SizeToText()
			end
			
			populate = function(dir)
				current_dir = dir
				files:SetupSorted("name")
				folders:SetupSorted("name")
				
				if utility.GetParentFolder(dir):find("/", nil, true) then
					folders:AddEntry("..").OnSelect = function()
						populate(utility.GetParentFolder(dir))
					end
				end
				
				for name in vfs.Iterate(dir) do 
					if name ~= "." and name ~= ".." then
						if not name:find("%.") then
							folders:AddEntry(name).OnSelect = function()
								populate(dir .. name .. "/")
							end
						elseif all_extensions:IsChecked() or name:find(".lua", nil, true) then
							files:AddEntry(name).OnSelect = function()
								name_label:SetText(name)
								--tester.Begin(name)
								--	include(dir .. name)
								--tester.End()
								--frame:Remove()
							end
						else
							--function files:OnPress()

							--end
						end
					end
				end
			end
			
			populate("lua/gui/") 
		end},
		{L"run [ESC]", function() menu.Close() end},
		{L"reset", function() console.RunString("restart") end},
		{},
		{L"save state"},
		{L"open state"},
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
		{L"connect", function()
			gui.StringInput("Enter the server IP", cookies.Get("lastip", "localhost"), function(str)
				console.RunString("start_client")
				cookies.Set("lastip", str)
				console.RunString("connect "..str .." 1234")
				menu.Close()
			end)
		end},
		{L"disconnect", function() console.RunString("disconnect menu disconnect") end},
		{L"host", function() 
			system.StartLuaInstance("start_server", "host")
			
			event.Delay(0.25, function()
				console.RunString("connect localhost 1234")
			end) 
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
	
	bar:Layout(true)
	bar:SizeToWidth()
end
 
event.AddListener("RenderContextInitialized", menu.Open)

if RELOAD then 
	menu.Remake() 
end