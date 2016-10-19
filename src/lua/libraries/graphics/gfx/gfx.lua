local gfx = _G.gfx or {}

include("polygon_2d.lua", gfx)
include("polygon_3d.lua", gfx)
include("model_loader.lua", gfx)
include("quadric_bezier_curve.lua", gfx)
include("text.lua", gfx)
include("video.lua", gfx)
include("particles.lua", gfx)
include("markup/markup.lua", gfx)

function gfx.Initialize()
	gfx.ninepatch_poly = gfx.CreatePolygon2D(9 * 6)

	event.Delay(function()
		local tex = render.CreateBlankTexture(Vec2(surface.GetSize()))
		tex:SetWrapS("mirrored_repeat")
		tex:SetWrapT("mirrored_repeat")
		tex:Shade([[
			// http://www.geeks3d.com/20130705/shader-library-circle-disc-fake-sphere-in-glsl-opengl-glslhacker/3/
			float disc_radius = 1;
			float border_size = 0.0021;
			vec2 uv2 = vec2(uv.x, -uv.y + 1);
			float dist = sqrt(dot(uv2, uv2));
			float t = smoothstep(disc_radius + border_size, disc_radius - border_size, dist);
			return vec4(1,1,1,t);
		]])
		tex:GenerateMipMap()
		gfx.quadrant_circle_texture = tex
	end)

	event.Call("2DReady")
end

function gfx.DrawNinePatch(x, y, w, h, patch_size_w, patch_size_h, corner_size, u_offset, v_offset, uv_scale)
	local skin = surface.GetTexture()

	gfx.ninepatch_poly:SetNinePatch(1, x, y, w, h, patch_size_w, patch_size_h, corner_size, u_offset, v_offset, uv_scale, skin.Size.x, skin.Size.y)
	gfx.ninepatch_poly:Draw()
end

function gfx.DrawFilledCircle(x, y, sx, sy)
	sy = sy or sx

	surface.PushTexture(gfx.quadrant_circle_texture)
	surface.DrawRect(x, y, sx, sy)
	surface.DrawRect(x, y, sx, sy, math.pi)
	surface.DrawRect(x, y, sx, sy, math.pi/2)
	surface.DrawRect(x, y, sx, sy, -math.pi/2)
	surface.PopTexture()
end

function gfx.DrawCircle(x, y, radius, width, resolution)
	resolution = resolution or 16

	local spacing = (resolution/radius) - 0.1

	for i = 0, resolution do
		local i1 = ((i+0) / resolution) * math.pi * 2
		local i2 = ((i+1 + spacing) / resolution) * math.pi * 2

		surface.DrawLine(
			x + math.sin(i1) * radius,
			y + math.cos(i1) * radius,

			x + math.sin(i2) * radius,
			y + math.cos(i2) * radius,
			width
		)
	end
end

return gfx