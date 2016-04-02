local gmod = ... or gmod
local lib = render
local render = gmod.env.render

function render.GetBloomTex0() return _G.render.GetErrorTexture() end
function render.GetBloomTex1() return _G.render.GetErrorTexture() end
function render.GetScreenEffectTexture() return _G.render.GetErrorTexture() end

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

function render.SuppressEngineLighting(b)

end

function render.SetLightingOrigin()

end

function render.ResetModelLighting()

end

function render.SetColorModulation(r,g,b)

end

function render.SetBlend(a)
	surface.SetAlphaMultiplier(a)
end

function render.SetModelLighting()

end

function render.SetScissorRect(x,y,w,h, b)

end

function render.UpdateScreenEffectTexture()

end

local globals = gmod.env

gmod.render_targets = gmod.render_targets or {}

function globals.GetRenderTarget(name, w, h)
	local fb = gmod.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gmod.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gmod.WrapObject(fb:GetTexture(), "ITexture")
end

function globals.GetRenderTargetEx(name, w, h, size_mode, depth_mode, texture_flags, rt_flags, image_format)
	local fb = gmod.render_targets[name] or lib.CreateFrameBuffer(Vec2(w, h))
	gmod.render_targets[name] = fb
	fb:GetTexture().fb = fb
	return gmod.WrapObject(fb:GetTexture(), "ITexture")
end

function globals.ScrW() return lib.GetWidth() end
function globals.ScrH() return lib.GetHeight() end

function globals.DisableClipping(b)

end