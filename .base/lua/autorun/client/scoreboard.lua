local score = utility.RemoveOldObject(gui2.CreatePanel("base"), "score")
score:SetVisible(false)
score:SetSize(window.GetSize()/1.25)
score:Center()
score:SetNoDraw(true)

surface.CreateFont("scoreboard_title", {
	path = "Oswald",
	fallback = "default",
	size = 17,
	padding = 8, 
	shade = passes,
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
	info.wow = true
	info:SetLayoutSize()

	title.OnStateChanged = function(_, b)
		if b then
			info:SetVisible(true)
			info:Animate("Size", {Vec2(1,0), Vec2(1,1)}, 0.25, "*", 0.25, true)
		else
			info:Animate("Size", {Vec2(1,1), Vec2(1,0)}, 0.25, "*", 0.25, true, function()
				info:SetVisible(false)
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
	tags:SetupLayoutChain("size_to_children", "center_x")
	tags:SetNoDraw(true)
	tags:SetAlwaysReceiveMouseInput(true)

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
		text:SetupLayoutChain("right", "left")
		
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

console.AddCommand("+score", function()
	score:SetVisible(true)
end)
console.AddCommand("-score", function()
	score:SetVisible(false)
end)

input.Bind("tab", "+score")
input.Bind("tab", "-score")