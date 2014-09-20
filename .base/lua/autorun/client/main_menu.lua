surface.CreateFont("impact", {path = "Rosario", size = 20})

menu = menu or {}
menu.buttons = menu.buttons or {}

do -- open close  
	function menu.Open()
		if menu.visible then return end
		window.SetMouseTrapped(false) 
		menu.MakeButtons()
		event.AddListener("PreDrawMenu", "StartupMenu", menu.RenderBackground)
		menu.visible = true
	end

	function menu.Close()
		if not menu.visible then return end
		window.SetMouseTrapped(true) 
		for k,v in ipairs(menu.buttons)do
			if type(v) == "table" and v.Remove then 
				v:Remove() 
			end
		end
		menu.buttons = {}
		event.RemoveListener("PreDrawMenu", "StartupMenu")
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

	function menu.FadeIn()
		local i = 1 
		event.AddListener("PostDrawMenu", "StartupMenu", function(dt)
			i = i - (i*1.5) * dt * 5
			surface.SetColor(0,0,0,i)
			surface.DrawRect(0,0,surface.GetScreenSize())
			if i < 0 then
				return HOOK_DESTROY
			end
		end)
	end
	
	event.AddListener("Disconnected", "main_menu", menu.Open)
end

function menu.RenderBackground()	
	local scrw, scrh = render.GetScreenSize():Unpack()
	
	local alpha = 0.75

	local steps = 8			-- Amount of detail
	local wavelength = 30		-- Distance between dark and light
	local speed =  0.2 			-- Speed
	local amplitude = 0.6 		-- Difference between light and dark
	local median = 0.8			-- Lightness (Min: 0 Max: 1) [WARNING: median + amplitude should be between 0 and 1]
	
	local x, y = window.GetMousePos():Unpack()
	local t = ((x / -scrw) * 2) + 1

	local r, g, b = gui.GetSkinColor("dark"):Unpack()
	
	y =  -(y / scrh) + 2
	r = r * y
	g = g * y 
	b = b * y
	
	surface.SetWhiteTexture()
	
	for i=0, steps-1 do
		local fract = i/steps
		local f = math.sin(fract*100/wavelength+t)*amplitude+median
		surface.SetColor(r*f, g*f, b*f, alpha)
		surface.DrawRect(scrw*fract, 0, scrw/steps, scrh)
	end
end

function menu.MakeButtons()
	for key, pnl in pairs(menu.buttons) do
		if typex(v) == "panel" then 
			pnl:Remove()
		end
	end

	menu.buttons = {}
	
	if CLIENT and network.IsConnected() then
		menu.AddButton("Resume", function() event.Delay(0.1, function() menu.Close() end) end)
		menu.AddButtonSpace()
	end


	if not SERVER then
		menu.AddButton("Connect", function()
			gui.StringInput("Enter the server IP", cookies.Get("lastip", "localhost"), function(str)
				console.RunString("start_client")
				cookies.Set("lastip", str)
				console.RunString("connect "..str .." 1234")
				menu.Close()
			end)
		end)
		
		if CLIENT and network.IsConnected() then
			menu.AddButton("Disconnect", function()
				console.RunString("disconnect menu disconnect")
				menu.Remake()
			end)
		else
			menu.AddButton("Host", function()
				system.StartLuaInstance("start_server", "host")
				menu.Remake()
				
				event.Delay(0.25, function()
					console.RunString("connect localhost 1234")
				end)
				menu.Close()
			end)
		end
	end
		 
	menu.AddButtonSpace()

	menu.AddButton("Tests", function()

		local frame = gui.Create("frame")
		frame:SetTitle("test")
		frame:SetSize(Vec2(512, 512))
		frame:Center()
		
		local scroll = gui.Create("scrollable", frame)
		scroll:Dock("fill")
	
		local grid = gui.Create("grid")
		grid:SetSizeToWidth(true)	
		grid:SetStackRight(false)
		grid:SetItemSize(Vec2()+25)
		
		local function populate(dir)
			frame:SetTitle(dir)
			
			if utility.GetParentFolder(dir):find("/", nil, true) then
				local btn = gui.Create("text_button")
					btn:SetText("<<")
					
					function btn:OnPress()
						grid:RemoveChildren()
						populate(utility.GetParentFolder(dir))
					end
					
				grid:AddChild(btn)
			end
			
			for name in vfs.Iterate(dir) do 
				if name ~= "." and name ~= ".." then
					local btn = gui.Create("text_button")
					btn:SetText(name)

					if name:find(".lua", nil, true) then
						function btn:OnPress()
							tester.Begin(name)
								include(dir .. name)
							tester.End()
							frame:Remove()
						end
					elseif not name:find("%.") then
						function btn:OnPress()
							grid:RemoveChildren()
							populate(dir .. name .. "/")
						end
					else
						function btn:OnPress()

						end
					end	
					
					grid:AddChild(btn)  
				end
			end
		end
		
		populate("lua/tests/") 
				
		grid:SizeToContents()
		grid:SetWidth(500)
		
		scroll:SetPanel(grid)
	end)
	
	menu.AddButtonSpace() 
 
	menu.AddButton("Exit", function() os.exit() end)
	
	-- the world has to be setup..hmm
	event.AddListener("WorldPanelLayout", "menu_resize", menu.SetupButtons)
end
 
function menu.AddButton(name, func)

	local pnl = gui.Create("label")
		pnl:SetSkinColor("text", "light")
		pnl:SetSkinColor("shadow", Color(0,0,0,0.1)) 
		pnl:SetFont("impact")
		pnl:SetText(name)
		pnl:SetCursor("hand")
		
		--pnl:SetShadowDir(Vec2())
		--pnl:SetShadowSize(18)
		
		pnl:SetIgnoreMouse(false)
		pnl:SetSize(Vec2(100, 18))	
		function pnl:OnMouseInput(key, press)
			if key == "button_1" and press then
				func()
			end
		end
	
	menu.buttons[#menu.buttons+1] = pnl
end 

function menu.AddButtonSpace()
	menu.buttons[#menu.buttons+1] = true
end

function menu.SetupButtons()
	local sw, sh = render.GetScreenSize():Unpack()
			
	local margin = 50
	local x = sw/2
	local y = sh/1.5
	
	for i=1, #menu.buttons do
		local b = menu.buttons[#menu.buttons-i+1]

		if b == true then
			y = y - (margin / 2)
		else
			b:RequestLayout(true)
			b:SetPos(Vec2(x - b:GetWidth() / 2, y-b:GetHeight() * 2)) 
			y = y - (margin / 1.25)
		end
	end
	
end
 
event.AddListener("RenderContextInitialized", menu.Open)

if not network.IsStarted() then
	menu.FadeIn()
end

if RELOAD then 
	menu.Remake() 
end