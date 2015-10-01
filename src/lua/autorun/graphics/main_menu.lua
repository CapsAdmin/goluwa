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
			local frame = gui.CreatePanel("frame")
			frame:SetSkin(bar:GetSkin())
			frame:SetSize(Vec2(500, 400))
			frame:CenterSimple()
			frame:SetTitle("load lua")

			local area = frame:CreatePanel("base")
			area:SetupLayout("fill")
			area:SetNoDraw(true)
			area:SetMargin(Rect()+8)


			local divider = area:CreatePanel("divider")
			divider.lol = true
			divider:SetHeight(250)
			divider:SetupLayout("top", "fill_x")
			divider:SetDividerWidth(8)

			local left = divider:SetLeft(gui.CreatePanel("base", divider))
			left:SetNoDraw(true)
			local right = divider:SetRight(gui.CreatePanel("base", divider))
			right:SetNoDraw(true)

			divider.horizontal_divider:SetColor(Color(1,1,1,0)) -- todo

			divider:SetDividerPosition(300)


			local label = left:CreatePanel("text")
			label:SetText("filename")
			label:SetupLayout("top", "left")

			local left_list = left:CreatePanel("list")
			left_list:SetPadding(Rect(0,0,0,10))
			left_list:SetupLayout("fill")
			left_list:SetupSorted("name"--[[, "modified", "type", "size"]])


			local label = right:CreatePanel("text")
			label:SetText("directory")
			label:SetupLayout("top", "left")

			local right_list = right:CreatePanel("list")
			right_list:SetPadding(Rect(0,0,0,10))
			right_list:SetupLayout("fill")
			right_list:SetupSorted("name"--[[, "modified", "type", "size"]])

			local path_label = area:CreatePanel("text")
			path_label:SetPadding(Rect()+2)
			path_label:SetSize(Vec2()+12)
			path_label:SetupLayout("top", "left", "fill_x")

			local text_entry = area:CreatePanel("text_edit")
			text_entry:SetPadding(Rect()+2)
			text_entry:SetSize(Vec2() + 20)
			text_entry:SetupLayout("top", "left", "fill_x")

			local filename_label = area:CreatePanel("text")
			filename_label:SetPadding(Rect()+2)
			filename_label:SetSize(Vec2()+12)
			filename_label:SetupLayout("top", "left")

			local bottom = area:CreatePanel("base")
			bottom:SetSize(Vec2()+20)
			bottom:SetPadding(Rect()+2)
			bottom:SetMargin(Rect(10,0,10,0))
			bottom:SetupLayout("top", "fill")
			bottom:SetNoDraw(true)

			do
				local area = bottom:CreatePanel("base")
				area:SetPadding(Rect()+2)
				area:SetMargin(Rect(10,0,10,0))
				area:SetWidth(100)
				area:SetupLayout("left", "bottom", "fill_y", "size_to_width")
				area:SetNoDraw(true)

				local choice1 = area:CreatePanel("checkbox_label")
				choice1:SetPadding(Rect()+4)
				choice1:SetText("long filename")
				choice1:SizeToText()
				choice1:SetupLayout("top", "left")

				local choice2 = area:CreatePanel("checkbox_label")
				choice2:SetPadding(Rect()+4)
				choice2:SetText("snes header name")
				choice2:SizeToText()
				choice2:SetupLayout("top", "left")

				choice2:TieCheckbox(choice1)

				local check = area:CreatePanel("checkbox_label")
				check:SetPadding(Rect()+4)
				check:SetText("show all extensions")
				check:SizeToText()
				check:SetupLayout("top", "bottom", "left")
			end

			local current_script

			do
				local area = bottom:CreatePanel("base")
				area:SetPadding(Rect()+2)
				area:SetMargin(Rect(10,0,10,0))
				area:SetupLayout("left", "top", "fill")
				area:SetNoDraw(true)

				do
					local left = area:CreatePanel("base")
					left:SetSize(Vec2()+20)
					left:SetPadding(Rect()+2)
					left:SetMargin(Rect(10,0,10,0))
					left:SetupLayout("top", "right", "fill", "layout_children", "size_to_width")
					left:SetNoDraw(true)

					local choice1 = left:CreatePanel("checkbox_label")
					choice1:SetPadding(Rect()+4)
					choice1:SetText("PAL")
					choice1:SizeToText()
					choice1:SetupLayout("bottom", "left")

					local choice2 = left:CreatePanel("checkbox_label")
					choice2:SetPadding(Rect()+4)
					choice2:SetText("NTSC")
					choice2:SizeToText()
					choice2:SetupLayout("bottom", "left")

					choice2:TieCheckbox(choice1)

					local label = left:CreatePanel("text")
					label:SetPadding(Rect()+2)
					label:SetText("force")
					label:SetupLayout("bottom", "left")
				end

				do
					local right = area:CreatePanel("base")
					right:SetSize(Vec2()+20)
					right:SetPadding(Rect()+2)
					right:SetMargin(Rect(10,0,10,0))
					right:SetupLayout("top", "right", "fill", "layout_children", "size_to_width")
					right:SetNoDraw(true)

					local choice1 = right:CreatePanel("checkbox_label")
					choice1:SetPadding(Rect()+4)
					choice1:SetText("hirom")
					choice1:SizeToText()
					choice1:SetupLayout("bottom", "left")

					local choice2 = right:CreatePanel("checkbox_label")
					choice2:SetPadding(Rect()+4)
					choice2:SetText("lowrom")
					choice2:SizeToText()
					choice2:SetupLayout("bottom", "left")

					choice2:TieCheckbox(choice1)

					local label = right:CreatePanel("text_button")
					label:SetText("load")
					label:SetMargin(Rect()+5)
					label:SizeToText()
					label:SetupLayout("bottom", "left", "fill_x")
					label.OnPress = function()
						if current_script then include(current_script) end
					end
				end
			end


			local function populate(dir)
				path_label:SetText(dir)
				right_list:SetupSorted("name"--[[, "modified", "type", "size"]])
				left_list:SetupSorted("name"--[[, "modified", "type", "size"]])

				if utility.GetParentFolder(dir) then
					right_list:AddEntry("..", 0, "folder", 0).OnSelect = function()
						populate(utility.GetParentFolder(dir))
					end
				end

				for full_path in vfs.Iterate(dir, nil, true) do
					local name = full_path:match(".+/(.+)")

					if vfs.IsFolder(full_path) then
						local entry = right_list:AddEntry(name--[[, last_modified, type, size]])

						entry.OnSelect = function()
							populate(dir .. name .. "/")
							filename_label:SetText(name)
						end

						--entry:SetIcon("textures/silkicons/folder.png")
					else
						local entry = left_list:AddEntry(name--[[, last_modified, type, size]])

						entry.OnSelect = function()
							current_script = dir .. name
							filename_label:SetText(name)
						end

						--entry:SetIcon("textures/silkicons/script.png")
					end
				end
			end

			populate("lua/tests/")

			frame:Layout()
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