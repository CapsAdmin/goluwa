local scoreboard = _G.scoreboard or {}

scoreboard.panel = scoreboard.panel or NULL
scoreboard.containers = {}
scoreboard.clients = {}

input.Bind("tab", "+score", function()
	if input.IsKeyDown("left_alt") then return end
	if menu.IsVisible() then return end

	if not scoreboard.panel:IsValid() then
		scoreboard.Initialize()
		if not network.IsConnected() then
			scoreboard.AddClient(clients.GetLocalClient())
		end
	end
	scoreboard.panel:SetVisible(true)
end)

input.Bind("tab", "-score", function()
	if input.IsKeyDown("left_alt") then return end

	if not scoreboard.panel:IsValid() then return end
	if scoreboard.showed_cursor then
		window.SetMouseTrapped(true)
	end
	scoreboard.showed_cursor = nil

	if not render3d.IsGBufferReady() then
		prototype.SafeRemove(scoreboard.panel)
		return
	end

	scoreboard.panel:SetVisible(false)
end)

local scoreboard_title
local scoreboard_title_2


function scoreboard.SetupContainer(id)
	if not scoreboard.panel:IsValid() then
		scoreboard.Initialize()
	end

	if scoreboard.containers[id] then return scoreboard.containers[id] end

	local container = scoreboard.panel:CreatePanel("base")
	container:SetStyle("text_edit")
	container:SetMargin(Rect())
	container:SetupLayout("layout_children", "top", "size_to_children_height")
	container:SetNoDraw(true)
	container:SetMinimumSize(Vec2())
	container:SetLayoutSize()
	container:SetWidth(scoreboard.panel:GetWidth())

	local title = container:CreatePanel("text_button")
	title:SetFont(scoreboard_title_2)
	title:SetMode("toggle")
	title:SetMargin(Rect()+5)
	title:SetText(id)
	title:SizeToText()
	title:SetWidth(scoreboard.panel:GetWidth())
	title:SetColor(Color(0.25,0.5,1,1)*3.75)
	title:SetupLayout("top")
	title.label:SetupLayout("center_y_simple")
	title:SetState(true)
	--title.label:SetupLayout("top", "center_x_simple")

	local team = scoreboard.panel:CreatePanel("base")
	team:SetMargin(Rect())
	team:SetSize(scoreboard.panel:GetSize())
	team:SetupLayout("top", "size_to_children_height")
	team:SetNoDraw(true)
	team.container = container
	team.id = id

	title.OnStateChanged = function(_, b)
		if b then
			team:SetVisible(true)
			team:Animate("DrawScaleOffset", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)
		else
			team:Animate("DrawScaleOffset", {Vec2(1,1), Vec2(1,0)}, 0.25, "*", 0.25, true, function()
				team:SetVisible(false)
				title:SetState(false)
				scoreboard.panel:Layout(true)
			end)
		end
	end

	scoreboard.containers[id] = team

	return team
end

function scoreboard.AddClient(client)
	scoreboard.RemoveClient(client, true)
	local player_info = scoreboard.SetupContainer(client:GetGroup()):CreatePanel("base")

	scoreboard.clients[client] = player_info

	player_info:SetHeight(30)
	player_info:SetupLayout("top", "fill_x")
	player_info:SetNoDraw(true)
	player_info:SetMargin(Rect())
--	player_info:SetPadding(Rect())

	local friend = player_info:CreatePanel("base")
	friend:SetCursor("hand")
	friend:SetTexture(render.CreateTextureFromPath("textures/silkicons/user.png"))
	friend:SetSize(Vec2()+16)
	friend:SetPadding(Rect()+5)
	friend:SetupLayout("left", "center_y_simple")

	local avatar = player_info:CreatePanel("image")
	prototype.AddPropertyLink(avatar, client, "Path", "AvatarPath") --avatar:SetTexture(client:GetAvatarTexture())
	avatar:SetSize(Vec2()+30)
	avatar:SetPadding(Rect())
	avatar:SetupLayout("left", "center_y_simple")

	local info = player_info:CreatePanel("base")
	info:SetHeight(30)
	info:SetStyle("tab_frame")
	info:SetupLayout("left", "fill_x")

	info.OnRightClick = function()
		gui.CreateMenu({
			{"goto", {{"bring", nil, "textures/silkicons/arrow_in.png"}}, "textures/silkicons/arrow_right.png"},
			{},
			{"spawn", {{"revive", nil, "textures/silkicons/heart.png"}}, "textures/silkicons/heart_add.png"},
			{"cleanup", {{"kick", nil, "textures/silkicons/connect.png"}}, "textures/silkicons/bin.png"},
			{},
			{"admin menu", {
				{"ban weapons", nil, "textures/silkicons/gun.png"},
				{"kick", nil, "textures/silkicons/door_out.png"},
				{"ban", nil, "textures/silkicons/delete.png"},
			}, "textures/silkicons/lock.png"},
			{"mute", {{"gag", nil, "textures/silkicons/comment_delete.png"}}, "textures/silkicons/sound_mute.png"},
		}, info)
	end

	do
		local ping = info:CreatePanel("base")
		ping:SetNoDraw(true)
		ping:SetHeight(30)
		ping:SetWidth(50)
		ping:SetMargin(Rect()+5)
		ping:SetupLayout("layout_children", "right")

		local icon = ping:CreatePanel("base")
		icon:SetTexture(render.CreateTextureFromPath("textures/silkicons/connect.png"))
		icon:SetSize(Vec2()+16)
		icon:SetupLayout("left", "center_y_simple")

		local text = ping:CreatePanel("text")
		prototype.AddPropertyLink(text, client, "Text", "Ping") -- text:SetText(client:GetPing())
		text:SetPadding(Rect()+4)
		text:SetupLayout("left", "center_y_simple")
	end

	local name = info:CreatePanel("text")
	name:SetPadding(Rect()+5)
	prototype.AddPropertyLink(name, client, "Text", "Nick") -- name:SetText(client:GetNick())
	name:SetupLayout("left", "center_y_simple", "fill_x")

	do
		local tags = player_info:CreatePanel("base")
		tags:SetHeight(30)
		tags:SetWidth(400)
		tags:SetupLayout("layout_children", "size_to_children_width", "center_x_simple")
		tags:SetNoDraw(true)

		tags.OnMouseEnter = function()
			if window.GetMouseTrapped() then return end
			for _, child in ipairs(tags:GetChildren()) do
				if child.ClassName == "text" then
					child:SetVisible(true)
				end
			end
			player_info:Layout()
		end

		tags.OnMouseExit = function()
			for _, child in ipairs(tags:GetChildren()) do
				if child.ClassName == "text" then
					child:SetVisible(false)
				end
			end
			player_info:Layout()
		end

		local function add_tag(path, str)
			local icon = tags:CreatePanel("base")
			icon:SetTexture(render.CreateTextureFromPath(path))
			icon:SetSize(Vec2()+16)
			icon:SetPadding(Rect()+5)
			icon:SetIgnoreMouse(true)
			icon:SetupLayout("left", "center_y_simple")

			local text = tags:CreatePanel("text")
			text:SetVisible(false)
			text:SetPadding(Rect()+3)
			text:SetText(str)
			text:SetIgnoreMouse(true)
			text:SetupLayout("left", "center_y_simple")
		end

		add_tag("textures/silkicons/clock.png", "AFK")
		add_tag("textures/silkicons/wrench.png", "Building")
	end

	scoreboard.panel.help:BringToFront()
end

function scoreboard.RemoveClient(client, now)
	local panel = scoreboard.clients[client] or NULL
	if panel:IsValid() then
		panel:SetGreyedOut(true)
		local function callback()
			if panel:IsValid() then
				local parent = panel:GetParent()
				gui.RemovePanel(panel)
				scoreboard.panel:Layout()
				if parent:IsValid() then
					if #parent:GetChildren() == 0 then
						scoreboard.containers[parent.id] = nil
						parent.container:Remove()
					end
				end
			end
		end
		if now then
			callback()
		else
			event.Delay(3, callback)
		end
	end
end

function scoreboard.Initialize()
	scoreboard_title = fonts.CreateFont({
		path = "Oswald",
		fallback = gfx.GetDefaultFont(),
		size = 17,
		shadow = 1,
	})

	scoreboard_title_2 = fonts.CreateFont({
		path = "Oswald",
		fallback = gfx.GetDefaultFont(),
		size = 11,
		shadow = 5,
	})

	gui.RemovePanel(scoreboard.panel)
	local panel = gui.CreatePanel("base")
	scoreboard.panel = panel

	if not RELOAD then
		panel:SetVisible(false)
	end

	panel:SetSize(window.GetSize()/1.75)
	panel:SetNoDraw(true)
	panel:SetupLayout("layout_children", "size_to_children_height", "center_x_simple", "center_y_simple")
	--panel:SetupLayout("center_x_simple", "center_y_simple")

	local title = panel:CreatePanel("text_button")
	title:SetMode("toggle")
	title:SetFont(scoreboard_title)
	title:SetText("Bubu's Server - Subway Simulator")
	prototype.AddPropertyLink(title, function() return network.GetHostname() end, function(val) title:SetText(val) end)

	title:SetMargin(Rect()+7)
	title:SizeToText()
	title:SetupLayout("top", "fill_x")
	title.label:SetupLayout("left")

	do
		local info = panel:CreatePanel("base")
		info:SetVisible(false)
		info:SetHeight(30)
		info:SetStyle("frame2")
		info:SetupLayout("top", "fill_x")
		info:SetClipping(true)
		info:SetMinimumSize(Vec2())
		info:SetLayoutSize()

		title.OnStateChanged = function(_, b)
			if b then
				info:SetVisible(true)
				info:Animate("Size", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)
			else
				info:Animate("Size", {Vec2(1,1), Vec2(1,0)}, 0.25, "*", 0.25, true, function()
					info:SetVisible(false)
					title:SetState(false)
				end)
			end
		end

		local text = info:CreatePanel("text")
		text:SetPadding(Rect(10,5,10,5))
		text:SetText("gm_metrostroi_b47 with 3 players")
		text:SetupLayout("left", "top")

		local text = info:CreatePanel("text")
		text:SetPadding(Rect(10,5,10,5))
		text:SetText("tickrate: 67")
		text:SetupLayout("left", "top")

		local text = info:CreatePanel("text")
		text:SetPadding(Rect(10,5,10,5))
		text:SetText("curtime 1:24h")
		text:SetupLayout("left", "top")
	end

	local help = panel:CreatePanel("text", "help")
	help:SetFont(scoreboard_title)
	help:SetText("right click to show cursor")
	help:SetPadding(Rect()+10)
	help:SetupLayout("top", "center_x_simple")

	panel.OnShow = function()
		help:SetVisible(window.GetMouseTrapped())
	end

	help.OnGlobalMouseInput = function(_, button, press)
		if not window.GetMouseTrapped() then return end
		if panel.Visible and button == "button_2" then
			window.SetMouseTrapped(false)
			help:SetVisible(false)
			scoreboard.showed_cursor = true
			return true
		end
	end
end

event.AddListener("ClientEntered", "scoreboard", function(client)
	scoreboard.AddClient(client)
end)

event.AddListener("ClientLeft", "scoreboard", function(client, reason)
	scoreboard.RemoveClient(client)
end)

event.AddListener("ClientChangedGroup", "scoreboard", function(client, old_group)
	scoreboard.RemoveClient(client, true)
	scoreboard.AddClient(client)
end)

if RELOAD then
	scoreboard.panel:Remove()
	scoreboard.Initialize()
	for _, client in ipairs(clients.GetAll()) do
		scoreboard.AddClient(client)
	end
end

_G.scoreboard = scoreboard
--return scoreboard