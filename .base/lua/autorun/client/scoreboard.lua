local score = utility.RemoveOldObject(gui.CreatePanel("base"), "score")

input.Bind("tab", "+score", function()
	score:SetVisible(true)
end)

input.Bind("tab", "-score", function()
	score:SetVisible(false)
	window.SetMouseTrapped(true)
end)

if not RELOAD then
	score:SetVisible(false)
end

score:SetSize(window.GetSize()/1.25)
score:SetNoDraw(true)
score:SetupLayoutChain("layout_children", "size_to_height", "center_x_simple", "center_y_simple")

surface.CreateFont("scoreboard_title", {
	path = "Oswald",
	fallback = "default",
	size = 17,
	shadow = 1,
})

local title = score:CreatePanel("text_button")
title:SetMode("toggle")
title:SetFont("scoreboard_title")
title:SetText("Bubu's Server - Subway Simulator")

title:SetMargin(Rect()+7)
title:SizeToText()
title:SetupLayoutChain("top", "fill_x")
title.label:SetupLayoutChain("left")

do
	local info = score:CreatePanel("base")
	info:SetVisible(false)
	info:SetHeight(30)
	info:SetStyle("frame2")
	info:SetupLayoutChain("top", "fill_x")
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
	text:SetText("gm_metrostroi_b47 with 3 players")
	text:SetupLayoutChain("left")
	text:SetPadding(Rect()+30)

	local text = info:CreatePanel("text")
	text:SetText("tickrate: 67")
	text:SetupLayoutChain("right", "left")
	text:SetPadding(Rect()+30)

	local text = info:CreatePanel("text")
	text:SetText("curtime 1:24h")
	text:SetupLayoutChain("right", "left")
	text:SetPadding(Rect()+30)
end

local function add_player(avatar_path, name_str)

	local player_info = score:CreatePanel("base")
	player_info:SetHeight(30)
	player_info:SetupLayoutChain("left", "top", "fill_x")
	player_info:SetNoDraw(true)

	local friend = player_info:CreatePanel("base")
	friend:SetTexture(Texture("textures/silkicons/user.png"))
	friend:SetSize(Vec2()+16)
	friend:SetPadding(Rect()+5)
	friend:SetupLayoutChain("left")

	local avatar = player_info:CreatePanel("base")
	avatar:SetTexture(Texture(avatar_path))
	avatar:SetSize(Vec2()+30)
	avatar:SetPadding(Rect()+5)
	avatar:SetupLayoutChain("left")

	local info = player_info:CreatePanel("base")
	info:SetHeight(30)
	info:SetStyle("tab_frame")
	info:SetupLayoutChain("left", "fill_x")
	
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
		ping:SetStyle("menu_select")
		ping:SetHeight(30)
		ping:SetWidth(55)
		ping:SetupLayoutChain("right")
		
		local icon = ping:CreatePanel("base")
		icon:SetTexture(Texture("textures/silkicons/connect.png"))
		icon:SetSize(Vec2()+16)
		icon:SetPadding(Rect()+5)
		icon:SetupLayoutChain("left")
		
		local text = ping:CreatePanel("text")
		text:SetText(math.random(100, 200))
		text:SetSize(Vec2()+16)
		text:SetupLayoutChain("left")
	end

	local name = info:CreatePanel("text")
	name:SetPadding(Rect()+5)
	name:SetText(name_str)
	name:SetupLayoutChain("left", "fill_x")

	local tags = player_info:CreatePanel("base")
	tags:SetHeight(30)
	tags:SetWidth(200)
	tags:SetupLayoutChain("layout_children", "size_to_width", "center_x_simple")
	tags:SetNoDraw(true)

	tags.OnMouseEnter = function()
		for i, child in ipairs(tags:GetChildren()) do
			if child.ClassName == "text" then
				child:SetVisible(true)
			end
		end
		player_info:Layout()
	end

	tags.OnMouseExit = function()
		for i, child in ipairs(tags:GetChildren()) do
			if child.ClassName == "text" then
				child:SetVisible(false)
			end
		end
		player_info:Layout()
	end

	local function add_tag(path, str)
		local icon = tags:CreatePanel("base")
		icon:SetTexture(Texture(path))
		icon:SetSize(Vec2()+16)
		icon:SetPadding(Rect()+5)
		icon:SetIgnoreMouse(true)
		icon:SetupLayoutChain("right", "left")

		local text = tags:CreatePanel("text")
		text:SetVisible(false)
		text:SetText(str)
		text:SetPadding(Rect()+10)
		text:SetIgnoreMouse(true)
		text:SetupLayoutChain("right", "left", "size_parent_to_width")
		
		tags:Layout()
	end
		
	add_tag("textures/silkicons/clock.png", "AFK")
	add_tag("textures/silkicons/wrench.png", "Building")
end

local team = score:CreatePanel("text_button")
team:SetStyle("property")
team:SetText("players")
team:SetMargin(Rect(30,3,20,3))
team:SetPadding(Rect()+5)
team:SizeToText()
team:SetupLayoutChain("top", "left")

add_player("http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/78/78e60cd9f3178dd8a841b87c9bb8049ee65540e6_full.jpg", "CapsAdmin")
add_player("http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/b8/b8ae62638fb03a5b9ec65c9c46f73a362a51382c_full.jpg", "Bubu")
add_player("http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/be/be1e045bb4d999294a235a6ec33991fec05e370a_full.jpg", "Immortalyes")

local help = score:CreatePanel("text")
help:SetFont("scoreboard_title")
help:SetText("right click to show cursor")
help:SetPadding(Rect()+10)
help:SetupLayoutChain("top")

score.OnShow = function() help:SetVisible(true) end

help.OnGlobalMouseInput = function(_, button, press)
	if score.Visible and button == "button_2" then
		window.SetMouseTrapped(false)
		help:SetVisible(false)
	end
end