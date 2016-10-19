local lib = _G.render2d
local render2d = gine.env.render2d

function render2d.SetDrawColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function render2d.SetAlphaMultiplier(a)
	lib.SetAlphaMultiplier(a)
end

function gfx.DrawTexturedRectRotated(x,y,w,h,r)
	lib.DrawRect(x,y,w,h,math.rad(r))
end

function gfx.DrawTexturedRect(x,y,w,h)
	lib.DrawRect(x,y,w,h)
end

function render2d.DrawRect(x,y,w,h)
	local old = lib.bound_texture
	lib.SetWhiteTexture()
	lib.DrawRect(x,y,w,h)
	lib.bound_texture = old
end

render2d.DrawOutlinedRect = render2d.DrawRect

function gfx.DrawTexturedRectUV(x,y,w,h, u1,v1, u2,v2)
	lib.SetRectUV(u1,v1, u2-u1,v2-v1)
	lib.DrawRect(x,y,w,h)
	lib.SetRectUV()
end

function gfx.DrawLine(...)
	lib.DrawLine(...)
end

function render2d.DisableClipping(b)

end

function render2d.DrawPoly()

end
