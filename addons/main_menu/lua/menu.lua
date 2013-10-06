input.Bind("escape", "toggle_menu")

console.AddCommand("toggle_menu", function()
	menu.Toggle()
end)

menu = menu or {}

menu.visible = false

if menu.Toggle then
	menu.Toggle()
	menu.Toggle()
end 

function menu.RenderBackground()	

	window.ShowCursor(true)
	local scrw, scrh = render.GetScreenSize()
	
	local alpha = 1
	
	if CLIENT and entities.GetLocalPlayer():IsValid() then 
		alpha = 0.75
	end	

	local steps = 8			-- Amount of detail
	local wavelength = 30		-- Distance between dark and light
	local speed =  0.2 			-- Speed
	local amplitude = 0.6 		-- Difference between light and dark
	local median = 0.8			-- Lightness (Min: 0 Max: 1) [WARNING: median + amplitude should be between 0 and 1]
	
	local x, y = window.GetMousePos():Unpack()
	local t = ((x / -scrw) * 2) + 1

	local r, g, b = aahh.GetSkinColor("dark"):Unpack()
	
	y =  -(y / scrh) + 2
	r = r * y
	g = g * y 
	b = b * y
	
	for i=0, steps-1 do
		local fract = i/steps
		local f = math.sin(fract*100/wavelength+t)*amplitude+median
		surface.Color(r*f, g*f, b*f, alpha)
		surface.DrawRect(scrw*fract, 0, scrw/steps, scrh)
	end
end

function menu.FadeIn()
	local i = 1 
	event.AddListener("PostDrawMenu", "StartupMenu", function()
		i = i - (i*1.5) * FT * 5
		surface.Color(0,0,0,i)
		surface.DraRect(0,0,surface.GetScreenSize())
		if i < 0 then
			return HOOK_DESTROY
		end
	end)
end

function menu.Toggle()
	if menu.visible then
		menu.Close()
	else
		menu.Open()
	end
end

function menu.Open()
	if menu.visible then return end
	window.ShowCursor(true)
	menu.MakeButtons()
	event.AddListener("PreDrawMenu", "StartupMenu", menu.RenderBackground)
	menu.visible = true
end

function menu.Close()
	if not menu.visible then return end
	window.ShowCursor(false)
	for k,v in ipairs(menu.buttons)do
		if type(v) == "table" and v.Remove then 
			v:Remove() 
		end
	end
	menu.buttons = {}
	event.RemoveListener("PreDrawMenu", "StartupMenu")
	menu.visible = false
end

function menu.Remake()
	menu.Toggle()
	menu.Toggle()
end

menu.buttons = {}

function menu.AddButton(name, func)

	local pnl = aahh.Create("label")
		pnl:SetSkinColor("text", "light")
		pnl:SetSkinColor("shadow", Color(0,0,0,0.1)) 
		pnl:SetFont("impact.ttf")
		pnl:SetText(name)
		pnl:SetCursor(e.IDC_HAND)
		
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
	local sw, sh = render.GetScreenSize()
	
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

function menu.MakeButtons()
	for key, pnl in pairs(menu.buttons) do
		if typex(v) == "panel" then 
			pnl:Remove()
		end
	end

	menu.buttons = {}
	
	if CLIENT and players.GetLocalPlayer():IsValid() then
		menu.AddButton("Resume", function() timer.Simple(0.1, function() menu.Close() end) end)
		menu.AddButtonSpace()
	end

	menu.AddButton("Connect", function()
		aahh.StringInput("Enter the server IP", cookies.Get("lastip", "localhost"), function(str)
			cookies.Set("lastip", str)
			console.RunString("connect "..str .." 64090")
		end)
	end)
	if CLIENT and players.GetLocalPlayer():IsValid() then
		menu.AddButton("Disconnect", function()
			console.RunString("disconnect")
		end)
	end
	 
	menu.AddButtonSpace()
	
	menu.AddButton("Mount", function() 
		aahh.StringInput("Enter the game content folder and restart your game", "E:\\steam\\steamapps\\common\\crysis 2\\gamecrysis2", function(str)
			MountGame(str)
		end)
	end)
		
	menu.AddButton("Tests", function()

		local frame = aahh.Create("frame")
		frame:SetTitle("test")
		frame:SetSize(Vec2(512, 512))
		frame:Center()
		
		local grid = aahh.Create("grid", frame)
		grid:Dock("fill")
		grid:SetSizeToWidth(true)
		grid:SetStackRight(false)
		
		grid:SetItemSize(Vec2()+20)

		local function populate(dir)
			frame:SetTitle(dir)
			
			if utilities.GetParentFolder(dir):find("/", nil, true) then
				local btn = aahh.Create("textbutton")
					btn:SetText("<<")
					
					function btn:OnPress()
						grid:RemoveChildren()
						populate(utilities.GetParentFolder(dir))
					end
					
				grid:AddChild(btn)
			end
			for name in vfs.Iterate(dir, false, true) do
				if name ~= "." and name ~= ".." then
					local btn = aahh.Create("textbutton")
					btn:SetText(name)
					
					if name:find(".lua", nil, true) then
						function btn:OnPress()
							easylua.Start(entities.GetLocalPlayer())
							tester.Begin(name)
								include(dir .. name)
							tester.End()
							easylua.End()
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
			
			--grid:RequestLayout(true)
			--frame:SetHeight(grid:GetCurrentSize().h + 33)
			--frame:RequestLayout(true)
		end
		
		populate("lua/")
	end)
	
	menu.AddButtonSpace() 
 
	menu.AddButton("Console", function() console.RunString("ConsoleShow", true, true) end)
	menu.AddButton("Restart", function() timer.Simple(0.1, function() console.RunString("reoh", true, true) end) end)
	menu.AddButton("Exit", function() os.exit() end)
	
	menu.SetupButtons()
end 

window.Open(1024, 760)
menu.Close()
menu.Open()

event.AddListener("OnWindowResized", "aahh_world", function(window, w,h)
	menu.Close()
	menu.Open()
end)
 