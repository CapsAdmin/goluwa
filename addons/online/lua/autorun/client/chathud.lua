
-- lol
surface.SetTextColor = surface.Color
surface.SetDrawColor = surface.Color
local RealTime = glfw.GetTime

local default_font = "chathud"

local chatprint_font  = "chattextalt2"
local chatprint_color = Color(201, 255, 41, 255)

local max_width = 500
local height_spacing = 3
local history_life = 20

local created = false
local default_font_blur = default_font .. "_blur"

local function create_fonts()

	surface.CreateFont(default_font, 
		{
			path = "fonts/arial.ttf", 
			size = 15, 
			antialias = true,
			weight = 600,
		}
	)

	surface.CreateFont(chatprint_font, 
		{
			path = "fonts/arial.ttf",
			size = 15, 
			weight = 800,
			antialias = true,
			shadow = true,
		}
	)
	
	created = true
end

local extras = 
{
	["...."] = {type = "font", val = "DefaultFixed"},
	["!!!"] = {type = "font", val = "Trebuchet24"},
	--["!!1"] = {type = "font", val = "HUDNumber5"},
}

local FONT = default_font
local R,G,B,A = 1,1,1,1
local X,Y = 0,0

local function surface_DrawText(text)
	surface.DrawText(text)
end

local function surface_SetTextColor(r, g, b, a)
	surface.SetTextColor(r,g,b,a)
	R = r
	G = g
	B = b
	A = a
end

local function surface_SetTextPos(x, y)
	surface.SetTextPos(x, y)
	X = x
	Y = y
end

local function surface_SetFont(font)
	if not created then
		create_fonts()
	end
	surface.SetFont(font)
	FONT = font
end

local smiley_translate = 
{
	v = "vee",
} 

local shortcuts = {}
for v in vfs.Iterate("textures/silkicons/") do
	shortcuts[v:match("(.-)%.")] = "<texture=" .. "textures/silkicons/" .. v .. ">"
end

-- internal
local SafeSetFont

local history = {}
local variables = {}
local time_speed = 1
local time_offset = 0
--


local lib = 
{
	PI = math.pi,
	rand = math.random,
	random = math.random,
	randx = function(a,b)
		a = a or -1
		b = b or 1
		return math.Rand(a, b)
	end,
	
	abs = math.abs,
	acos = math.acos,
	asin = math.asin,
	atan = math.atan,
	atan2 = math.atan2,
	ceil = math.ceil,
	cos = math.cos,
	cosh = math.cosh,
	deg = math.deg,
	exp = math.exp,
	floor = math.floor,
	frexp = math.frexp,
	ldexp = math.ldexp,
	log = math.log,
	log10 = math.log10,
	max = math.max,
	min = math.min,
	rad = math.rad,
	sin = math.sin,
	sinh = math.sinh,
	sqrt = math.sqrt,
	tanh = math.tanh,
	tan = math.tan,
	
	clamp = math.Clamp,
	time = RealTime,
}

local blacklist = {"repeat", "until", "function", "end"}

local expressions = {}

local function compile_expression(str, extra_lib)
	local source = str

	for _, word in pairs(blacklist) do
		if str:find("[%p%s]" .. word) or str:find(word .. "[%p%s]") then
			return false, string.format("illegal characters used %q", word)
		end
	end
	
	local functions = {}
	
	for k,v in pairs(lib) do functions[k] = v end
	
	if extra_lib then
		for k,v in pairs(extra_lib) do functions[k] = v end
	end
	
	functions.select = select
	str = "local input = select(1, ...) return " .. str
	
	local func, err = loadstring(str)
	
	if not func then
		return false, err
	else
		setfenv(func, functions)
		expressions[func] = source
		return true, func
	end
end


local commands = 
{
	hsv = 
	{
		arguments = {0, 1, 1},
		
		draw = function(self, x,y,a, h, s, v)
			local c = HSVToColor(h, s, v)
			surface_SetTextColor(c.r, c.g, c.b, 1)
			surface.SetDrawColor(c.r, c.g, c.b, 1)
		end,
	},
	
	color = 
	{
		arguments = {1, 1, 1, 1},
		
		draw = function(self, x,y,a, r,g,b,a)
			surface_SetTextColor(r, g, b, a)
			surface.SetDrawColor(r, g, b, a)
		end,
	},
	
	physics = 
	{
		arguments = {1, 0, 0, 0, 0.99, 0.1},
		
		pre = function(self, gx, gy, vx, vy, drag, rand_mult)
			local part = {}
			
			part =
			{
				pos = {x = 0, y = 0},
				vel = {x = vx, y = vy},
				siz = 10,
				rand_mult = rand_mult,
				drag = drag,
			}
			
			self.part = part
		end,
		
		draw = function(self, x,y,a, gravity_y, gravity_x, vx, vy, drag, rand_mult)
			local delta = FrameTime() * 5
			local rand = math.Rand
			
			local part = self.part
			
			local center = Vector(x, y - 10, 0)
			local W, H = max_width/2, ScrH()
			
			W = W - center.x
			H = H - center.y
			
			-- random velocity for some variation
			part.vel.y = part.vel.y + gravity_y + (math.Rand(-1,1) * rand_mult)
			part.vel.x = part.vel.x + gravity_x + (math.Rand(-1,1) * rand_mult)
			
			-- velocity
			part.pos.x = part.pos.x + (part.vel.x * delta)
			part.pos.y = part.pos.y + (part.vel.y * delta)
			
			-- friction
			part.vel.x = part.vel.x * part.drag
			part.vel.y = part.vel.y * part.drag
			
			-- collision
			if part.pos.x - part.siz < -center.x then
				part.pos.x = -center.x + part.siz
				part.vel.x = part.vel.x * -part.drag
			end
			
			if part.pos.x + part.siz > W then
				part.pos.x = W - part.siz
				part.vel.x = part.vel.x * -part.drag
			end
			
			if part.pos.y - part.siz < -center.y then
				part.pos.y = -center.y + part.siz
				part.vel.y = part.vel.y * -part.drag
			end
			
			if part.pos.y + part.siz > H then
				part.pos.y = H - part.siz
				part.vel.y = part.vel.y * -part.drag
			end
			
			local mat = Matrix()
			
			mat:Translate(Vector(part.pos.x, part.pos.y))
			
			cam.PushModelMatrix(mat)
		end,
		
		post = function()
			cam.PopModelMatrix()
		end,
	},
	
	matrix = 
	{
		arguments = {0, 0, 1, 1, 0, 0, 0},
		
		draw = function(self, x,y,a, pos_x, pos_y, scale_x, scale_y, angle, center_x, center_y)
			local mat = Matrix()
			
			local center = Vector(x, y, 0)
			mat:Translate(center)
				mat:Translate(Vector(pos_x, pos_y, 0))
				mat:Scale(Vector(scale_x, scale_y, 1))
				mat:Translate(Vector(center_x, center_y, 0))
					mat:Rotate(Angle(0, angle, 0))
				mat:Translate(-Vector(center_x, center_y, 0))
			mat:Translate(-center)
			
			cam.PushModelMatrix(mat)
		end,
		
		post = function()
			cam.PopModelMatrix()
		end,
	},
	
	font = 
	{
		arguments = {default_font},
		
		draw = function(self, x,y,a, font)
			SafeSetFont(font)
		end,
		
		pre = function(self, font)
			SafeSetFont(font)
		end,
	},
	
	texture = 
	{
		arguments = {"error", {default = 1, min = 1, max = 4}},
		
		pre = function(self, path)
						
			if false and pac and path:find("http") then
				mat = CreateMaterial("fishing_hud_rc_" .. util.CRC(path) .. "_" .. FrameNumber(), "UnlitGeneric", {})

				pac.urltex.GetMaterialFromURL(path, function(_mat)
					mat:SetTexture("$basetexture", _mat:GetTexture("$basetexture"))
				end, nil, "UnlitGeneric", size, false)

				mat:SetFloat("$alpha", 0.999)
			end
			
			self.tex = Image(path)
		end,

		get_size = function(self, path, size_mult)
			local size = 16 * size_mult
			return size, size
		end,
		
		draw = function(self, x,y,a, path, size_mult)
			local size = 16 * size_mult
			surface.SetTexture(self.tex)
			surface.DrawRect(x, y, size, size)
		end,
	}
}

commands.matrix = nil
commands.font = nil
commands.physics = nil

local function run_tag(line, name, ...)
	if not line.val.cmd then return end
	if line.type == "custom" then
		local func = line.val.cmd and line.val.cmd[name]
		if func then
			
			local sigh = {line, ...}
			for k,v in pairs(line.val.args) do
				if type(v) == "function" then
					local ok, val = pcall(v, line.exp_env)
					if ok and val then
						v = val
					else
						v = line.val.cmd.arguments[k]
						if type(v) == "table" then
							v = v.default
						end
					end
				end
				table.insert(sigh, v)
			end
			
			local args = {pcall(func, unpack(sigh))}
			
			if not args[1] then
				event.RemoveListener("DrawHUD", "chathud")
				history = {}
				error(string.format("tag error %s", args[2]))
			else
				return select(2, unpack(args))
			end
		end
	end
end

local height_mult = console.CreateVariable("chathud_height_mult", 0.76)
local width_mult = console.CreateVariable("chathud_width_mult", 0.5)

local panic = false

local function show_text(markup)
	
	-- these two arent really used here only but lets update them here
	-- incase you change res
	local w, h = surface.GetScreenSize()
	max_width = w * width_mult:Get()
	max_height = h * height_mult:Get()
	
	markup.life_time = RealTime() + history_life
	table.insert(history, 1, markup)
	
	event.AddListener("DrawHUD", "chathud", function()
		
		local history_x = 45
		local history_y = max_height
		
		for i, markup in pairs(history) do
			history_y = history_y - markup.h
			local alpha = math.clamp(markup.life_time - RealTime(), 0, 1) ^ 5
			
			-- reset font and color for every line
			surface.SetAlphaMultiplier(alpha)
			surface_SetFont(default_font)
			surface_SetTextColor(1, 1, 1, 1)
			surface.SetDrawColor(1, 1, 1, 1) 
			
			-- debug
			--surface.SetDrawColor(255, 0, 0, 255)
			--surface.DrawOutlinedRect(history_x, history_y, markup.w, markup.h)
			
			for _, data in pairs(markup.data) do
				local x = history_x + data.x
				local y = history_y + data.y
				
				if y < 0 then goto continue end
				if x < 0 then goto continue end
	
				if data.type == "font" then
					SafeSetFont(data.val)
				elseif data.type == "string" then
					surface_SetTextPos(x, y)
					surface_DrawText(data.val)
				elseif data.type == "color" then
					local c = data.val
					
					surface_SetTextColor(c.r, c.g, c.b, c.a * alpha)
				elseif data.type == "custom" and not data.stop then
					data.started = true
					run_tag(data, "draw", x, y, alpha)
				end
			end
			
			for _, data in pairs(markup.data) do
				if data.type == "custom" then
					if not data.stop and data.started and data.val.cmd and data.val.cmd.post then
						data.started = false
						run_tag(data, "post")
					end
					
					if panic then
						data.stop = true
					end
				end
			end
			
			if alpha == 0 then
				table.remove(history, i)
			end
			
			::continue::
		end

		surface.SetAlphaMultiplier(1)
	
	end)
end

local unsafe = {}
SafeSetFont = function(font)
	do surface.SetFont(font) return end

	if unsafe[font] then surface_SetFont(default_font) return end

	local ok, msg = pcall(surface_SetFont, font)
	if not ok then
		unsafe[font] = true
		SafeSetFont(font)
	end
end

local function split_text(str, maxwide)
	local lines = {}
	local pos = 0
	local last_pos = 0
	local wide = 0
	local found = false
	
	local space_pos
	
	for char in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		pos = pos + #char
		
		local w, h = surface.GetTextSize(char == "&" and "%" or char)
		
		w = w or 0
		h = h or 0
		
		if char == " " then
			space_pos = pos
		end

		if wide + w >= maxwide then
			if space_pos then
				table.insert(lines, str:sub(last_pos+1, space_pos))
				last_pos = space_pos
			else
				table.insert(lines, str:sub(last_pos+1, pos))
				last_pos = pos
			end
			
			wide = 0
			found = true
			space_pos = nil
		else
			wide = wide + w
		end
    end
	
	if found then
		table.insert(lines, str:sub(last_pos+1, pos))
	else
		table.insert(lines, str)
	end
	
	return lines
end

local last_font	= default_font

-- grabbin puke!!!!!!!!!!!!!!!!!!!!
local function to_args(str)
	str = str .. ","
	local out =  {}
	local expressions = {}
	
	str = str:gsub("(%[.-%]),", function(expression)
		local id =  "__" .. expression .. "__"
		expressions[id] = expression:sub(2, -2)
		return id .. ","
	end)
	
	for arg in str:gmatch("(.-),") do
		if expressions[arg]	 then
			local ok, func = compile_expression(expressions[arg])
			if func then
				table.insert(out, func)
			else
				logf("chathud expression error: %s", func)
				table.insert(out, 0)
			end
		else
			table.insert(out, arg)
		end
	end
	
	return out
end

if luadata then
	variables = luadata.ReadFile("chathud_variables.txt")
	for _, set in pairs(variables) do
		for _, data in pairs(set) do
			data.cmd = commands[data.cmd]
			
			for i, arg in pairs(data.args) do
				if type(arg) == "table" and arg.type == "expression" then
					local ok, func = compile_expression(arg.val)
					if func then
						data.args[i] = func
					else
						logf("chathud expression error: %s", func)
						data.args[i] = 0
					end
				end
			end
		end
	end
end

local function to_markup(str)
	local data = {}
	local found = false
	
	local in_tag = false
	local current_string = {}
	local current_tag = {}
	
	-- just used for <r>
	local tags = {}
	
	for char in str:gmatch("(.)") do
		if char == "<" then
			if current_string then
				table.insert(data, table.concat(current_string, ""))
			end
			
			current_tag = {}
			in_tag = true
		elseif char == ">" and in_tag then
			if current_tag then
				local input = table.concat(current_tag, "") .. ">"
				local cmd, args = input:match("<(.-)=(.+)>")
				
				if not cmd and not args then
					cmd = input:match("<(.-)>")
				end
				
				local info = commands[cmd]
				
				if info then
					local args = to_args(args or "")
					
					for i = 1, #info.arguments do
						local arg = args[i]
						local default = info.arguments[i]
						local t = type(default)
						
						if t == "number" then
							local num = tonumber(arg)
							
							if not num and type(arg) == "function" then
								num = arg
							end
							
							args[i] = num or default
						elseif t == "string" then
							if not arg or arg == "" then
								arg = default
							end
							
							args[i] = arg
						elseif t == "table" then
							if default.min or default.max or default.default then
								local num = tonumber(arg)
								
								if num then
									if default.min and default.max then
										args[i] = math.Clamp(num, default.min, default.max)
									elseif default.min then
										args[i] = math.min(num, default.min)
									elseif default.max then
										args[i] = math.max(num, default.max)
									end
								else
									if type(arg) == "function" then
										if default.min and default.max then
											args[i] = function(...) return math.Clamp(arg(...) or default.default, default.min, default.max) end
										elseif default.min then
											args[i] = function(...) return math.min(arg(...) or default.default, default.min) end
										elseif default.max then
											args[i] = function(...) return math.max(arg(...) or default.default, default.max) end
										end
									else
										args[i] = default.default
									end
								end
							end
						end
					end
					
					found = true
					
					local tag = {cmd = info, type = cmd, args = args}
					table.insert(data, tag)
					
					-- for special tags
					table.insert(tags, tag)
				else
					if cmd == "repeat" or cmd == "r" then
						local args = to_args(args or "")
						local count = tonumber(args[1]) or 1
						
						for i = 0, count - 1 do
							local last = tags[#tags - i]
							if last then
								table.insert(data, last)
							else
								break
							end
						end
						
						found = true
					elseif cmd == "remember" and args then
						local args = to_args(args)
						
						if args[1] then
							local id = tostring(args[1])
							if id == "" then return end
							
							local count = tonumber(args[1]) or #tags
							
							local set = {}
							
							for i = 0, count - 1 do
								local last = tags[#tags - i]
								if last then
									table.insert(set, 1, last)
								else
									break
								end
							end
							
							variables[id] = set
							found = true
							
							if luadata then
								local store = table.Copy(set)
								for _, data in pairs(store) do
									data.cmd = data.type
									for i, arg in pairs(data.args) do
										local str = expressions[arg]
										if str then
											data.args[i] = {type = "expression", val = str}
										end
									end
								end
								luadata.SetKeyValueInFile("chathud_variables.txt", id, store)
							end
						end
					elseif (cmd == "variable" or cmd == "var" or cmd == "v") and args then
						local args = to_args(args)
						local set = variables[args[1]]
						
						if set then
							for k,v in pairs(set) do
								table.insert(data, v)
							end
							found = true
						end
					end
				end
			end
			
			current_string = {}
			in_tag = false
		end
		
		if in_tag then
			table.insert(current_tag, char)
		elseif char ~= ">" then
			table.insert(current_string, char)
		end
	end
	
	if found then
		table.insert(data, table.concat(current_string, ""))
	else
		data = {str}
	end
	
	return data
end

local function parse_string(markup, str)
	for i, var in pairs(to_markup(str)) do
		if type(var) == "string"  then
			table.insert(markup, {type = "string", val = var})
		else
			table.insert(markup, {type = "custom", val = var})
		end
	end
end

-- just for readability really

local function is_color(var)
	return var.r and var.g and var.b
end

local function is_font(var)
	return #var == 1 and type(var[1]) == "string"
end

local function add_extra(markup, find, add)
	for i, data in pairs(markup) do
		if data.type == "string" and data.val and data.val:find(find, nil, true) then
			
			table.insert(markup, 1, add)
			return
		end
	end
end

local function parse_addtext(args)
	
	if panic then
		panic = false
	end
	
	local is_maybe_player_chat = false
	
	-- preprocess :something: to <texture=something>
	for k,v in pairs(args) do
		if type(v) == "string" then
			for _k, _v in pairs(smiley_translate) do
				v = v:gsub(":" .. _k .. ":", ":" .. _v .. ":")
			end
			args[k] = v:gsub("(:%l-:)", function(str)
				str = str:sub(2, -2)
				
				if variables[str] then
					return "<v=" .. str .. ">"
				end
				
				if shortcuts[str] then
					return shortcuts[str]
				end
			end)
		end
	end

	-- normalize everything into a consistent markup table
	-- strings are also parsed
	local markup = {}
	
	for i, var in pairs(args) do
		local t = typex(var)
		
		if t == "player" then
			table.insert(markup, {type = "color", val = chatprint_color})
			table.insert(markup, {type = "string", val = var:GetNick()})
			table.insert(markup, {type = "color", val = color_white})
			
			is_maybe_player_chat = true
		elseif t == "string" then
			if var:sub(1, 2) == ": " then
				is_maybe_player_chat = true
			end
			
			if is_maybe_player_chat and (var == ": sh" or var:find("%ssh%s")) then
				panic = true
			end
			parse_string(markup, var)
			
		elseif t == "color" then
			table.insert(markup, {type = "color", val = var})
		elseif t == "table" then
			if is_font(var) then
				table.insert(markup, {type = "font", val = var[1]})
			end
		else
			logf("tried to parse unknown type %q", t)
		end

	end
	
	-- concatenate all repeated strings to properly work with with splitting and better performance
	local concatenated = {}
	local last_data = {}
	
	for i, data in pairs(markup) do
		
		if data.type == "color" and markup[i+1] and markup[i+1].type == "color"  then goto continue end
		
		if last_data.type == "string" and data.type == "string" then
			last_data.val = last_data.val .. data.val
		else
			table.insert(concatenated, data)
			last_data = data
		end
		
		::continue::
	end
	
	for key, val in pairs(extras) do
		add_extra(concatenated, key, val)
	end
	
	surface_SetFont(default_font)
	
	-- get the size of each object
	local temp = {}
	
	for i, data in pairs(concatenated) do
		if data.type == "font" then
			SafeSetFont(data.val)
		elseif data.type == "string" and data.val then
			-- this really should be done in the previous loop..
			for _, str in pairs(split_text(data.val, max_width)) do
				local w, h = surface.GetTextSize(str)
				table.insert(temp, {type = "string", val = str, w = w, h = h, x = 0, y = 0})
			end
			
			goto continue
		elseif data.type == "custom" then
			local info = data.val.cmd
			
			local w, h = run_tag(data, "get_size")
			data.w = w
			data.h = h
			
			run_tag(data, "pre")
		end
		
		-- for consistency sake everything should have x y w h
		data.x = data.x or 0
		data.y = data.y or 0
		data.w = data.w or 0
		data.h = data.h or 0
		
		table.insert(temp, data)
		
		::continue::
	end
	
	-- split it up if needed
	
	local markup = {w = 0, h = 0, data = {}}
	
	local y = 0
	
	local width = 0
	
	local split = false
	local line_height = 0
	
	for i, data in pairs(temp) do
		data.x = width
		data.y = y
		
		width = width + data.w

		-- figure out how tall this line is
		if data.h > line_height then
			line_height = data.h
		end
		
		if width + data.w >= max_width and i ~= #temp then
			y = y + line_height
			
			if width > markup.w then
				markup.w = width
			end
			
			width = 0
			split = true
			
			markup.h = markup.h + line_height
		end
		
		table.insert(markup.data, data)
	end
	
	if not split then
		markup.w = width
		markup.h = line_height
		
		for i, data in pairs(markup.data) do
			data.y = line_height - data.h
		end
	else
		markup.h = markup.h + line_height
	end
	
	-- this is for expressions to be use d like line.i+time()
	for i, data in pairs(markup.data) do
		data.exp_env = {i = i, w = data.w, h = data.h, x = data.x, y = data.y, rand = math.random()}
	end
	
	markup.h = markup.h + height_spacing
	
	return markup
end 

local cl_shownewhud = console.CreateVariable("cl_shownewhud", true)

local function add_text(...)
	if not surface.IsReady() then return end
	
	if cl_shownewhud:Get() then
		local data = parse_addtext({...})
		show_text(data)
		
		return true
	else
		event.RemoveListener("DrawHUD", "chathud")
	end
end	

chathud = {AddText = add_text}
