local fonts = ... or {}

fonts.registered_fonts = fonts.registered_fonts or {}
fonts.font_dpi = 64

fonts.default_font_path = "fonts/unifont.ttf"

local ready = false
local queue = {}

function fonts.Initialize()
	ready = true

	fonts.default_font = fonts.CreateFont({path = fonts.default_font_path})
	fonts.loading_font = fonts.GetMiniFont()

	gfx.SetFont(fonts.default_font)

	for _, args in pairs(queue) do
		fonts.CreateFont(unpack(args))
	end
end

function fonts.GetDefaultFont()
	return fonts.default_font
end

function fonts.GetMiniFont()
	if not vfs.IsFile("data/fonts/minifont.bdf") then
		vfs.Write("data/minifont.zip", crypto.Base64Decode((([[
		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
		]]):gsub("%s", ""))))

		vfs.Write("data/fonts/minifont.bdf", vfs.Read("libarchive:" .. R("data/minifont.zip") .. "/tom-thumb.bdf"))
	end

	fonts.minifont = fonts.minifont or fonts.CreateFont({
		path = "data/fonts/minifont.bdf",
		size = 6,
		filtering = "nearest",
		--scale = Vec2(),
	})
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