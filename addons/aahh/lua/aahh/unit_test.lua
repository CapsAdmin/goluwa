console.AddCommand("aahh_unit_test", function()

	if not aahh.initialized then return end

	local frame = utilities.RemoveOldObject(aahh.Create("frame"), "aahh_unit_test")
	frame:SetSize(Vec2() + 300)
	frame:Center()
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

		local tab, pnl = tabs:AddTab("tree", "tree")
			
		local data = luadata.ReadFile(R("well.txt"))
		local done = {}
		 
		local function fill(tbl, node)		
			for key, val in pairs(tbl.children) do
				local node = node:AddNode(val.self.Name)
				node:SetIcon(Image(icons[val.self.ClassName]))
				fill(val, node)
			end  
			
		end 
			 
		for key, val in pairs(data) do
			local node = pnl:AddNode(val.self.Name)
			node:SetIcon(Image(icons[val.self.ClassName]))
			fill(val, node)
		end

		pnl:Stack()
	end

	do -- uh

		local tab, grid = tabs:AddTab("properties", "grid")

		grid:SetDrawBackground(false)
		grid:Dock("fill")
		grid:SetSpacing(Vec2() + 5)
		grid:SetSizeToWidth(true)
		grid:SetStackRight(false)
		grid:SetItemSize(Vec2()+20)
				
		local slider = aahh.Create("labeled_slider", grid)
		slider:SetValue(10)
		
		local knob = aahh.Create("labeled_knob", grid)
		knob:SetValue(10)
		
		local check = aahh.Create("labeled_checkbox", grid)
		check:SetText("ummmmm")
		check:SetValue(true)
		
		local text = aahh.Create("textinput", grid)
			
	end
		do return end

	do -- text
		local tab, grid = tabs:AddTab("text input", "textinput2")
		
	end

	tabs:SelectTab("properties")
	frame:RequestLayout(true)
	
	debug.logcalls(true)
end)

