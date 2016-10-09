local lib = _G.surface
local surface = gmod.env.surface

function surface.SetDrawColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetAlphaMultiplier(a)
	lib.SetAlphaMultiplier(a)
end

function surface.DrawTexturedRectRotated(x,y,w,h,r)
	lib.DrawRect(x,y,w,h,math.rad(r))
end

function surface.DrawTexturedRect(x,y,w,h)
	lib.DrawRect(x,y,w,h)
end

function surface.DrawRect(x,y,w,h)
	local old = lib.bound_texture
	lib.SetWhiteTexture()
	lib.DrawRect(x,y,w,h)
	lib.bound_texture = old
end

surface.DrawOutlinedRect = surface.DrawRect

function surface.DrawTexturedRectUV(x,y,w,h, u1,v1, u2,v2)
	lib.SetRectUV(u1,v1, u2-u1,v2-v1)
	lib.DrawRect(x,y,w,h)
	lib.SetRectUV()
end

function surface.DrawLine(...)
	lib.DrawLine(...)
end

function surface.DisableClipping(b)

end

function surface.DrawPoly()

end