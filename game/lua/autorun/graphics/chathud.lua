chathud = chathud or {}
chathud.font_modifiers = {
--["...."] = {type = "font", val = "DefaultFixed"},
--["!!!!"] = {type = "font", val = "Trebuchet24"},
--["!!!!!11"] = {type = "font", val = "DermaLarge"},
}
chathud.emote_shortucts = chathud.emote_shortucts or
	{
		smug = "<texture=masks/smug>",
		downs = "<texture=masks/downs>",
		saddowns = "<texture=masks/saddowns>",
		niggly = "<texture=masks/niggly>",
		colbert = "<texture=masks/colbert>",
		eli = "<texture=models/eli/eli_tex4z,4>",
		bubu = "<remember=bubu><color=1,0.3,0.2><texture=materials/hud/killicons/default.vtf,50>  <translate=0,-15><color=0.58,0.239,0.58><font=ChatFont>Bubu<color=1,1,1>:</translate></remember>",
		acchan = "<remember=acchan><translate=20,-35><scale=1,0.6><texture=http://www.theonswitch.com/wp-content/uploads/wow-speech-bubble-sidebar.png,64></scale></translate><scale=0.75,1><texture=http://img1.wikia.nocookie.net/__cb20110317001632/southparkfanon/images/a/ad/Kyle.png,64></scale></remember>",
	}
chathud.tags = chathud.tags or {}

if render2d.DrawFlag then
	chathud.tags.flag = {
		arguments = {"gb"},
		draw = function(markup, self, x, y, flag)
			render2d.DrawFlag(flag, x, y - 12)
		end,
	}
end

local pos_mult = pvars.Setup("chathud_pos_mult", Vec2(0.6, 0.76))

function chathud.Initialize()
	chathud.markup = gfx.CreateMarkup()
	chathud.markup:SetEditable(false)
	chathud.markup:SetSelectable(false)
	chathud.life_time = 20

	resource.Download("data/steam_emotes.json"):Then(function(path)
		profiler.StartTimer("emotes")
		local i = 0

		for _, emote in ipairs(vfs.Read(path)) do
			local name = emote.name:sub(2, -2)
			chathud.emote_shortucts[name] = "<texture=http://cdn.steamcommunity.com/economy/emoticon/" .. name .. ">"
			i = i + 1
		end

		llog("loaded %s emotes in %s seconds", i, profiler.StopTimer(true))
	end)

	chathud.font = fonts.CreateFont(
		{
			path = "Roboto",
			fallback = gfx.GetDefaultFont(),
			size = 16,
			margin = 50,
			shadow = {
				order = 1,
				dir = 0,
				color = Color(0, 0, 0, 1),
				blur_radius = 0.5,
				blur_passes = 4,
				alpha_pow = 2,
			},
		}
	)

	for _, v in pairs(vfs.Find("textures/silkicons/")) do
		chathud.emote_shortucts[v:gsub("(%.png)$", "")] = "<texture=textures/silkicons/" .. v .. ",16>"
	end

	chathud.Show()
end

local first = true

function chathud.AddText(...)
	if first then
		chathud.Initialize()
		first = nil
	end

	local args = {}

	for _, v in pairs({...}) do
		local t = typex(v)

		if t == "client" then
			list.insert(args, v:GetUniqueColor())
			list.insert(args, v:GetNick())
			list.insert(args, ColorBytes(255, 255, 255, 255))
		elseif t == "string" then
			if v == ": sh" or v == "sh" or v:find("%ssh%s") then
				chathud.markup:TagPanic()
			end

			v = v:gsub("<remember=(.-)>(.-)</remember>", function(key, val)
				chathud.emote_shortucts[key] = val
			end)
			v = v:gsub("(:[%a%d]-:)", function(str)
				str = str:sub(2, -2)

				if chathud.emote_shortucts[str] then
					return chathud.emote_shortucts[str]
				end
			end)
			v = v:gsub("\\n", "\n")
			v = v:gsub("\\t", "\t")

			for pattern, font in pairs(chathud.font_modifiers) do
				if v:find(pattern, nil, true) then list.insert(args, #args - 1, font) end
			end

			list.insert(args, v)
		else
			list.insert(args, v)
		end
	end

	event.Call("ChatAddText", args)
	local markup = chathud.markup
	markup:BeginLifeTime(chathud.life_time)
	-- this will make everything added here get removed after said life time
	markup:AddFont(chathud.font) -- also reset the font just in case
	markup:AddTable(args, true)
	markup:AddTagStopper()
	markup:AddString("\n")
	markup:EndLifeTime()
	markup:SetMaxWidth(render2d.GetSize() * pos_mult:Get().x)

	for k, v in pairs(chathud.tags) do
		markup.tags[k] = v
	end
end

function chathud.Draw()
	--render2d.SetTexture() render2d.DrawRect(0,0,render2d.GetSize())
	local markup = chathud.markup
	local _, h = render2d.GetSize()
	local x, y = 30, h * pos_mult:Get().y
	y = y - markup.height
	render2d.PushMatrix(x, y)
	markup:Update()
	markup:Draw()
	render2d.PopMatrix()
end

function chathud.MouseInput(button, press, x, y)
	chathud.markup:OnMouseInput(button, press, x, y)
end

event.AddListener("Chat", "chathud", function(name, str, client)
	local tbl = chat.AddTimeStamp()

	if client:IsValid() then list.insert(tbl, client:GetUniqueColor()) end

	list.insert(tbl, name)
	list.insert(tbl, Color(1, 1, 1, 1))
	list.insert(tbl, ": ")
	list.insert(tbl, str)
	chathud.AddText(unpack(tbl))
end)

function chathud.Show()
	event.AddListener("PreDrawGUI", "chathud", function()
		chathud.Draw()
	end)

	event.AddListener("MouseInput", "chathud", function(button, press)
		chathud.MouseInput(button, press, window.GetMousePosition():Unpack())
	end)
end

function chathud.Hide()
	event.RemoveListener("PostDrawGUI", "chathud")
	event.RemoveListener("PreDrawGUI", "chathud")
	event.RemoveListener("MouseInput", "chathud")
end

if RELOAD then chathud.AddText(utility.BuildRandomWords(40)) end