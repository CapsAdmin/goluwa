chathud = { 
	font_translate = {
		-- usage
		-- chathud.font_translate.chathud_default = "my_font"
		-- to override fonts
	},
	config = {
		max_width = 500,
		max_height = 1200,
		height_spacing = 3,
		history_life = 20,
		
		extras = {
			["...."] = {type = "font", val = "DefaultFixed"},
			["!!!!"] = {type = "font", val = "Trebuchet24"},
			["!!!!!11"] = {type = "font", val = "DermaLarge"},
		},
		
		smiley_translate =
		{
			v = "vee",
		},	

		shortcuts = {		
			smug = "<texture=masks/smug>",
			downs = "<texture=masks/downs>",
			saddowns = "<texture=masks/saddowns>",
			niggly = "<texture=masks/niggly>",
			colbert = "<texture=masks/colbert>",
			eli = "<texture=models/eli/eli_tex4z,4>",
			bubu = "<remember=bubu><color=255,80,50><texture=materials/hud/killicons/default.vtf,50>  <translate=0,-15><color=148,61,148><font=ChatFont>Bubu<color=255,255,255>:</translate></remember>",
			acchan = "<remember=acchan><translate=20,-35><scale=1,0.6><texture=http://www.theonswitch.com/wp-content/uploads/wow-speech-bubble-sidebar.png,64></scale></translate><scale=0.75,1><texture=http://img1.wikia.nocookie.net/__cb20110317001632/southparkfanon/images/a/ad/Kyle.png,64></scale></remember>",
		}
		
	},
	fonts = {
		default = {
			name = "chathud_default",
			data = {
				path = "Roboto",
				size = 15,
				weight = 600,
				antialias = true,
				shadow = true,
				prettyblur = 1,
			} ,
		}
	},
	tags = {},
}
 
if surface.DrawFlag then
	chathud.tags.flag =
	{		
		arguments = {"gb"},
		
		draw = function(markup, self, x,y, flag)
			surface.DrawFlag(flag, x, y - 12)
		end,
	}
end

for _, v in pairs(vfs.Find("textures/silkicons/")) do
	chathud.config.shortcuts[v:gsub("(%.png)$","")] = "<texture=textures/silkicons/" .. v .. ",16>"
end

for name, data in pairs(chathud.fonts) do
	surface.CreateFont(data.name, data.data)
end

local chathud_show = console.CreateVariable("cl_chathud_show", 1)
local height_mult = console.CreateVariable("cl_chathud_height_mult", 0.76)
local width_mult = console.CreateVariable("cl_chathud_width_mult", 0.6)

chathud.markup =  surface.CreateMarkup()
chathud.markup:SetEditable(false)
chathud.life_time = 20

function chathud.AddText(...)
	local args = {}
		
	for k,v in pairs({...}) do
		local t = typex(v)
		if t == "client" then
			table.insert(args, v:GetUniqueColor())
			table.insert(args, v:GetNick())
			table.insert(args, Color(255, 255, 255, 255))
		elseif t == "string" then
		
			if v == ": sh" or v == "sh" or v:find("%ssh%s") then
				chathud.markup:TagPanic()
			end
		
			v = v:gsub("<remember=(.-)>(.-)</remember>", function(key, val) 
				chathud.config.shortcuts[key] = val
			end)
		
			v = v:gsub("(:[%a%d]-:)", function(str)
				str = str:sub(2, -2)
				if chathud.config.shortcuts[str] then
					return chathud.config.shortcuts[str]
				end
			end)
			
			v = v:gsub("\\n", "\n")
			v = v:gsub("\\t", "\t")
			
			for pattern, font in pairs(chathud.config.extras) do
				if v:find(pattern, nil, true) then
					table.insert(args, #args-1, font)
				end
			end
						
			table.insert(args, v)
		else
			table.insert(args, v)
		end
	end
	 
	local markup = chathud.markup
	
	markup:BeginLifeTime(chathud.life_time)
		-- this will make everything added here get removed after said life time
		markup:AddFont("chathud_default") -- also reset the font just in case
		markup:AddTable(args, true)
		markup:AddTagStopper()
		markup:AddString("\n")
	markup:EndLifeTime()
	
	markup:SetMaxWidth(surface.GetScreenSize() * width_mult:Get())
		
	for k,v in pairs(chathud.tags) do
		markup.tags[k] = v
	end
end
   
function chathud.Draw()
	local markup = chathud.markup
	
	local w, h = surface.GetScreenSize()
	local x, y = 30, h * height_mult:Get()
	
	y = y - markup.height
	
	surface.PushMatrix(x,y)
		markup:Draw(x, y, w, h, mat)
	surface.PopMatrix()
end

function chathud.MouseInput(button, press, x, y)
	chathud.markup:OnMouseInput(button, press, x, y)
end

event.AddListener("DrawHUD", "chathud", function()
	chathud.Draw()
end)

event.AddListener("MouseInput", "chathud", function(button, press)
	chathud.MouseInput(button, press, window.GetMousePos():Unpack())
end)

include("tradingcard_emotes.lua")