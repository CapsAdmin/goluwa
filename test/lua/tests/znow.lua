local S = gui2.skin.scale

do -- testing
	local frame = gui2.CreatePanel("frame")
	frame:SetPosition(Vec2()+200)
	frame:SetSize(Vec2()+500)

	local tab = gui2.CreatePanel("tab", frame)
	tab:SetupLayoutChain("fill_x", "fill_y")

	do
		local content = tab:AddTab("tree")
		
		local icons =
		{
			text = "silkicons/text_align_center.png",
			bone = "silkicons/wrench.png",
			clip = "silkicons/cut.png",
			light = "silkicons/lightbulb.png",
			sprite = "silkicons/layers.png",
			bone = "silkicons/connect.png",
			effect = "silkicons/wand.png",
			model = "silkicons/shape_square.png",
			animation = "silkicons/eye.png",
			entity = "silkicons/brick.png",
			group = "silkicons/world.png",
			trail = "silkicons/arrow_undo.png",
			event = "silkicons/clock.png",
			sunbeams = "silkicons/weather_sun.png",
			jiggle = "silkicons/chart_line.png",
			sound = "silkicons/sound.png",
			command = "silkicons/application_xp_terminal.png",
			material = "silkicons/paintcan.png",
			proxy = "silkicons/calculator.png",
			particles = "silkicons/water.png",
			woohoo = "silkicons/webcam_delete.png",
			halo = "silkicons/shading.png",
			poseparameter = "silkicons/vector.png",
		}

		local scroll = gui2.CreatePanel("scroll", content)
		local tree = gui2.CreatePanel("tree") 
		scroll:SetPanel(tree)
		tree:SetupLayoutChain("fill_x", "fill_y")
		scroll:SetupLayoutChain("fill_x", "fill_y")
		
		local data = serializer.ReadFile("luadata", R"data/tree.txt") or {}
		local done = {}
		 
		local function fill(tbl, node)		
			for key, val in pairs(tbl) do
				local node = node:AddNode(val.self.Name)
				node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
				fill(val.children, node)
			end  
		end 
		
		fill(data, tree)
	end
	
	do
		local content = tab:AddTab("list")
		local list = gui2.CreatePanel("list", content)
		list:SetupSorted("name", "date modified", "type", "size")
		list:SetupLayoutChain("fill_x", "fill_y")
		
		for k,v in pairs(vfs.Find("lua/")) do
			local file = vfs.Open("lua/"..v)
			
			list:AddEntry(v, os.date("%m/%d/%Y %H:%M", vfs.GetLastModified("lua/"..v) or 0), vfs.IsFile("lua/"..v) and "file" or "folder", file and utility.FormatFileSize(file:GetSize()) or "0")
		end
	end

	do
		local content = tab:AddTab("dividers")
		local div = gui2.CreatePanel("divider", content)
		div:SetupLayoutChain("fill_x", "fill_y")
		div:SetDividerPosition(400)

		local huh = div:SetLeft(gui2.CreatePanel("button"))
		
		local div = div:SetRight(gui2.CreatePanel("divider"))
	end
	
	do		
		local content = tab:AddTab("sliders")
		
		content:SetStack(true)
		content:SetStackRight(false)
		--content:SetClipping(true)
		--content:SetScrollable(true)
				
		local slider = gui2.CreatePanel("slider", content)
		slider:SetXSlide(true)
		slider:SetYSlide(false)
		slider:SetSize(Vec2(256, 35))
		--slider:SetPosition(Vec2(8, 8))
		
		local slider = gui2.CreatePanel("slider", content)
		slider:SetXSlide(true)
		slider:SetYSlide(false)
		slider:SetRightFill(false)
		slider:SetSize(Vec2(256, 35))
		--slider:SetPosition(Vec2(8, 8))
	end
	
	do
		local content = tab:AddTab("text")
		
		local text = gui2.CreatePanel("text_edit", content)
		text:SetSize(Vec2(128, 128))
		text:SetText("huh")
		text:SetupLayoutChain("fill_x", "fill_y")
	end		 
		   
	local padding = 5 * S

	local bar = gui2.CreatePanel("base") 
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetPadding(Rect(1,1,5*S,3*S))
	bar:SetSize(Vec2(500, 15*S))

	local function create_button(text, options)
		local button = gui2.CreatePanel("text_button", bar)
		button:SetClipping(true)
		button:SetText(text)
		button:SetMargin(Rect()+2.5*S)
		button:SizeToText()
		button:SetMode("toggle")
		button:SetupLayoutChain("left")
		
		button.OnStateChanged = function(_, b, ...)
			if b then return end
			local menu = gui2.CreateMenu(options)
			
			--menu:SetPosition(button:GetWorldPosition() + Vec2(0, button:GetHeight() + 2*S), options)
		--	menu:Animate("DrawScaleOffset", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)
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
			for k,v in pairs(vfs.Find("/")) do
				panel:AddEntry(v)
			end
		end},
		{"run  [ESC]", function() debug.trace() end},
		{"reset", {
			{"video"},
			{"sound"},
			{"paths"},
			{"huh", {
				{"misc keys"},
				{"gui opts"},
				{"key comb."},
				{"save cfg"},
				{},
				{"about"},
			}},
			{"saves"},
			{"speed"},
		}},
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
		{"internet"},
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
	surface.SetColor(DX and Color(0,0,0,1) or gui2.skin.background)
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

