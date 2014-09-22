--[[
All surface.fonts must implement:
number :GetHeight()
w, h:GetTextSize(text)
x, y :DrawString(str, x, y)
.options (a ref to the options table)

surface.AddFontLoader{.AttemptLoad(<binaryData>, options, callback(suc, errmsg/metatable))}
]]

local surface = (...) or _G.surface

surface.fonts = surface.fonts or {}
surface.font_loaders = surface.font_loaders or {}
surface.font_dpi = 72

local initted = false
local queue = {}

function surface.InitializeFonts()
	surface.CreateFont("default", {path = "fonts/unifont.ttf"})
	
	initted = true
	
	for k,v in pairs(queue) do
		surface.CreateFont(unpack(v))
	end
end

function surface.CreateFont(name, options, callback)
	
	if not initted then
		table.insert(queue, {name, options, callback})
		surface.fonts[name] = "loading"
		return
	end
	
	options = options or {}
	options.path = options.path or "fonts/unifont.ttf"
	options.size = options.size or 14
	
	if options.monospace and not options.spacing then
		options.spacing = options.size
	end
	
	options.spacing = options.spacing or 1
			
	surface.fonts[name] = "loading"
	
	for loader_name, font_loader in pairs(surface.font_loaders) do		
		local ok, res = pcall(font_loader.LoadFont, name, options, function(...)
			event.Call("FontChanged", name, options)
			if callback then
				callback(...)
			end
		end)
		if ok then
			res.font_options = options
			res.font_loader = loader_name
			res.font_name = name
			surface.fonts[name] = res
			return
		end
		if surface.debug then
			logf("%s failed to load font %s: %s\n", font_loader.Name, name, res)
		end
	end
	
	surface.fonts[name] = "default"
	
	surface.InvalidateFontSizeCache(name)
end

function surface.RegisterFontLoader(tbl)
	tbl.Type = "surface_font_" .. tbl.Name
	surface.font_loaders[tbl.Name] = prototype.CreateTemplate(tbl)
	
	for k, v in pairs(surface.fonts) do
		if v.font_loader == tbl.Name then
			surface.CreateFont(v.font_name, v.font_options)
		end
	end
	surface.InvalidateFontSizeCache(font)
end

local font = "default"

function surface.SetFont(name)
	if not surface.fonts[name] then 
		return 
	end
	font = name
end

local X, Y = 0, 0

function surface.DrawText(str, x, y)
	
	local ux,uy,uw,uh,usx,usy = surface.GetRectUV()
	local old_tex = surface.GetTexture()
	local r,g,b,a = surface.GetColor()

	do
		x = x or X
		y = y or Y
		
		local font = surface.fonts[font]
		
		if not font then return end
		
		if font == "loading" or font.state ~= "loaded" then
			surface.SetColor(0.8, 0.8, 0.8, 1)
			surface.SetWhiteTexture()
			surface.DrawRect(x, y, 32, 32)
			local deg = 360 / 8
			for i = 0, 7 do
				local n=0
				if math.floor(os.clock()*5)%18>=9 then
					n = ((math.floor(os.clock()*5) % 9) - i)
				else
					n = 1-(((math.floor(os.clock()*5)+9) % 9) - i)
				end
				surface.SetColor(n, n, n, 1)
				local ang = math.rad(deg * i)
				local X, Y = math.sin(ang), math.cos(ang)
				surface.DrawLine(X*2+16, Y*2+16, X*16 + 16, Y*16 + 16, 2)
			end
			return
		end
		
		font:DrawString(str, x, y)
	end
	
	surface.SetRectUV(ux,uy,uw,uh,usx,usy)
	surface.SetTexture(old_tex)
	surface.SetColor(r,g,b,a)
end

function surface.SetTextPos(x, y)
	X = x or X
	Y = y or Y
end

do
	local cache = {}

	function surface.GetTextSize(str)
		local font = surface.fonts[font]
		
		if cache[font] and cache[font][str] then 
			return cache[font][str][1], cache[font][str][2] 
		end
		
		if not font then return 0, 0 end
		
		if font == "loading" or font.state ~= "loaded" then
			return 32, 32
		end
			
		local x, y = font:GetTextSize(str)
		
		cache[font] = cache[font] or {}
		cache[font][str] = cache[font][str] or {}
		cache[font][str][1] = x
		cache[font][str][2] = y
		
		return x, y
	end
	
	function surface.InvalidateFontSizeCache(font)
		if font then
			print(cache[font])
			cache[font] = nil
		else
			cache = {}
		end
	end
end

function surface.WrapString(str, max_width)
	if not max_width or max_width == 0 then
		return str:explode("")
	end
	
	local lines = {}
	
	local last_pos = 0
	local line_width = 0
	local found = false

	local space_pos

	for pos, char in pairs(str:utotable()) do
		local w, h = surface.GetTextSize(char)

		if char:find("%s") then
			space_pos = pos
		end

		if line_width + w >= max_width then

			if space_pos then
				lines[#lines+1] = str:usub(last_pos+1, space_pos)
				last_pos = space_pos
			else
				lines[#lines+1] = str:usub(last_pos+1, pos)
				last_pos = pos
			end

			line_width = 0
			found = true
			space_pos = nil
		else
			line_width = line_width + w
		end
	end

	if found then
		lines[#lines+1] = str:usub(last_pos+1, pos)
	else
		lines[#lines+1] = str
	end

	return lines
end

include("font_loaders/*", surface)

if RELOAD then
	surface.InitializeFonts()
end