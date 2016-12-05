local fonts = ... or {}

fonts.registered_fonts = fonts.registered_fonts or {}
fonts.font_dpi = 72

fonts.default_font_path = "fonts/unifont.ttf"

local ready = false
local queue = {}

function fonts.Initialize()
	ready = true

	fonts.default_font = fonts.CreateFont({path = fonts.default_font_path})
	gfx.SetFont(fonts.default_font)

	for _, args in pairs(queue) do
		fonts.CreateFont(unpack(args))
	end
end

function fonts.CreateFont(options, callback)

	if not ready then
		table.insert(queue, {options, callback})
		return
	end

	options = options or {}

	local path = options.path or fonts.default_font_path
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
				dir = type(shadow) ~= "number" and Vec2(-shadow.x, shadow.y) or Vec2(-shadow, shadow),
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

	for class_name, _ in pairs(fonts.registered_fonts) do
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

		self.OnLoad = function()
			self:SetReady(true)
			event.Call("FontChanged", self, options)
		end

		local ok, err = pcall(self.Initialize, self, options)

		if ok and err ~= false then
			if gfx then
				gfx.InvalidateFontSizeCache(self)
			end
			return self
		else
			if err ~= false or fonts.debug then
				llog("%s: failed to load font %s %q", class_name, self, err)
			end

			self:Remove()
		end
	end

	return fonts.default_font
end

function fonts.FindFont(name)
	for _, font in ipairs(prototype.GetCreated(true, "font")) do
		if font:GetName():compare(name) then
			return font
		end
	end
	return fonts.default_font
end

function fonts.RegisterFont(meta)
	meta.TypeBase = "base"
	meta.Type = "font"

	prototype.Register(meta)

	fonts.registered_fonts[meta.ClassName] = meta
end

runfile("base_font.lua")
runfile("fonts/*", fonts)

if RELOAD then
	fonts.Initialize()
end

return fonts