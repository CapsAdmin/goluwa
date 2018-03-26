local fonts = ... or {}

fonts.registered_fonts = fonts.registered_fonts or {}
fonts.font_dpi = 64

fonts.default_font_path = "fonts/unifont.ttf"

local ready = false
local queue = {}

function fonts.Initialize()
	ready = true

	for _, args in ipairs(queue) do
		fonts.CreateFont(unpack(args))
	end
end

function fonts.GetDefaultFont()
	fonts.default_font = fonts.default_font or fonts.CreateFont({path = fonts.default_font_path})

	return fonts.default_font or fonts.GetFallbackFont()
end

function fonts.GetFallbackFont()
	fonts.minifont = fonts.minifont or fonts.CreateFont({type = "fallback_font"})
	return fonts.minifont
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

	local monospace = options.monospace
	local spacing = options.spacing

	if monospace and not spacing then
		spacing = size
	end

	spacing = spacing or 0

	if type(options.shadow) == "number" then
		options.shadow = {
			dir = options.shadow,
			color = options.shadow_color
		}
	end

	local shading_info = options.shader

	if shading_info then
		if type(shading_info) == "string" then
			if not shading_info:find("return") then
				shading_info = "return " .. shading_info
			end
			shading_info = {source = shading_info}
		end

		if shading_info.source then
			shading_info = {shading_info}
		end
	end

	local sorted = {}

	for name, callback in pairs(fonts.effects) do
		if options[name] then
			options[name].order = options[name].order or 0
			table.insert(sorted, {info = options[name], callback = callback})
		end
	end

	if options.fx then
		for _, tbl in ipairs(options.fx) do
			local callback = fonts.effects[tbl.type]
			if callback then
				tbl.order = tbl.order or 0
				table.insert(sorted, {info = tbl, callback = callback})
			end
		end
	end

	if sorted[1] then
		shading_info = shading_info or {}
		table.sort(sorted, function(a, b) return a.info.order > b.info.order end)

		for _, data in ipairs(sorted) do
			local stages = data.callback(data.info, options)

			if stages.source then
				stages = {stages}
			end

			for _, stage in ipairs(stages) do
				table.insert(shading_info, stage)
			end
		end
	end

	for class_name, _ in pairs(fonts.registered_fonts) do
		if not options.type or options.type == class_name then
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
			self:SetShadingInfo(shading_info)
			self:SetMonospace(monospace)
			self:SetSpacing(spacing)
			self:SetFiltering(filtering)
			self:SetReverseDraw(options.reverse_draw)
			self:SetTabWidthMultiplier(options.tab_width_multiplier or 4)
			self:SetFlags(options.flags)
			if options.curve then self:SetCurve(options.curve) end

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
	end

	if options.path ~= fonts.default_font_path then
		return fonts.GetDefaultFont()
	end

	return fonts.GetFallbackFont()
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

	if RELOAD then
		for _, v in pairs(prototype.GetCreated()) do
			if v.Type == "font" and v.ClassName == meta.ClassName then
				v.string_cache = {}
				v.total_strings_stored = 0
				v:CreateTextureAtlas()
				v:Rebuild()
			end
		end
	end
end

do
	fonts.effects = fonts.effects or {}

	function fonts.AddEffect(name, callback)
		fonts.effects[name] = callback
	end

	local function add_blur_stage(stages, blur_radius, blur_dir)
		table.insert(stages, {
			source = [[
			//this will be our RGBA sum
			vec4 sum = vec4(0.0);

			//the amount to blur, i.e. how far off center to sample from
			//1.0 -> blur by one pixel
			//2.0 -> blur by two pixels, etc.
			vec2 blur = vec2(radius)/size;

			//the direction of our blur
			//(1.0, 0.0) -> x-axis blur
			//(0.0, 1.0) -> y-axis blur
			float hstep = dir.x;
			float vstep = dir.y;

			//apply blurring, using a 9-tap filter with predefined gaussian weights

			sum += texture(self, vec2(uv.x - 4.0*blur.x*hstep, uv.y - 4.0*blur.y*vstep)) * 0.0162162162;
			sum += texture(self, vec2(uv.x - 3.0*blur.x*hstep, uv.y - 3.0*blur.y*vstep)) * 0.0540540541;
			sum += texture(self, vec2(uv.x - 2.0*blur.x*hstep, uv.y - 2.0*blur.y*vstep)) * 0.1216216216;
			sum += texture(self, vec2(uv.x - 1.0*blur.x*hstep, uv.y - 1.0*blur.y*vstep)) * 0.1945945946;

			sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

			sum += texture(self, vec2(uv.x + 1.0*blur.x*hstep, uv.y + 1.0*blur.y*vstep)) * 0.1945945946;
			sum += texture(self, vec2(uv.x + 2.0*blur.x*hstep, uv.y + 2.0*blur.y*vstep)) * 0.1216216216;
			sum += texture(self, vec2(uv.x + 3.0*blur.x*hstep, uv.y + 3.0*blur.y*vstep)) * 0.0540540541;
			sum += texture(self, vec2(uv.x + 4.0*blur.x*hstep, uv.y + 4.0*blur.y*vstep)) * 0.0162162162;

			return sum;
			]],
			vars = {
				radius = blur_radius,
				dir = blur_dir,
			},
			blend_mode = "alpha",
		})
	end

	fonts.AddEffect("shadow", function(info, options)
		local dir = info.dir or options.size / 2
		local color = info.color or Color(0, 0, 0, 0.25)
		local blur_radius = info.blur_radius

		if type(dir) == "number" then
			dir = Vec2(-dir, dir)
		else
			dir = Vec2(-dir.x, dir.y)
		end

		local stages = {}

		-- copy the old texture
		table.insert(stages, {copy = true})

		local passes = info.dir_passes or 1
		for i = 1, passes do
			local m = (i / passes)

			table.insert(stages, {
				source = "return vec4(color.r, color.g, color.b, texture(copy, uv + (dir / size)).a * color.a);",
				vars = {
					dir = dir * m,
					color = i == 1 and color or color:Copy():SetAlpha((color.a * -m+1) ^ (info.dir_falloff or 1)),
				},
				blend_mode = i == 1 and "none" or "alpha",
			})
		end

		if blur_radius then
			local times = info.blur_passes or 1
			for i = 1, times do
				local m = i / times
				add_blur_stage(stages, blur_radius, Vec2(0,1) * m)
				add_blur_stage(stages, blur_radius, Vec2(1,0) * m)
			end
		end

		if info.alpha_pow then
			table.insert(stages, {
				source = "return vec4(texture(self, uv).rgb, pow(texture(self, uv).a, alpha_pow));",
				vars = {
					alpha_pow = info.alpha_pow,
				},
				blend_mode = "none",
			})
		end

		table.insert(stages, {
			source = "return texture(self, uv) * vec4(1,1,1,color.a);",
			blend_mode = "alpha",
			vars = {
				color = color,
			},
			blend_mode = "none",
		})

		-- render the old texture above the shadow texture with normal alpha blending
		table.insert(stages, {
			source = "return texture(copy, uv);",
			blend_mode = "alpha",
			vars = {},
		})

		return stages
	end)

	fonts.AddEffect("gradient", function(info, options)
		return {
			source = "return vec4(texture(gradient_texture, uv).rgb, texture(self, uv).a);",
			vars = {
				gradient_texture = info.texture,
			},
			blend_mode = "none",
		}
	end)

	fonts.AddEffect("color", function(info, options)
		return {
			source = "return texture(self, uv) * color;",
			vars = {
				color = info.color,
			},
			blend_mode = "none",
		}
	end)
end

runfile("base_font.lua")
runfile("fonts/*", fonts)

if RELOAD then
	fonts.Initialize()
end

return fonts