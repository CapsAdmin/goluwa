
local mesh = render2d.CreateMesh(2048)
mesh:SetDrawHint("dynamic")

local mesh_idx = render.CreateIndexBuffer()
mesh_idx:LoadIndices(2048)
mesh_idx:SetDrawHint("dynamic")

for i = 1, 2048 do
	mesh:SetVertex(i, "color", 1,1,1,1)
end

--mesh:SetMode("triangle_fan")

local function surface_DrawPoly(tbl)
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
	mesh:Draw(mesh_idx, #tbl)
end




local mesh = {}

for i = 1, 6 do
	mesh[i] = {x = 0, y = 0, u = 0, v = 0}
end

local function draw_rectangle(x,y, w,h, u1,v1,u2,v2, sx,sy)
	u1 = u1 or 0
	v1 = v1 or 0

	u2 = u2 or 1
	v2 = v2 or 1

	sx = sx or 1
	sy = sy or 1

	-- scale uv coordinates where sx and sy are maybe texture size
	u1 = u1 / sx
	v1 = v1 / sy
	u2 = u2 / sx
	v2 = v2 / sy

	-- make u2 and v2 relative to u1 and v1
	u2 = u2 + u1
	v2 = v2 + v1

	-- make w and h relative to x and y
	w = w + x
	h = h + y

	-- flip y
	local t = v2
	v2 = v1
	v1 = t

	mesh[1].x = w
	mesh[1].y = h
	mesh[1].u = u2
	mesh[1].v = v1

	mesh[2].x = x
	mesh[2].y = y
	mesh[2].u = u1
	mesh[2].v = v2

	mesh[3].x = w
	mesh[3].y = y
	mesh[3].u = u2
	mesh[3].v = v2


	mesh[4].x = x
	mesh[4].y = h
	mesh[4].u = u1
	mesh[4].v = v1

	mesh[5].x = x
	mesh[5].y = y
	mesh[5].u = u1
	mesh[5].v = v2

	mesh[6].x = w
	mesh[6].y = h
	mesh[6].u = u2
	mesh[6].v = v1

	surface_DrawPoly(mesh)
end


function goluwa.PreDrawGUI()
	local x = 50
	local y = 50
	local w = 100
	local h = 100

	local u1 = 0
	local v1 = 0
	local u2 = 1
	local v2 = 1

	local sx = 1
	local sy = 1

	render2d.SetColor(1,1,1,1)
	render2d.SetTexture()
	draw_rectangle(x,y, w,h, u1,v1,u2,v2, sx,sy)
	--gfx.DrawRect(x,y,w,h)
end