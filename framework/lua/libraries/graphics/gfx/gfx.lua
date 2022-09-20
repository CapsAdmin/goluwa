local gfx = _G.gfx or {}
runfile("polygon_2d.lua", gfx)
runfile("sprite_batch.lua", gfx)
runfile("quadric_bezier_curve.lua", gfx)
runfile("text.lua", gfx)

function gfx.Initialize()
	if VULKAN then return end

	gfx.ninepatch_poly = gfx.CreatePolygon2D(9 * 6)
	gfx.ninepatch_poly.vertex_buffer:SetDrawHint("dynamic")
	local tex = render.CreateBlankTexture(Vec2() + 1024)
	tex:SetWrapS("mirrored_repeat")
	tex:SetWrapT("mirrored_repeat")
	tex:SetMipMapLevels(32)
	tex:SetMinFilter("nearest")
	--tex:SetMagFilter("linear")
	tex:Shade([[
		// http://www.geeks3d.com/20130705/shader-library-circle-disc-fake-sphere-in-glsl-opengl-glslhacker/3/
		float disc_radius = 1;
		float border_size = 0.0001;
		vec2 uv2 = vec2(uv.x, -uv.y + 1);
		float dist = sqrt(dot(uv2, uv2));
		float t = smoothstep(disc_radius + border_size, disc_radius - border_size, dist);
		return vec4(1,1,1,t);
	]])
	tex:GenerateMipMap()
	gfx.quadrant_circle_texture = tex
	event.Call("2DReady")
end

function gfx.DrawNinePatch(x, y, w, h, patch_size_w, patch_size_h, corner_size, u_offset, v_offset, uv_scale)
	local size = render2d.GetTexture():GetSize()
	gfx.ninepatch_poly:SetNinePatch(
		1,
		x,
		y,
		w,
		h,
		patch_size_w,
		patch_size_h,
		corner_size,
		u_offset,
		v_offset,
		uv_scale,
		size.x,
		size.y
	)
	gfx.ninepatch_poly:Draw()
end

function gfx.DrawFilledCircle(x, y, sx, sy)
	sy = sy or sx
	render2d.PushTexture(gfx.quadrant_circle_texture)
	render2d.DrawRect(x, y, sx, sy)
	render2d.DrawRect(x, y, sx, sy, math.pi)
	render2d.DrawRect(x, y, sy, sx, math.pi / 2)
	render2d.DrawRect(x, y, sy, sx, -math.pi / 2)
	render2d.PopTexture()
end

function gfx.DrawRoundedRect(x, y, w, h, amt)
	amt = amt or 16

	if amt > w / 2 then amt = w / 2 end

	if amt > h / 2 then amt = h / 2 end

	amt = math.ceil(amt)
	render2d.PushTexture(render.GetWhiteTexture())
	render2d.DrawRect(x + amt, y + amt, w - amt * 2, h - amt * 2)
	render2d.DrawRect(x + amt, y, w - amt * 2, amt)
	render2d.DrawRect(x + amt, y + h - amt, w - amt * 2, amt)
	render2d.DrawRect(w - amt, amt, amt, h - amt * 2)
	render2d.DrawRect(x, amt, amt, h - amt * 2)
	render2d.PopTexture()
	render2d.PushTexture(gfx.quadrant_circle_texture)
	render2d.DrawRect(x + w - amt, y + h - amt, amt, amt)
	render2d.DrawRect(x + amt, y + h - amt, amt, amt, math.pi / 2)
	render2d.DrawRect(x + amt, y + amt, amt, amt, math.pi)
	render2d.DrawRect(x + w - amt, y + amt, amt, amt, -math.pi / 2)
	render2d.PopTexture()
end

function gfx.DrawRect(x, y, w, h, tex, r, g, b, a)
	if not y and not w and not h then
		tex = x
		x, y = 0, 0
		w, h = tex:GetSize():Unpack()
	end

	if r then render2d.PushColor(r, g, b, a) end

	tex = tex or render.GetWhiteTexture()
	render2d.PushTexture(tex)
	render2d.DrawRect(x, y, w, h)
	render2d.PopTexture()

	if r then render2d.PopColor() end
end

function gfx.DrawOutlinedRect(x, y, w, h, r, r_, g, b, a)
	r = r or 1

	if r_ then render2d.PushColor(r_, g, b, a) end

	render2d.PushTexture(render.GetWhiteTexture())

	if type(r) == "number" then r = Rect() + r end

	gfx.DrawLine(x, y, x, y + h, r.x, true, r.x)
	gfx.DrawLine(x - r.x + r.y, y, x + w + r.y + r.w, y, r.y, true, 0, r.y)
	gfx.DrawLine(x + w, y, x + w, y + h, r.w, true, 0)
	gfx.DrawLine(x - r.x, y + h, x + w + r.w, y + h, r.h, true, r.h, 0)
	render2d.PopTexture()

	if r_ then render2d.PopColor() end
end

function gfx.DrawLine(x1, y1, x2, y2, w, skip_tex, ox, oy)
	w = w or 1

	if not skip_tex then render2d.SetTexture() end

	local dx, dy = x2 - x1, y2 - y1
	local ang = math.atan2(dx, dy)
	local dst = math.sqrt((dx * dx) + (dy * dy))
	ox = ox or (w * 0.5)
	oy = oy or 0
	render2d.DrawRect(x1, y1, w, dst, -ang, ox, oy)
end

function gfx.DrawCircle(x, y, radius, width, resolution)
	resolution = resolution or 16
	local spacing = (resolution / radius) - 0.1

	for i = 0, resolution do
		local i1 = ((i + 0) / resolution) * math.pi * 2
		local i2 = ((i + 1 + spacing) / resolution) * math.pi * 2
		gfx.DrawLine(
			x + math.sin(i1) * radius,
			y + math.cos(i1) * radius,
			x + math.sin(i2) * radius,
			y + math.cos(i2) * radius,
			width
		)
	end
end

do
	function gfx.GetMousePosition()
		if window.GetMouseTrapped() then
			return render.GetWidth() / 2, render.GetHeight() / 2
		end

		return window.GetMousePosition():Unpack()
	end

	local last_x = 0
	local last_y = 0
	local last_diff = 0

	function gfx.GetMouseVel()
		local x, y = window.GetMousePosition():Unpack()
		local vx = x - last_x
		local vy = y - last_y
		local time = system.GetElapsedTime()

		if last_diff < time then
			last_x = x
			last_y = y
			last_diff = time + 0.1
		end

		return vx, vy
	end
end

if RELOAD then gfx.Initialize() end

return gfx