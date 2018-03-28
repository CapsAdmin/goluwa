do
	local META = prototype.CreateTemplate("main_menu")

	function META:Initialize()
		self:SetColor(Color(0.6,0.6,0.5,1))
		self:SetSize(render.GetScreenSize():Copy())

		local s = render.GetWidth()/1920
		s = s * 1.25

		local menu_font = fonts.CreateFont({
			path = "Roboto Black",
			fallback = gfx.GetDefaultFont(),
			size = 35*s,
			padding = 50,
			shadow = {
				order = 1,
				dir = Vec2(-1, 1) * 5 * s,
				dir_passes = 5,
				color = Color(0.25,0.25,0.25,1),
			},
		})

		local title_font = fonts.CreateFont({
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

		--self:SetColor(Color(0.1,0.1,0.1,1))


		self:SetMargin(Rect(100, 50, 100, 50)*s)

		local logo = self:CreatePanel("base")
		logo:SetSize(Vec2(400, 200))
		logo:NoCollide()
		logo:SetMargin(Rect()+20*s)
		logo:SetNoDraw(true)

			local image = logo:CreatePanel("image")
			image:SetTexture(render.CreateTextureFromPath("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/textures/lua_logo.png"))
			image:SetSizeKeepAspectRatio(200*s)
			image:SetPosition(Vec2(35, 15)*s)
			image:NoCollide()

			local title = logo:CreatePanel("text")
			title:SetFont(title_font)
			title:SetTextColor(Color(1,1,1,1))
			title:SetText("GOLUWA")
			title:SetupLayout("left", "center_y_simple")

		logo:SetupLayout("SizeToChildren")

		local buttons = self:CreatePanel("base")
		--buttons:SetMargin(Rect()+50)
		buttons:SetWidth(300*s)
		buttons:SetHeight(300*s)
		buttons:SetupLayout("left", "bottom")
		buttons:SetNoDraw(true)

		local function add_button(text, cb)
			local btn = buttons:CreatePanel("text_button")
			btn:SetActiveStyle("blank")
			btn:SetColor(Color(1,1,1,0))
			btn:SetOffsetContentOnClick(4)
			btn:SetInactiveStyle("blank")
			btn:SetFont(menu_font)
			btn:SetTextColor(Color(1,1,1,1))
			btn:SetText(text)
			btn:SetMargin(Rect(2,1,2,1)*15*s)
			btn:SizeToText()
			btn:SetPadding(Rect(1,1,1,1)*5*s)
			btn:SetupLayout("top", "fill_x")
			btn.OnRelease = cb
		end

		add_button("LOAD SCENE")
		add_button("JOIN SERVER")
		add_button("OPTIONS", function()
			local frame = gui.CreatePanel("frame")
			frame:SetSize(Vec2() + 500)
			frame:Center()
			frame:SetTitle("options")
		end)
		add_button("EXIT", function() system.ShutDown() end)
	end

	gui.RegisterPanel(META)
end

event.AddListener("ShowMenu", "main_menu", function(b)
	if b then
		menu.panel = gui.CreatePanel("main_menu")

	else
		prototype.SafeRemove(menu.panel)
	end
end)

if RELOAD then
	menu.Toggle()
	menu.Toggle()
end

menu.Open()