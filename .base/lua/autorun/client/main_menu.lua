surface.CreateFont("impact", {path = "Rosario", size = 20})

menu = menu or {}

menu.panel = menu.panel or NULL

do -- open close  
	function menu.Open()
		if menu.visible then return end
		window.SetMouseTrapped(false) 
		menu.CreateTopBar()
		event.AddListener("PreDrawMenu", "StartupMenu", menu.RenderBackground)
		event.CreateTimer("StartupMenu", 0.1, menu.UpdateBackground)
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
	emitter:SetPosition(Vec3(math.random((DX and 256 or render.GetWidth()) + 100) - 150, -50, 0))
		
	local p = emitter:AddParticle()
	p:SetDrag(1)

	--p:SetStartLength(Vec2(0))
	--p:SetEndLength(Vec2(30, 0))
	p:SetAngle(math.random(360)) 
	 
	p:SetVelocity(Vec3(math.random(100),math.random(40, 80)*2,0) * (DX and 0.25 or 1))

	p:SetLifeTime(20)

	p:SetStartSize(2 * (1 + math.random() ^ 50))
	p:SetEndSize(2 * (1 + math.random() ^ 50))

	p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
end

local background = ColorBytes(64, 44, 128, 200)

function menu.RenderBackground(dt)		
	emitter:Update(dt)
	
	surface.SetWhiteTexture()
	surface.SetColor(DX and Color(0,0,0,1) or background)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
		
	emitter:Draw()
end

local skin = include("gui2/skins/zsnes.lua")

function menu.CreateTopBar()
	local S = skin.scale
	local padding = 5 * S

	local bar = gui2.CreatePanel("base", gui2.world, "main_menu_bar") 
	bar:SetSkin(skin)
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetSize(Vec2(700, 15*S))
	bar:SetupLayoutChain("left", "top")
	
	menu.panel = bar

	local function create_button(text, options)
		local button = gui2.CreatePanel("text_button", bar)
		button:SetText(text)
		button:SetMargin(Rect()+S*3)
		button:SetPadding(Rect()+S*3)
		button:SizeToText()
		button:SetMode("toggle")
		button:SetupLayoutChain("left")
		
		button.OnPress = function()
			local menu = gui2.CreateMenu(options, bar)
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
		{"freeze data: off"},
		{"clear all data"},
	}) 
	create_button("game", {
		{"load", function() 
			local frame = gui2.CreatePanel("frame") 

			frame:SetPosition(Vec2(100, 100))
			frame:SetSize(Vec2(300, 300))
			frame:SetTitle("file browser")
			
			local panel = gui2.CreatePanel("list", frame)
			panel:SetupLayoutChain("fill_x", "fill_y")

			local function populate(dir)
				panel:SetupSorted("name")
				frame:SetTitle(dir)
				
				if utility.GetParentFolder(dir):find("/", nil, true) then
					panel:AddEntry("<<").OnSelect = function()
						populate(utility.GetParentFolder(dir))
					end
				end
				
				for name in vfs.Iterate(dir) do 
					if name ~= "." and name ~= ".." then
						if name:find(".lua", nil, true) then
							panel:AddEntry(name).OnSelect = function()
								tester.Begin(name)
									include(dir .. name)
								tester.End()
								frame:Remove()
							end
						elseif not name:find("%.") then
							panel:AddEntry(name).OnSelect = function()
								populate(dir .. name .. "/")
							end
						else
							function btn:OnPress()

							end
						end
					end
				end
			end
			
			populate("lua/tests/") 
		end},
		{"run  [ESC]", function() debug.trace() end},
		{"reset"},
		{},
		{"save state"},
		{"open state"},
		{"pick state"},
		{},
		{"quit", function() os.exit() end} 
	})
	create_button("config", {
		{"input"},
		{},
		{"devices"},
		{"chip cfg"},
		{},
		{"options"},
		{"video"},
		{"sound"},
		{"paths"},
		{"saves"},
		{"speed"},
	})
	create_button("cheat", {
		{"add code"},
		{"browse"},
		{"search"},
	})
	create_button("netplay", {
		{"connect", function()
			gui2.StringInput("Enter the server IP", cookies.Get("lastip", "localhost"), function(str)
				console.RunString("start_client")
				cookies.Set("lastip", str)
				console.RunString("connect "..str .." 1234")
				menu.Close()
			end)
		end},
		{"disconnect", function() console.RunString("disconnect menu disconnect") end},
		{"host", function() 
			system.StartLuaInstance("start_server", "host")
			
			event.Delay(0.25, function()
				console.RunString("connect localhost 1234")
			end) 
		end},
	})
	create_button("misc", {
		{"misc keys"},
		{"gui opts"},
		{"key comb."},
		{"save cfg"},
		{},
		{"about"},
	})
end
 
event.AddListener("RenderContextInitialized", menu.Open)

if RELOAD then 
	menu.Remake() 
end