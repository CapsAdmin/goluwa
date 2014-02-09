local canvas = utilities.RemoveOldObject(aahh.Create("canvas"))
canvas:SetSize(Vec2(512, 512))
canvas:Center()     
   
	local frame = aahh.Create("frame", canvas)
	frame:Center() 
	frame:SetSize(Vec2() + 300)
	frame:SetTitle("unit test")     
	
	local tabs = frame:CreatePanel("tabbed")
	tabs:Dock("fill")
   	
	do -- tree test
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

		local tab, scroll = tabs:AddTab("tree", "scrollable")
		local tree = scroll:CreatePanel("tree")
		LOL = scroll
		tree:Dock("fill")
		
		local data = luadata.ReadFile(R("well.txt"))
		local done = {}
		 
		local function fill(tbl, node)		
			for key, val in pairs(tbl.children) do
				local node = node:AddNode(val.self.Name)
				node:SetIcon(Image("textures/" .. icons[val.self.ClassName]))
				fill(val, node)
			end  
			
		end 
			 
		for key, val in pairs(data) do
			local node = tree:AddNode(val.self.Name)
			node:SetIcon(Image("textures/" .. icons[val.self.ClassName]))
			fill(val, node)
		end

		tree:Stack()
	end

	do -- uh

		local tab, grid = tabs:AddTab("properties", "grid")

		grid:SetDrawBackground(false)
		grid:Dock("fill")
		grid:SetSpacing(Vec2() + 5)
		grid:SetSizeToWidth(true)
		grid:SetStackRight(false)
		grid:SetItemSize(Vec2()+20)
		 
		local text = aahh.Create("text_input", grid)

		local slider = aahh.Create("labeled_slider", grid)
		slider:SetValue(10)
		
		
		
		local container = aahh.Create("container", grid)
			container:SetHeight(100)

			local grid = aahh.Create("grid", container)
			
			grid:SetDrawBackground(false)
			grid:Dock("fill")
			grid:SetSpacing(Vec2() + 5)
			grid:SetSizeToWidth(true)
			grid:SetStackRight(false)
			grid:SetItemSize(Vec2()+20)
			grid:SetSizeToContent(true)
			grid:SetObeyMargin(false)
		
			local knob = aahh.Create("labeled_knob", grid)
			knob:SetValue(10)
			
			local check = aahh.Create("labeled_checkbox", grid)
			check:SetText("ummmmm")
			check:SetValue(true)
		
	end

	do -- text
		local tab, grid = tabs:AddTab("text input", "text_input")
		grid:SetMultiLine(true)
		grid:SetLineNumbers(true)
	end

	tabs:SelectTab("properties")
	frame:RequestLayout(true)

      