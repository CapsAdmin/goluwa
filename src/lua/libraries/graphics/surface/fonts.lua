local surface = (...) or _G.surface

surface.registered_fonts = surface.registered_fonts or {}
surface.font_dpi = 72

surface.default_font_path = "fonts/unifont.ttf"

local ready = false
local queue = {}

function surface.InitializeFonts()
	ready = true

	surface.default_font = surface.CreateFont({path = surface.default_font_path})
	surface.SetFont(default_font)

	for _, args in pairs(queue) do
		surface.CreateFont(unpack(args))
	end
end

function surface.SetDefaultFont()
	surface.current_font = surface.default_font
end

function surface.GetDefaultFont()
	return surface.default_font
end

function surface.CreateFont(options, callback)

	if not ready then
		table.insert(queue, {options, callback})
		return
	end

	options = options or {}

	local path = options.path or surface.default_font_path
	local size = options.size or 14
	local scale = options.scale or Vec2(1,1)
	local padding = options.padding or 1
	local fallback = options.fallback
	local filtering = options.filtering or "linear"

	if type(scale) == "number" then
		scale = Vec2()+scale
	end

	if fallback then
		if typex(fallback) ~= "table" then fallback = {options.fallback} end
	end

	local shader = options.shade

	if shader then
		if type(shader) == "string" then
			if not shader:find("return") then
				shader = "return " .. shader
			end
			shader = {source = shader}
		end
		if shader.source then
			shader = {shader}
		end
	end

	local shadow = options.shadow
	local shadow_color = options.shadow_color or Color(0,0,0,0.25)

	if shadow and type(shadow) ~= "number" then
		shadow = size * scale --???
	end

	if shadow then
		shader = shader or {}
		table.insert(shader, {
			source = "return texture(self, uv + dir / size) * vec4(shadow_color.rgb, shadow_color.a) - texture(self, uv);",
			vars = {
				dir = Vec2(-shadow, shadow),
				shadow_color = shadow_color,
			},
		})
	end

	local monospace = options.monospace
	local spacing = options.spacing

	if monospace and not spacing then
		spacing = size
	end

	spacing = spacing or 1

	for class_name, _ in pairs(surface.registered_fonts) do
		local self = prototype.CreateDerivedObject("font", class_name)

		self.pages = {}
		self.chars = {}
		self.state = "reading"

		self:SetName(path)
		self:SetPath(path)
		self:SetSize(size)
		self:SetScale(scale)
		self:SetPadding(padding)
		self:SetFallbackFonts(fallback)
		self:SetShadingInfo(shader)
		self:SetShadow(shadow)
		self:SetShadowColor(shadow_color)
		self:SetMonospace(monospace)
		self:SetSpacing(spacing)
		self:SetFiltering(filtering)

		self.OnLoad = function(...)
			self:SetReady(true)
			event.Call("FontChanged", self, options)
		end

		local ok, err = pcall(self.Initialize, self, options)

		if ok and err ~= false then
			surface.InvalidateFontSizeCache(self)
			return self
		else
			if err ~= false or surface.debug then
				llog("%s: failed to load font %s %q", class_name, self, err)
			end

			self:Remove()
		end
	end

	return surface.default_font
end

function surface.RegisterFont(meta)
	meta.TypeBase = "base"
	meta.Type = "font"

	prototype.Register(meta)

	surface.registered_fonts[meta.ClassName] = meta
end

function surface.SetFont(font)
	surface.current_font = font or surface.default_font
end

function surface.GetFont()
	return surface.current_font
end

function surface.FindFont(name)
	for _, font in ipairs(prototype.GetCreated(true, "font")) do
		if font:GetName():compare(name) then
			return font
		end
	end
	return surface.default_font
end

local X, Y = 0, 0

function surface.DrawText(str, x, y, w)
	local ux,uy,uw,uh,usx,usy = surface.GetRectUV()
	local old_tex = surface.GetTexture()
	local r,g,b,a = surface.GetColor()

	x = x or X
	y = y or Y

	local font = surface.current_font

	if not font or not font:IsReady() then
		surface.SetTexture(render.GetLoadingTexture())
		surface.DrawRect(x,y,32,32)
	else
		font:DrawString(str, x, y, w)
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
	local cache = utility.CreateWeakTable()

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

		cache[font] = cache[font] or utility.CreateWeakTable()
		cache[font][str] = cache[font][str] or utility.CreateWeakTable()
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
		return str:split("")
	end

	local lines = {}

	local last_pos = 0
	local line_width = 0
	local found = false

	local space_pos

	for pos, char in pairs(str:utotable()) do
		local w = surface.GetTextSize(char)

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