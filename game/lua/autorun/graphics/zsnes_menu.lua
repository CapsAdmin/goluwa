menu = _G.menu or {}
menu.panel = menu.panel or NULL

event.AddListener("ShowMenu", "main_menu", function(b, remove)
	if b then
		menu.CreateTopBar()
		event.AddListener("PreDrawGUI", "StartupMenu", menu.RenderBackground)
		timer.Repeat("StartupMenu", 0.050, menu.UpdateBackground)
	else
		event.RemoveListener("PreDrawGUI", "StartupMenu")
		timer.RemoveTimer("StartupMenu")

		if not render3d.IsGBufferReady() then
			prototype.SafeRemove(menu.panel)
			return
		end

		if remove then
			prototype.SafeRemove(menu.panel)
		elseif menu.panel:IsValid() then
			menu.panel:SetVisible(false)
		end
	end
end)

local function MessageBox(title, msg, callback)
	local frame = gui.CreatePanel("frame", nil, "message_box")
	frame:SetSkin("zsnes")
	frame:SetSize(Vec2(250, 120))
	frame:SetTitle(title)
	frame:CenterSimple()
	local top = frame:CreatePanel("base")
	top:SetStyle("frame")
	top:SetHeight(40)
	top:SetColor(Color(0, 0, 0, 0))
	local area = top:CreatePanel("base")
	area:SetSize(Vec2(500, 500))
	area:SetColor(Color(0, 0, 0, 0))
	local text = area:CreatePanel("text")
	text:SetPadding(Rect(2, 4, 2, 4))
	text:SetText(msg)
	text:SetTextColor(ColorBytes(200, 200, 100, 255))
	text:SetupLayout("left")
	area:SetupLayout("size_to_children", "center_simple ")
	top:SetupLayout("top", "fill_x")
	local bottom = frame:CreatePanel("base")
	bottom:SetColor(Color(0, 0, 0, 0))
	bottom:SetHeight(60)
	bottom:SetupLayout("top", "fill_x", "bottom")
	local yes = bottom:CreatePanel("text_button")
	yes.label:SetupLayout("center_y_simple")
	yes.label:SetPadding(Rect(4, 0, 2, 0))
	yes:SetPadding(Rect() + 20)
	yes:SetColor(Color(1, 1, 1.5, 1) * 1.4)
	yes:SetSize(Vec2(80, 26))
	yes:SetText("no")
	yes:SetupLayout("center_y_simple", "right")
	yes.OnRelease = function()
		callback(true)
		frame:Remove()
	end
	local no = bottom:CreatePanel("text_button")
	no.label:SetupLayout("center_y_simple")
	no.label:SetPadding(Rect(4, 0, 2, 0))
	no:SetColor(Color(1, 1, 1.5, 1) * 1.4)
	no:SetPadding(Rect() + 20)
	no:SetSize(Vec2(80, 26))
	no:SetText("yes")
	no:SetupLayout("center_y_simple", "right", "left")
	no.OnRelease = function()
		callback(false)
		frame:Remove()
	end
end

local function LoadLua(bar)
	local frame = gui.CreatePanel("frame", nil, "load_lua")
	frame:SetSkin(bar and bar:GetSkin() or "zsnes")
	frame:SetSize(Vec2(500, 400))
	frame:CenterSimple()
	frame:SetTitle("load lua")
	local hor_divider = frame:CreatePanel("divider")
	hor_divider:SetHeight(240)
	hor_divider:SetDividerWidth(8)
	hor_divider:SetupLayout("fill")
	hor_divider:SetHideDivider(true)
	local top = hor_divider:SetTop(gui.CreatePanel("base", hor_divider))
	top:SetMargin(Rect() + 8)
	top:SetNoDraw(true)
	local divider = top:CreatePanel("divider")
	divider:SetHeight(20)
	divider:SetupLayout("fill")
	divider:SetDividerWidth(8)
	divider:SetHideDivider(true)
	local left = divider:SetLeft(gui.CreatePanel("base", divider))
	left:SetNoDraw(true)
	local right = divider:SetRight(gui.CreatePanel("base", divider))
	right:SetNoDraw(true)
	divider:SetDividerPosition(320)
	local label = left:CreatePanel("text")
	label:SetText("filename")
	label:SetupLayout("top", "left")
	local left_list = left:CreatePanel("list")
	left_list:SetupLayout("fill")
	left_list:SetupSorted("name"--[[, "modified", "type", "size"]] )
	local label = right:CreatePanel("text")
	label:SetText("directory")
	label:SetupLayout("top", "left")
	local right_list = right:CreatePanel("list")
	right_list:SetupLayout("fill")
	right_list:SetupSorted("name"--[[, "modified", "type", "size"]] )
	local bottom = hor_divider:SetBottom(gui.CreatePanel("base", hor_divider))
	bottom:SetMargin(Rect(8, 0, 8, 0))
	bottom:SetNoDraw(true)
	local bottom2 = bottom:CreatePanel("base")
	bottom2:SetupLayout("fill_x", "size_to_children_height")
	bottom2:SetNoDraw(true)
	local path_label = bottom2:CreatePanel("text")
	path_label:SetPadding(Rect() + 1)
	path_label:SetSize(Vec2() + 12)
	path_label:SetText("/home/caps/")
	path_label:SetupLayout("top", "left", "fill_x")
	local text_entry = bottom2:CreatePanel("text_edit")
	text_entry:SetPadding(Rect() + 1)
	text_entry:SetSize(Vec2() + 20)
	text_entry:SetupLayout("top", "fill_x")
	local filename_label = bottom2:CreatePanel("text")
	filename_label:SetPadding(Rect() + 1)
	filename_label:SetSize(Vec2() + 12)
	filename_label:SetText("aaaa.zip")
	filename_label:SetupLayout("top", "left", "fill_x")
	local bottom3 = bottom:CreatePanel("base")
	bottom3:SetHeight(100)
	bottom3:SetupLayout("bottom", "fill_x")
	bottom3:SetNoDraw(true)

	do
		local area = bottom3:CreatePanel("base")
		area:SetPadding(Rect() + 2)
		area:SetMargin(Rect(0, 0, 0, 0))
		area:SetupLayout("size_to_children_width", "top", "left", "fill_y")
		area:SetNoDraw(true)
		local check = area:CreatePanel("checkbox_label")
		check:SetPadding(Rect() + 4)
		check:SetText("show all extensions")
		check:SizeToText()
		check:SetupLayout("bottom", "left")
		local choices = gui.CreateChoices({"long filename", "snes header name"}, 1, area)
		choices:SetupLayout("bottom", "left")
	end

	local current_script

	do
		local area = bottom3:CreatePanel("base")
		area:SetPadding(Rect() + 2)
		area:SetMargin(Rect(10, 0, 10, 0))
		area:SetHeight(100)
		area:SetWidth(220)
		area:SetupLayout("layout_children", "top", "right", "fill_y")
		area:SetNoDraw(true)

		do
			local left = area:CreatePanel("base")
			left:SetSize(Vec2() + 20)
			left:SetPadding(Rect() + 2)
			left:SetMargin(Rect(10, 0, 10, 0))
			left:SetupLayout("size_to_children_width", "fill_y", "right")
			left:SetNoDraw(true)
			local choices = gui.CreateChoices({"PAL", "NTSC"}, 1, left, Rect() + 4)
			choices:SetupLayout("center_x_simple", "bottom")

			for _, choice in ipairs(choices:GetChildren()) do
				if choice.checkbox then
					choice.checkbox:SetActiveStyle("check")
					choice.checkbox:SetInactiveStyle("uncheck")
				end
			end

			local label = left:CreatePanel("text")
			label:SetPadding(Rect() + 2)
			label:SetText("force")
			label:SetupLayout("center_x_simple", "bottom")
		end

		do
			local right = area:CreatePanel("base")
			right:SetSize(Vec2() + 20)
			right:SetPadding(Rect() + 2)
			right:SetMargin(Rect(10, 0, 10, 0))
			right:SetupLayout("size_to_children_width", "fill_y", "left")
			right:SetNoDraw(true)
			local choices = gui.CreateChoices({"hirom", "lorom"}, 1, right, Rect() + 4)
			choices:SetupLayout("center_x_simple", "bottom")

			for _, choice in ipairs(choices:GetChildren()) do
				if choice.checkbox then
					choice.checkbox:SetActiveStyle("check")
					choice.checkbox:SetInactiveStyle("uncheck")
				end
			end

			local label = right:CreatePanel("text_button")
			label:SetText("load")
			label:SetMargin(Rect() + 5)
			label:SizeToText()
			label:SetupLayout("center_x_simple", "bottom", "left", "fill_x")
			label.OnPress = function()
				if current_script then runfile(current_script) end
			end
		end
	end

	local function populate(dir)
		path_label:SetText(dir)
		right_list:SetupSorted("name"--[[, "modified", "type", "size"]] )
		left_list:SetupSorted("name"--[[, "modified", "type", "size"]] )
		right_list:AddEntry("..", 0, "folder", 0).OnSelect = function()
			populate(vfs.GetParentFolderFromPath(dir))
		end

		for full_path in vfs.Iterate(dir, true) do
			local name = full_path:match(".+/(.+)")

			if vfs.IsDirectory(full_path) then
				local entry = right_list:AddEntry(name--[[, last_modified, type, size]] )
				entry.OnSelect = function()
					populate(dir .. name .. "/")
					filename_label:SetText(name)
				end
			--entry:SetIcon("textures/silkicons/folder.png")
			else
				local entry = left_list:AddEntry(name--[[, last_modified, type, size]] )
				entry.OnSelect = function()
					current_script = dir .. name
					filename_label:SetText(name)
				end
			--entry:SetIcon("textures/silkicons/script.png")
			end
		end
	end

	populate("lua/examples/")
	frame:Layout()
end

local emitter = gfx.CreateParticleEmitter(2000)
emitter:SetPosition(Vec3(50, 50, 0))
emitter:SetMoveResolution(0.6)
emitter:SetAdditive(false)

function menu.UpdateBackground()
	emitter:SetScreenRect(Rect(-100, -100, render.GetScreenSize():Unpack()))

	for i = 1, 4 do
		emitter:SetPosition(Vec3(math.random(render.GetWidth() + 100) - 150, -50, 0))
		local p = emitter:AddParticle()
		p:SetDrag(1)
		--p:SetStartLength(Vec2(0))
		--p:SetEndLength(Vec2(30, 0))
		--p:SetAngle(math.random(360))
		p:SetVelocity(Vec3(math.random(100), math.random(30, 75) * 2, 0))
		p:SetLifeTime(20)
		p:SetStartSize(2)
		p:SetEndSize(2)
		p:SetColor(Color(1, 1, 1, math.randomf(0.1, 0.7)))
	end
end

-- closest while alpha is low
local background = Color(0.525, 0.3225, 1, 0.2475)

function menu.RenderBackground()
	render2d.SetTexture()
	render2d.SetColor(background:Unpack())
	render2d.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	emitter:Draw()
end

function menu.CreateTopBar()
	if not gui.init then gui.Initialize() end

	local skin = gui.GetRegisteredSkin("zsnes").skin
	local S = skin:GetScale()
	local thingy = gui.CreatePanel("base", gui.world, "close_resize_minimize")
	thingy:SetSize(Vec2(52, 27))
	thingy:SetColor(Color(0, 0, 0, 0))
	thingy:SetupLayout("right", "top")
	thingy:SetCachedRendering(true)

	local function draw_shadow(self)
		render2d.SetTexture()
		render2d.SetColor(0, 0, 0, 0.5)
		render2d.DrawRect(11, 11, self.Size.x, self.Size.y)
	end

	local min = thingy:CreatePanel("text_button")
	min:SetSkin(skin)
	min:SetText("-")
	min:SetSize(Vec2(22, 10))
	min:CenterText()
	min:SetupLayout("left", "bottom")
	min:SetPadding(Rect() + 2)
	min.OnPreDraw = draw_shadow
	min.OnRelease = function()
		window.Minimize()
	end
	local restore = false
	local max = thingy:CreatePanel("text_button")
	max:SetSkin(skin)
	max:SetText("▫")
	max:SetSize(Vec2(22, 10))
	max:CenterText()
	max:SetupLayout("left", "bottom")
	max:SetPadding(Rect() + 2)
	max.OnPreDraw = draw_shadow
	max.OnRelease = function()
		if restore then
			window.Restore()
			restore = false
		else
			window.Maximize()
			restore = true
		end
	end
	local exit = thingy:CreatePanel("text_button")
	exit:SetSkin(skin)
	exit:SetText("x")
	exit:SetSize(Vec2(23, 22))
	exit:CenterText()
	exit:SetupLayout("right", "bottom")
	exit:SetPadding(Rect() + 2)
	exit.OnPreDraw = draw_shadow
	exit.OnRelease = function()
		system.ShutDown()
	end
	local bar = gui.CreatePanel("base", gui.world, "main_menu_bar")
	bar:SetSkin(skin)
	bar:SetStyle("gradient")
	bar:SetDraggable(true)
	bar:SetSize(window.GetSize() * 1)
	bar:SetMargin(Rect() + S)
	bar:SetCachedRendering(true)
	bar:SetupLayout("size_to_children")
	bar.OnPreDraw = draw_shadow

	bar:CallOnRemove(function()
		thingy:Remove()
	end)

	menu.panel = bar
	bar:SetUpdateRate(1 / 40)
	bar.OnUpdate = function(_, dt)
		emitter:Update(dt)
	end

	local function create_button(text, options, w)
		w = w or 0
		local button = bar:CreatePanel("text_button")
		button:SetSizeToTextOnLayout(true)
		button:SetText(text)
		button:SetMargin(Rect(S * 2 - w, S * 1, S * 2 - w, S * 1))
		button:SetPadding(Rect(S * 2, S, S * 2, S))
		button:SetMode("toggle")
		button:SetupLayout("left", "top")
		button.menu = NULL
		local old = button.OnMouseEnter
		button.OnMouseEnter = function(...)
			if gui.current_menu:IsValid() and button.menu ~= gui.current_menu then
				button:OnPress()
				button:SetState(true)
			end

			old(...)
		end
		button.OnPress = function()
			if button.menu:IsValid() and button.menu == gui.current_menu then
				button.menu:Remove()
				gui.current_menu:Remove()
				button:SetState(false)
				return
			end

			if button.menu:IsValid() then return end

			local menu = gui.CreateMenu(options, bar)

			function menu:OnPreDraw()
				render2d.SetTexture()
				render2d.SetColor(0, 0, 0, 0.25)
				render2d.DrawRect(11, 11, self.Size.x, self.Size.y)
			end

			menu:SetPosition(button:GetWorldPosition() + Vec2(0, button:GetHeight() + 2 * S), options)
			menu:Animate("DrawScaleOffset", {Vec2(1, 0), Vec2(1, 1)}, 0.25, "*", 0.25, true)

			menu:CallOnRemove(function()
				if button:IsValid() then button:SetState(false) end

				menu:Animate(
					"DrawScaleOffset",
					{Vec2(1, 1), Vec2(1, 0)},
					0.25,
					"*",
					0.25,
					true,
					function()
						menu.okay = true
						menu:Remove()
					end
				)

				if not menu.okay then --return false
				end
			end)

			button.menu = menu
		end
	end

	local command_history = serializer.ReadFile("luadata", "data/cmd_history.txt") or {}
	local lst = {}

	for i = 1, 10 do
		local name = i .. "."

		if i == 10 then name = "0." end

		local cmd = command_history[#command_history - i - 1]

		if cmd then name = name .. cmd:trim() end

		list.insert(
			lst,
			{
				name,
				function()
					if cmd then commands.RunString(cmd) end
				end,
			}
		)
	end

	list.insert(lst, {})
	list.insert(lst, {L("freeze data: off")})
	list.insert(lst, {L("clear all data")})
	create_button("↓", lst, 1)
	create_button(
		L("game"),
		{
			{
				L("load"),
				function()
					LoadLua(bar)
				end,
			},
			{
				L("run [ESC]"),
				function()
					menu.Close()
				end,
			},
			{
				L("reset"),
				function()
					commands.RunString("restart")
				end,
			},
			{},
			{
				L("save state"),
				function()
					MessageBox("state confirmation", "okay to save state?", function(b)
						if b then
							serializer.WriteFile("luadata", "world.map", entities.GetWorld():GetStorableTable())
						end
					end)
				end,
			},
			{
				L("open state"),
				function()
					MessageBox("state confirmation", "okay to load state?", function(b)
						if b then
							entities.GetWorld():SetStorableTable(serializer.ReadFile("luadata", "world.map"))
						end
					end)
				end,
			},
			{L("pick state")},
			{},
			{
				L("quit"),
				function()
					system.ShutDown()
				end,
			},
		}
	)
	create_button(
		L("config"),
		{
			{L("input")},
			{},
			{L("devices")},
			{L("chip cfg")},
			{},
			{L("options")},
			{
				L("video"),
				function()
					local frame = gui.CreatePanel("frame")
					frame:SetSkin(bar:GetSkin())
					frame:SetSize(Vec2(500, 400))
					frame:CenterSimple()
					frame:SetTitle(L("video config"))
					local tab = frame:CreatePanel("tab")
					tab:SetupLayout("fill")
					local page = tab:AddTab(L("modes"))
					local page = tab:AddTab(L("filter"))
					local label = page:CreatePanel("text")
					label:SetPadding(Rect() + 2)
					label:SetText("video filters:")
					label:SetupLayout("left", "top")
					local choices = gui.CreateChoices(
						{
							"none",
							--[["interpolation", "2xsai engine", "super 2xsai", "ntsc filter", "super eagle",]] "hq filter",
						},
						1,
						page,
						Rect() + 8
					)
					choices:SetupLayout("bottom", "left", "top")

					function choices:OnCheck(what)
						if what == "none" then
							render2d.RemoveEffect("zsnes_filter")
							render2d.EnableEffects(false)
						else
							render2d.EnableEffects(true)

							if what == "hq filter" then
								render2d.AddEffect(
									"zsnes_filter",
									1,
									[[
							float mx = 1.0; // start smoothing wt.
							const float k = -1.10; // wt. decrease factor
							const float max_w = 0.75; // max filter weigth
							const float min_w = 0.03; // min filter weigth
							const float lum_add = 0.33; // effects smoothing

							vec4 color = texture2D(self, uv);
							vec3 c = color.xyz;


							float x = 0.5 * (1.0 / _G.screen_size.x);
							float y = 0.5 * (1.0 / _G.screen_size.y);

							const vec3 dt = 1.0*vec3(1.0, 1.0, 1.0);

							vec2 dg1 = vec2( x, y);
							vec2 dg2 = vec2(-x, y);

							vec2 sd1 = dg1*0.5;
							vec2 sd2 = dg2*0.5;

							vec2 ddx = vec2(x,0.0);
							vec2 ddy = vec2(0.0,y);

							vec4 t1 = vec4(uv-sd1,uv-ddy);
							vec4 t2 = vec4(uv-sd2,uv+ddx);
							vec4 t3 = vec4(uv+sd1,uv+ddy);
							vec4 t4 = vec4(uv+sd2,uv-ddx);
							vec4 t5 = vec4(uv-dg1,uv-dg2);
							vec4 t6 = vec4(uv+dg1,uv+dg2);

							vec3 i1 = texture2D(self, t1.xy).xyz;
							vec3 i2 = texture2D(self, t2.xy).xyz;
							vec3 i3 = texture2D(self, t3.xy).xyz;
							vec3 i4 = texture2D(self, t4.xy).xyz;

							vec3 o1 = texture2D(self, t5.xy).xyz;
							vec3 o3 = texture2D(self, t6.xy).xyz;
							vec3 o2 = texture2D(self, t5.zw).xyz;
							vec3 o4 = texture2D(self, t6.zw).xyz;

							vec3 s1 = texture2D(self, t1.zw).xyz;
							vec3 s2 = texture2D(self, t2.zw).xyz;
							vec3 s3 = texture2D(self, t3.zw).xyz;
							vec3 s4 = texture2D(self, t4.zw).xyz;

							float ko1 = dot(abs(o1-c),dt);
							float ko2 = dot(abs(o2-c),dt);
							float ko3 = dot(abs(o3-c),dt);
							float ko4 = dot(abs(o4-c),dt);

							float k1=min(dot(abs(i1-i3),dt),max(ko1,ko3));
							float k2=min(dot(abs(i2-i4),dt),max(ko2,ko4));

							float w1 = k2; if(ko3<ko1) w1*=ko3/ko1;
							float w2 = k1; if(ko4<ko2) w2*=ko4/ko2;
							float w3 = k2; if(ko1<ko3) w3*=ko1/ko3;
							float w4 = k1; if(ko2<ko4) w4*=ko2/ko4;

							c=(w1*o1+w2*o2+w3*o3+w4*o4+0.001*c)/(w1+w2+w3+w4+0.001);
							w1 = k*dot(abs(i1-c)+abs(i3-c),dt)/(0.125*dot(i1+i3,dt)+lum_add);
							w2 = k*dot(abs(i2-c)+abs(i4-c),dt)/(0.125*dot(i2+i4,dt)+lum_add);
							w3 = k*dot(abs(s1-c)+abs(s3-c),dt)/(0.125*dot(s1+s3,dt)+lum_add);
							w4 = k*dot(abs(s2-c)+abs(s4-c),dt)/(0.125*dot(s2+s4,dt)+lum_add);

							w1 = clamp(w1+mx,min_w,max_w);
							w2 = clamp(w2+mx,min_w,max_w);
							w3 = clamp(w3+mx,min_w,max_w);
							w4 = clamp(w4+mx,min_w,max_w);

							color = vec4((w1*(i1+i3)+w2*(i2+i4)+w3*(s1+s3)+w4*(s2+s4)+c)/(2.0*(w1+w2+w3+w4)+1.0), 1.0);

							return color;
						]]
								)
							end
						end
					end
				end,
			},
			{L("sound")},
			{L("paths")},
			{L("saves")},
			{L("speed")},
		}
	)
	create_button(L("cheat"), {
		{L("add code")},
		{L("browse")},
		{L("search")},
	})
	create_button(
		L("netplay"),
		{
			{
				L("internet"),
				function()
					local frame = gui.CreatePanel("frame")
					--frame:SetSkin(bar:GetSkin())
					frame:SetPosition(Vec2(100, 100))
					frame:SetSize(Vec2(500, 400))
					frame:SetTitle("servers (fetching public servers..)")
					local tab = frame:CreatePanel("tab")
					tab:SetupLayout("fill")
					local page = tab:AddTab(L("internet"))
					local list = page:CreatePanel("list")
					list:SetupLayout("fill")
					list:SetupSorted(L("name"), L("players"), L("map"), L("latency"))

					list:SetupConverters(nil, function(num)
						tostring(num)
					end)

					network.JoinIRCServer()

					local function add(info)
						frame:SetTitle("server list")
						list:AddEntry(info.name, info.players, info.map, info.latency).OnSelect = function()
							network.Connect(info.ip, info.port)
						end
					end

					for _, info in pairs(network.GetAvailableServers()) do
						add(info)
					end

					event.AddListener("PublicServerFound", "server_list", function(info)
						add(info)
					end)

					local page = tab:AddTab(L("favorites"))
					local list = page:CreatePanel("list")
					list:SetupLayout("fill")
					list:SetupSorted(L("name"), L("players"), L("map"), L("latency"))
					local page = tab:AddTab(L("history"))
					local list = page:CreatePanel("list")
					list:SetupLayout("fill")
					list:SetupSorted(L("name"), L("players"), L("map"), L("latency"))
					local page = tab:AddTab(L("lan"))
					local list = page:CreatePanel("list")
					list:SetupLayout("fill")
					list:SetupSorted(L("name"), L("players"), L("map"), L("latency"))
					tab:SelectTab(L("internet"))
				end,
			},
		}
	)
	create_button(
		L("misc"),
		{
			{L("misc keys")},
			{L("gui opts")},
			{L("key comb.")},
			{L("save cfg")},
			{},
			{L("about")},
		}
	)
--	bar:SetupLayout("left", "up", "fill_x", "size_to_children_width")
end

if RELOAD then
	menu.Toggle()
	menu.Toggle()
	LoadLua()
end