do
	local META = prototype.CreateTemplate("main_menu")

	local title_font
	local menu_font

	function META:OnLayout()

		local s = render.GetWidth()/1920
		s = s * 1.25

		menu_font = fonts.CreateFont({
			path = "Roboto Black",
			fallback = gfx.GetDefaultFont(),
			size = 30*s,
			padding = 50,
			shadow = {
				order = 1,
				dir = Vec2(-1, 1) * 5 * s,
				dir_passes = 5,
				color = Color(0.25,0.25,0.25,1),
			},
		})

		title_font = fonts.CreateFont({
			path = "propaganda squaregear",--"russian dollmaker",
			fallback = gfx.GetDefaultFont(),
			size = 100*s,
			padding = 50,
			color = {
				order = 2,
				color = ColorBytes(171,211,50),
			},
			shadow = {
				order = 1,
				dir = Vec2(-1, 1) * s * 10,
				dir_passes = 10,
				alpha_pow = 0,
				color = Color(0.25,0.25,0.25,1),
			},
		})

		self:SetSize(render.GetScreenSize():Copy())

		self:SetMargin(Rect(100, 100, 100, 50)*s)
		self.logo:SetMargin(Rect()+20*s)
		self.logo.image:SetSizeKeepAspectRatio(200*s)
		self.logo.image:SetPosition(Vec2(35, 15)*s)
		self.logo.title:SetFont(title_font)
		self.buttons:SetWidth(250*s)
		self.buttons:SetHeight(250*s)

		for i, btn in ipairs(self.buttons:GetChildren()) do
			btn:SetFont(menu_font)
			btn:SetMargin(Rect(1,1,1,1)*5*s)
			btn:SetPadding(Rect(1,1,1,1)*5*s)
			btn:SizeToText()
			btn:SetupLayout("top", "fill_x")
		end

		self.buttons:SetupLayout("SizeToChildren", "left", "bottom")
	end

	function META:Initialize()
		self:SetColor(Color(1,1,0.8,0.25))

		local logo = self:CreatePanel("base", "logo")
		logo:SetSize(Vec2(400, 200))
		logo:NoCollide()
		logo:SetNoDraw(true)

			local image = logo:CreatePanel("image", "image")
			image:SetTexture(render.CreateTextureFromPath("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/textures/lua_logo.png"))
			image:NoCollide()

			local title = logo:CreatePanel("text", "title")

			title:SetTextColor(Color(1,1,1,1))
			title:SetText("GOLUWA")
			title:SetupLayout("left", "center_y_simple")

		logo:SetupLayout("SizeToChildren")

		local buttons = self:CreatePanel("base", "buttons")
		buttons:SetupLayout("SizeToChildren", "left", "bottom")
		buttons:SetNoDraw(true)

		local function add_button(text, cb)
			local btn = buttons:CreatePanel("text_button")
			btn:SetActiveStyle("blank")
			btn:SetColor(Color(1,1,1,0))
			btn:SetOffsetContentOnClick(4)
			btn:SetInactiveStyle("blank")
			--btn:SetTextColor(Color(1,1,1,1))
			btn:SetText(L(text))

			btn:SetupLayout("top", "fill_x")
			btn.OnRelease = cb
		end

		add_button("RESUME", function()
			menu.Close()
		end)
		add_button("LOAD SCENE")
		add_button("JOIN SERVER", function()
			local frame = gui.CreatePanel("frame", menu.panel, "server_browser")
			frame:SetSize(Vec2(600, 400))
			frame:CenterSimple()
			frame:SetTitle("servers (fetching public servers..)")

			local tab = frame:CreatePanel("tab")
			tab:SetupLayout("fill")

			local page = tab:AddTab(L"internet")

			local list = page:CreatePanel("list")
			list:SetupLayout("fill")
			list:SetupSorted(L"name", L"players", L"scene", L"latency")
			list:SetupConverters(nil, function(num) tostring(num) end)

			network.JoinIRCServer(function(count)
				frame:SetTitle("server list (found " .. count .. " servers)")
			end)

			local function add(info)
				list:AddEntry(info.name, #info.players, info.scene_name, info.latency).OnSelect = function()
					network.Connect(info.ip, info.port)
				end
			end

			for _, info in pairs(network.GetAvailableServers()) do
				add(info)
			end

			event.AddListener("PublicServerFound", "server_list", function(info)
				add(info)
			end)

			tab:SelectTab(L"internet")
		end)
		add_button("OPTIONS", function()
			local frame = gui.CreatePanel("frame", menu.panel, "options")
			frame:SetSize(Vec2(600, 400))
			frame:CenterSimple()
			frame:SetTitle("options")

			local tabs = frame:CreatePanel("tab")
			tabs:SetupLayout("fill")

			do
				local page = tabs:AddTab("mounted games")
				local scroll = page:CreatePanel("scroll")
				scroll:SetupLayout("fill")

				for _, info in ipairs(steam.GetSourceGames()) do
					local check = scroll:CreatePanel("checkbox_label")
					check:SetText(info.game)
					check:SetTooltip(info.game_dir)
					check:SizeToText()
					check:SetupLayout("top", "left")
					check:SetState(steam.IsSourceGameMounted(info))

					check.OnCheck = function(_, b)
						if b then
							steam.MountSourceGame(info)
						else
							steam.UnmountSourceGame(info)
						end
					end
				end
			end

			do
				local page = tabs:AddTab("other")
				local scroll = page:CreatePanel("scroll")
				scroll:SetupLayout("fill")

				local props = scroll:SetPanel(page:CreatePanel("properties"))

				local grouped = {}
				for key, info in pairs(pvars.GetAll()) do
					if info.store then
						grouped[info.group] = grouped[info.group] or {}
						grouped[info.group][info.friendly] = info
					end
				end

				for group, vars in table.sortedpairs(grouped, function(a, b) return a.key < b.key end) do
					props:AddGroup(group)
					for key, info in table.sortedpairs(vars, function(a, b) return a.val.friendly < b.val.friendly end) do
						props:AddProperty(
							L(info.friendly),
							function(val) pvars.Set(info.key, val) end,
							function() return pvars.Get(info.key) end,
							info.default,
							info
						)
					end
				end
			end

			tabs:SelectTab("mounted games")
		end)
		add_button("EXIT", function()
			system.ShutDown()
		end)
	end

	gui.RegisterPanel(META)
end

event.AddListener("ShowMenu", "main_menu", function(b, remove)
	if b then
		if menu.panel:IsValid() then
			menu.panel:SetVisible(true)
		else
			menu.panel = gui.CreatePanel("main_menu")
			--console.Open(menu.panel)
			--menu.panel.console.edit:RequestFocus()
		end
	else
		if remove then
			prototype.SafeRemove(menu.panel)
		elseif menu.panel:IsValid() then
			menu.panel:SetVisible(false)
		end
	end
end)

if RELOAD then
	menu.Toggle()
	menu.Toggle()
end

menu.Open()
