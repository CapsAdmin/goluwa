local lib = _G.render
local render = gmod.env.render

gmod.render_targets = gmod.render_targets or {}

function gmod.env.GetRenderTarget(name, w, h)
	local fb = gmod.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gmod.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gmod.WrapObject(fb:GetTexture(), "ITexture")
end

function gmod.env.GetRenderTargetEx(name, w, h, size_mode, depth_mode, texture_flags, rt_flags, image_format)
	local fb = gmod.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gmod.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gmod.WrapObject(fb:GetTexture(), "ITexture")
end

local current_fb

function render.SetRenderTarget(tex)
	if tex.__obj.fb then
		tex.__obj.fb:Bind()
		current_fb = tex.__obj.fb
	end
end

function render.GetRenderTarget()
	return current_fb
end

function render.PushRenderTarget(rt, x,y,w,h)
	render.PushFramebuffer(rt.__obj.fb)

	x = x or 0
	y = y or 0
	w = w or rt.__obj.fb.w
	h = h or rt.__obj.fb.h

	render.PushViewport(x,y,w,h)
end

function render.PopRenderTarget()
	render.PopViewport()

	render.PopFramebuffer()
end