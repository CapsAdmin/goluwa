local S = gui.skin.scale
local skin = include("libraries/gui/skins/zsnes.lua")

if false then -- frame
	local frame = gui.CreatePanel("frame")
	frame:SetPosition(Vec2()+200)
	frame:SetSize(Vec2()+500)

	local tab = gui.CreatePanel("tab", frame)
	tab:SetupLayout("fill_x", "fill_y")

	do
		local content = tab:AddTab("tree")
		
		local scroll = gui.CreatePanel("scroll", content)
		local tree = gui.CreatePanel("tree") 
		scroll:SetPanel(tree)
		tree:SetupLayout("fill_x", "fill_y")
		scroll:SetupLayout("fill_x", "fill_y")
		
		local data = serializer.ReadFile("luadata", R"data/tree.txt") or {}
		local done = {}
		 
		local function fill(tbl, node)		
			for key, val in pairs(tbl) do
				local node = node:AddNode(val.self.Name)
				node:SetIcon(Texture("textures/" .. node:GetSkin().icons[val.self.ClassName]))
				fill(val.children, node)
			end  
		end 
		
		fill(data, tree)
	end
	
	do
		local content = tab:AddTab("list")
		local list = gui.CreatePanel("list", content)
		list:SetupSorted("name", "date modified", "type", "size")
		list:SetupLayout("fill_x", "fill_y")
		
		for k,v in pairs(vfs.Find("lua/")) do
			local file = vfs.Open("lua/"..v)
			
			list:AddEntry(v, os.date("%m/%d/%Y %H:%M", vfs.GetLastModified("lua/"..v) or 0), vfs.IsFile("lua/"..v) and "file" or "folder", file and utility.FormatFileSize(file:GetSize()) or "0")
		end
	end

	do
		local content = tab:AddTab("dividers")
		local div = gui.CreatePanel("divider", content)
		div:SetupLayout("fill_x", "fill_y")
		div:SetDividerPosition(400)

		local huh = div:SetLeft(gui.CreatePanel("button"))
		
		local div = div:SetRight(gui.CreatePanel("divider"))
	end
	
	do		
		local content = tab:AddTab("sliders")
		
		content:SetStack(true)
		content:SetStackRight(false)
		--content:SetClipping(true)
		--content:SetScrollable(true)
				
		local slider = gui.CreatePanel("slider", content)
		slider:SetXSlide(true)
		slider:SetYSlide(false)
		slider:SetSize(Vec2(256, 35))
		--slider:SetPosition(Vec2(8, 8))
		
		local slider = gui.CreatePanel("slider", content)
		slider:SetXSlide(true)
		slider:SetYSlide(false)
		slider:SetRightFill(false)
		slider:SetSize(Vec2(256, 35))
		--slider:SetPosition(Vec2(8, 8))
	end
	
	do
		local content = tab:AddTab("text")
		
		local text = gui.CreatePanel("text_edit", content)
		text:SetSize(Vec2(128, 128))
		text:SetText("huh")
		text:SetupLayout("fill_x", "fill_y")
	end	
end
	
do -- menu bar
	local padding = 5 * S

	local bar = gui.CreatePanel("base", gui.world, "top_bar") 
	bar:SetSkin(skin)
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetSize(Vec2(700, 15*S))
	bar:SetupLayout("left", "top")

	local function create_button(text, options)
		local button = gui.CreatePanel("text_button", bar)
		button:SetText(text)
		button:SetMargin(Rect()+S*3)
		button:SetPadding(Rect()+S*3)
		button:SizeToText()
		button:SetMode("toggle")
		button:SetupLayout("left")
		
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
		{"freeze data: off"},
		{"clear all data"},
	}) 
	create_button("game", {
		{"load", function() 
			local frame = gui.CreatePanel("frame") 

			frame:SetPosition(Vec2(100, 100))
			frame:SetSize(Vec2(300, 300))
			frame:SetTitle("file browser")
			
			local panel = gui.CreatePanel("list", frame)
			panel:SetupLayout("fill_x", "fill_y")

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
			gui.StringInput("Enter the server IP", cookies.Get("lastip", "localhost"), function(str)
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

local emitter = ParticleEmitter(800)
emitter:SetPosition(Vec3(50,50,0)) 
--emitter:SetMoveResolution(0.25) 
emitter:SetAdditive(false)

local fb
local DX = false

if DX then
	fb = render.CreateFrameBuffer(128, 128)
end

local background = ColorBytes(64, 44, 128, 200)

event.AddListener("Draw2D", "zsnow", function(dt)
	if DX then
		fb:Begin()
			surface.SetColor(0,0,0,0.01)
			surface.DrawRect(0,0,128,128)
			
			surface.PushMatrix()
				for i = -4, 4 do
					i = (i / 4) * math.pi
					
					surface.PushMatrix(math.sin(i)/2, math.cos(i)/2)
						render.Translate(-0.4, -0.4, 0)
						surface.SetColor(1,1,1,1)
						surface.SetTexture(fb:GetTexture())
						surface.DrawRect(0,0,128,128)
					surface.PopMatrix()
				end
			surface.PopMatrix()
			
			render.SetBlendMode("additive")
			emitter:Update(dt)
			emitter:Draw()
			render.SetBlendMode("alpha")
		fb:End()
	else
		emitter:Update(dt)
	end
		
	surface.SetWhiteTexture()
	surface.SetColor(DX and Color(0,0,0,1) or background)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	
	--surface.SetColor(1,1,1,1)
	--emitter:Draw()
	
	--surface.SetColor(0,0,0,0.25)
	--surface.DrawRect(5*S,5*S, x, 16 * S)
	
	
	--surface.SetFont("snow_font")
	--surface.SetTextPosition(50, 50)
	--surface.DrawText("ANIMATION 2")
	--local w,h = surface.GetTextSize("ANIMATION 2")
	--surface.DrawRect(50,50,w,h)
	
	if DX then
		render.SetBlendMode("additive")
		surface.SetColor(1,1,1,1)
		surface.SetTexture(fb:GetTexture())
		surface.DrawRect(0,0,render.GetWidth(), render.GetHeight())
		render.SetBlendMode("alpha")
	else
		emitter:Draw()
	end
end, {priority = math.huge}) 

event.CreateTimer("zsnow", 0.01, function()
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
	
	if DX then
		p:SetColor(HSVToColor(os.clock()/30,0.75, 1))
	else
		p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
	end
end) 

menu.Close()
window.SetMouseTrapped(false) 

