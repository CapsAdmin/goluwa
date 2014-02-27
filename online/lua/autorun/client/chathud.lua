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
		}
		
	},
	fonts = {
		default = {
			name = "chathud_default",
			data = {
				font = "Verdana",
				size = 36,
				weight = 600,
				antialias = true,
				shadow = true,
				prettyblur = 1,
			} ,
		},
		
		chatprint = {
			name = "chathud_chatprint",
			color = Color(201, 255, 41, 255),
			data = {
				font = "Verdana",
				size = 16,
				weight = 600,
				antialias = true,
				shadow = true,
				prettyblur = 1,
			},
		},
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

for _, v in pairs(vfs.Find("materials/icon16/*.png")) do
	chathud.config.shortcuts[v:gsub("(%.png)$","")] = "<texture=materials/icon16/" .. v .. ",16>"
end

for name, data in pairs(chathud.fonts) do
	surface.CreateFont(data.name, data.data)
end

local chathud_show = console.CreateVariable("cl_chathud_show", 1)
local height_mult = console.CreateVariable("cl_chathud_height_mult", 0.76)
local width_mult = console.CreateVariable("cl_chathud_width_mult", 0.3)

chathud.markup =  Markup()
chathud.markup:SetEditable(false)
chathud.life_time = 20

function chathud.AddText(...)
	local args = {}
		
	for k,v in pairs({...}) do
		local t = typex(v)
		if t == "player" then
			table.insert(args, v:GetUniqueColor())
			table.insert(args, v:GetNick())
			table.insert(args, Color(255, 255, 255, 255))
		elseif t == "string" then
		
			v = v:gsub("(:[%a]-:)", function(str)
				str = str:sub(2, -2)
				if chathud.config.shortcuts[str] then
					return chathud.config.shortcuts[str]
				end
			end)
			
			v = v:gsub("\\n", "\n")
			v = v:gsub("\\t", "\t")
			
			table.insert(args, v)
		else
			table.insert(args, v)
		end
	end
	 
	local markup = chathud.markup
	
	markup:BeginLifeTime(chathud.life_time)
		-- this will make everything added here get removed after said life time
		markup:AddFont("markup_default") -- also reset the font just in case
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


event.AddListener("PreDrawMenu", "chathud", function()
	chathud.Draw()
end)

event.AddListener("OnMouseInput", "chathud", function(button, press)
	chathud.MouseInput(button, press, window.GetMousePos():Unpack())
end)