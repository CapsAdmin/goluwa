local surface = (...) or _G.surface

surface.fonts = surface.fonts or {}
surface.registered_fonts = surface.registered_fonts or {}
surface.font_dpi = 72

local ready = false
local queue = {}

function surface.InitializeFonts()
	ready = true
	
	surface.SetFont(surface.CreateFont("default", {path = "fonts/unifont.ttf"}))
	
	for _, args in pairs(queue) do
		surface.CreateFont(unpack(args))
	end
end

function surface.CreateFont(name, options, callback)
	
	if not ready then
		table.insert(queue, {name, options, callback})
		return
	end
	
	local path = options.path or "fonts/unifont.ttf"
	local size = options.size or 14
	local padding = options.padding or 1
	local fallback = options.fallback
	
	if fallback then 
		if type(fallback) == "string" then fallback = {options.fallback} end
		for k,v in ipairs(fallback) do fallback[k] = surface.fonts[v] end
	end
	
	local shader = options.shade
	
	if shader then
		if shader.source then
			shader = {shader}
		end
	end
	
	local shadow = options.shadow
	local shadow_color = options.shadow_color or Color(0,0,0,0.5)

	if shadow and type(shadow) ~= "number" then
		shadow = size / 10 --???
	end
	
	local monospace = options.monospace
	local spacing = options.spacing
	
	if monospace and not spacing then
		spacing = size
	end
	
	spacing = spacing or 1
	
	surface.fonts[name] = surface.fonts.default
	
	for class_name, _ in pairs(surface.registered_fonts) do
		local self = prototype.CreateDerivedObject("font", class_name)
		
		self:SetName(name)
		self:SetPath(path)
		self:SetSize(size)
		self:SetPadding(padding)
		self:SetFallbackFonts(fallback)
		self:SetShadingInfo(shader)
		self:SetShadow(shadow)
		self:SetShadowColor(shadow_color)
		self:SetMonospace(monospace)
		self:SetSpacing(spacing)
				
		self.OnLoad = function(...)
			self:SetReady(true)
			event.Call("FontChanged", name, options)
		end
		
		local ok, err = pcall(self.Initialize, self)
		
		if ok and err ~= false then		
			surface.fonts[name] = self
			surface.InvalidateFontSizeCache(name)
			
			return self
		else
			if err ~= false or surface.debug then
				debug.trace()
				logf("%s: failed to load font %s %q\n", class_name, name, err)
			end
			
			self:Remove()
		end
	end
end

function surface.RegisterFont(meta)
	meta.TypeBase = "base"
	meta.Type = "font"
	
	prototype.Register(meta)
	
	surface.registered_fonts[meta.ClassName] = meta
end

function surface.SetFont(font)
	surface.current_font = surface.fonts[font] or surface.fonts.default
end

function surface.GetFont()
	return surface.current_font
end

local X, Y = 0, 0

function surface.DrawText(str, x, y)
	
	local ux,uy,uw,uh,usx,usy = surface.GetRectUV()
	local old_tex = surface.GetTexture()
	local r,g,b,a = surface.GetColor()
	
	x = x or X
	y = y or Y
	
	local font = surface.current_font
	
	if not font or not font:IsReady() then
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
	else
		font:DrawString(str, x, y)
	end
	
	surface.SetRectUV(ux,uy,uw,uh,usx,usy)
	surface.SetTexture(old_tex)
	surface.SetColor(r,g,b,a)
end

function surface.SetTextPosition(x, y)
	X = x or X
	Y = y or Y
end

do
	local cache = {}

	function surface.GetTextSize(str)
		local font = surface.current_font
		
		if not font then
			return 0,0
		end
		
		if not font:IsReady() then
			return font.Size, font.Size
		end
		
		if cache[font] and cache[font][str] then 
			return cache[font][str][1], cache[font][str][2] 
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

include("base_font.lua")
include("fonts/*", surface)

if RELOAD then
	surface.InitializeFonts()
end