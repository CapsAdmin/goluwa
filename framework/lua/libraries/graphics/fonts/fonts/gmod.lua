if PLATFORM ~= "gmod" then return end

local cam_PushModelMatrix = gmod.cam.PushModelMatrix
local cam_PopModelMatrix = gmod.cam.PopModelMatrix
local GetGmodWorldMatrix = GetGmodWorldMatrix
local prettytext = gmod.requirex("pretty_text")

local fonts = ... or _G.fonts

local META = prototype.CreateTemplate("gmod_font")

function META:Initialize(options)
	self.options = options
end

function META:DrawString(str, x, y, w)
	local r,g,b,a = render2d.GetColor()

	cam_PushModelMatrix(GetGmodWorldMatrix())
		prettytext.DrawText({
			text = str,
			x = x,
			y = y,
			font = self.options.font,
			size = self.options.size,
			weight = self.options.weight,
			blur_size = self.options.blur_size,

			foreground_color_r = r * 255,
			foreground_color_g = g * 255,
			foreground_color_b = b * 255,
			foreground_color_a = a * 255 * render2d.GetAlphaMultiplier(),

			background_color = self.options.background_color,

			blur_overdraw = self.options.blur_overdraw,

			shadow_x = self.options.shadow_x or self.options.shadow,
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