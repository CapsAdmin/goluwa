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
	render2d.DrawRect(x,y,w,h,math.rad(r),w/2,h/2)
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

function surface.DrawOutlinedRect(x,y,w,h)
	local old = render2d.bound_texture
	render2d.SetTexture()
	render2d.DrawRect(x, y, 1, h)
	render2d.DrawRect(x, y, w, 1)
	render2d.DrawRect(w + x - 1, y, 1, h)
	render2d.DrawRect(x, h + y - 1, w, 1)
	render2d.bound_texture = old
end

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

do
	local mesh = render2d.CreateMesh(2048)
	mesh:SetMode("triangle_fan")

	for i = 1, 2048 do
		mesh:SetVertex(i, "color", 1,1,1,1)
	end

	local mesh_idx = render.CreateIndexBuffer()
	mesh_idx:LoadIndices(2048)

	function surface.DrawPoly(tbl)
		local count = #tbl
		for i = 1, count do
			local vertex = tbl[i]

			mesh:SetVertex(i, "pos", vertex.x, vertex.y)

			if vertex.u and vertex.v then
				mesh:SetVertex(i, "uv", vertex.u, vertex.v)
			end
		end

		render2d.BindShader()
		mesh:UpdateBuffer()
		mesh_idx:UpdateBuffer()
		mesh:Draw(mesh_idx, count)
	end
end