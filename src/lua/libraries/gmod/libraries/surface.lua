local surface = gine.env.surface

function surface.SetDrawColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	render2d.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetAlphaMultiplier(a)
	render2d.SetAlphaMultiplier(a)
end

function surface.DrawTexturedRectRotated(x,y,w,h,r)
	render2d.DrawRect(x,y,w,h,math.rad(r))
end

function surface.DrawTexturedRect(x,y,w,h)
	render2d.DrawRect(x,y,w,h)
end

function surface.DrawRect(x,y,w,h)
	local old = render2d.bound_texture
	render2d.SetTexture()
	render2d.DrawRect(x,y,w,h)
	render2d.bound_texture = old
end

surface.DrawOutlinedRect = surface.DrawRect

function surface.DrawTexturedRectUV(x,y,w,h, u1,v1, u2,v2)
	render2d.SetRectUV(u1,v1, u2-u1,v2-v1)
	render2d.DrawRect(x,y,w,h)
	render2d.SetRectUV()
end

function surface.DrawLine(...)
	gfx.DrawLine(...)
end

function surface.DisableClipping(b)

end

function surface.DrawPoly()

end
