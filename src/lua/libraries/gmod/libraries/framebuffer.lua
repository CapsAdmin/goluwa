local lib = _G.render
local render = gine.env.render

gine.render_targets = gine.render_targets or {}

function gine.env.GetRenderTarget(name, w, h)
	local fb = gine.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gine.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gine.WrapObject(fb:GetTexture(), "ITexture")
end

function gine.env.GetRenderTargetEx(name, w, h, size_mode, depth_mode, texture_flags, rt_flags, image_format)
	local fb = gine.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gine.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gine.WrapObject(fb:GetTexture(), "ITexture")
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
	lib.PushFrameBuffer(rt.__obj.fb)

	x = x or 0
	y = y or 0
	w = w or rt.__obj.fb:GetSize().w
	h = h or rt.__obj.fb:GetSize().h

	lib.PushViewport(x,y,w,h)
end

function render.PopRenderTarget()
	lib.PopViewport()

	lib.PopFrameBuffer()
end
