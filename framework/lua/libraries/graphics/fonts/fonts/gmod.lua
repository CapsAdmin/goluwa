if PLATFORM ~= "gmod" then return end

local cam_PushModelMatrix = gmod.cam.PushModelMatrix
local cam_PopModelMatrix = gmod.cam.PopModelMatrix
local GetGmodWorldMatrix = GetGmodWorldMatrix
local prettytext = gmod.requirex("pretty_text")

local fonts = ... or _G.fonts

local META = prototype.CreateTemplate("gmod_font")

function META:Initialize(options)
	self.options = options

	if self.options.shadow then
		if type(self.options.shadow) == "number" then
			options.shadow_x = self.options.shadow
			options.shadow_y = self.options.shadow
		elseif type(self.options.shadow.dir) == "number" then
			options.shadow_x = self.options.shadow.dir
			options.shadow_y = self.options.shadow.dir
		else
			options.shadow_x = self.options.shadow.dir.x
			options.shadow_y = self.options.shadow.dir.y
		end
	end

	if options.shadow_color then
		options.shadow_color = gmod.Color(options.shadow_color.r*255, options.shadow_color.g*255, options.shadow_color.b*255, options.shadow_color.a*255)
	end
end

function META:DrawString(str, x, y, w)
	cam_PushModelMatrix(GetGmodWorldMatrix())
		prettytext.DrawText({
			text = str,
			x = x,
			y = y,
			font = self.options.font,
			size = self.options.size,
			blur_size = self.options.blur_size or 0,

			foreground_color_r = math.min(render2d.shader.global_color.r * 255, 255),
			foreground_color_g = math.min(render2d.shader.global_color.g * 255, 255),
			foreground_color_b = math.min(render2d.shader.global_color.b * 255, 255),
			foreground_color_a = math.min(render2d.shader.global_color.a * 255 * render2d.GetAlphaMultiplier(), 255),

			background_color = self.options.background_color,

			blur_overdraw = self.options.blur_overdraw,

			shadow_x = self.options.shadow_x,
			shadow_y = self.options.shadow_y,
		})
	cam_PopModelMatrix()
end

function META:GetTextSize(str)
	return prettytext.GetTextSize(str, self.options.font, self.options.size, self.options.weight, self.options.blur_size)
end

function META:IsReady()
	return true
end

function META:CompileString(data)
	local str = ""
	for i = 3, #data, 3 do
		str = str .. data[i]
	end

	local obj = {}

	function obj.Draw()
		self:DrawString(str)
	end

	return obj, self:GetTextSize(str)
end

function META:GetName()
	return self.options.font
end

fonts.RegisterFont(META)