window.Open(1280, 720)
	
if not aahh.initialized then return end

local frame = utilities.RemoveOldObject(aahh.Create("frame"), "aahh_unit_test") 
frame:SetSize(Vec2() + 500)
frame:Center()
frame:SetTitle("unit test")



local tabs = frame:CreatePanel("tab_bar")
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
	--if false then
	local tree = aahh.Create("tree")
	scroll:SetPanel(tree)

	--tree:Dock("fill")
	  
	local data = luadata.ReadFile(R("well.txt"))
	local done = {}
	 
	local function fill(tbl, node)		
		for key, val in pairs(tbl.children) do
			local node = node:AddNode(val.self.Name)
			node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
			fill(val, node)
		end  
		
	end 
		 
	for key, val in pairs(data) do
		local node = tree:AddNode(val.self.Name)
		node:SetIcon(Texture("textures/" .. icons[val.self.ClassName]))
		fill(val, node)
	end
	--end
end

do -- uh

	local tab, grid = tabs:AddTab("properties", "grid")

	grid:SetDrawBackground(false)
	grid:Dock("fill")
	grid:SetSpacing(Vec2() + 5)
	grid:SetSizeToWidth(true)
	grid:SetStackRight(false)
	grid:SetItemSize(Vec2()+20)
	
	LOL = grid
	
	local text = aahh.Create("text_input", grid)

	local slider = aahh.Create("labeled_slider", grid)
	slider:SetValue(10)
	
	local container = aahh.Create("container", grid)
	
		local grid = aahh.Create("grid", container)
		
		grid:SetDrawBackground(false)
		grid:Dock("fill")
		grid:SetSpacing(Vec2() + 5)
		grid:SetSizeToWidth(true)
		grid:SetStackRight(false)
		grid:SetItemSize(Vec2()+20)
		grid:SetObeyMargin(false)
	
		local knob = aahh.Create("labeled_knob", grid)
		knob:SetValue(10)
		
		local check = aahh.Create("labeled_checkbox", grid)
		check:SetText("ummmmm")
		check:SetValue(true)
		
	container:SizeToContents()
	grid:SizeToContents()
		
end

do -- text
	local tab, grid = tabs:AddTab("text input", "text_input")
	grid:SetMultiLine(true)
	grid:SetLineNumbers(true)
end

tabs:SelectTab("tree")
frame:RequestLayout(true)