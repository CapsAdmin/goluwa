local function huh(a, b) return a.x * b.y - a.y * b.x end

local function render_edge(mode, anchors, normals, s, len_s, ns, q, r, half_width)
	if mode == "none" then
		table.insert(anchors, q)
		table.insert(anchors, q)
		table.insert(normals, ns)
		table.insert(normals, -ns)

		s = (r - q)
		len_s = s:GetLength()
		ns = s:GetNormal(half_width / len_s)

		table.insert(anchors, q)
		table.insert(anchors, q)
		table.insert(normals, -ns)
		table.insert(normals, ns)
	elseif mode == "miter" then
		local t = r - q
		local len_t = t:GetLength()
		local nt = t:GetNormal(half_width / len_t)

		table.insert(anchors, q)
		table.insert(anchors, q)

		local det = huh(s, t)
		if math.abs(det) / (len_s * len_t) < 0.05 and (s * t):GetLength() > 0 then
			table.insert(normals, ns)
			table.insert(normals, -ns)
		else
			local lambda = huh(nt - ns, t) / det
			if not math.isvalid(lambda) then lambda = 0 end -- not really sure why this is needed
			local d = ns + s * lambda

			table.insert(normals, d)
			table.insert(normals, -d)
		end

		s = t
		ns = nt
		len_s = len_t

	elseif mode == "bevel" then
		local t = r - q
		local len_t = t:GetLength()

		local det = huh(s, t)
		if math.abs(det) / (len_s * len_t) < 0.05 and (s * t):GetLength() > 0 then
			local n = t:GetNormal(half_width / len_t)
			table.insert(anchors, q)
			table.insert(anchors, q)
			table.insert(normals, n)
			table.insert(normals, -n)
			s = t
			len_s = len_t
			return s, len_s, ns
		end

		local nt = t:GetNormal(half_width / len_t)
		local lambda = huh(nt - ns, t) / det
		if not math.isvalid(lambda) then lambda = 0 end -- not really sure why this is needed
		local d = ns + s * lambda

		table.insert(anchors, q)
		table.insert(anchors, q)
		table.insert(anchors, q)
		table.insert(anchors, q)

		if det > 0 then
			table.insert(normals, d)
			table.insert(normals, -ns)
			table.insert(normals, d)
			table.insert(normals, -nt)
		else
			table.insert(normals, ns)
			table.insert(normals, -d)
			table.insert(normals, nt)
			table.insert(normals, -d)
		end

		s = t
		len_s = len_t
		ns = nt
	end

	return s, len_s, ns
end

local function render(mode, coords, count, size_hint, half_width, pixel_size, draw_overdraw, draw_mode)
	local overdraw_vertex_count = 0
	local overdraw_vertex_start = 0

	local anchors = table.new(size_hint, 1)
	local normals = table.new(size_hint, 1)

	if draw_overdraw then
		half_width = half_width - pixel_size * 0.3
	end

	local is_looping = (coords[1] == coords[count - 1]) and (coords[2] == coords[count])
	local s

	if not is_looping then
		s = Vec2(coords[3] - coords[1], coords[4] - coords[2])
	else
		s = Vec2(coords[1] - coords[count - 3], coords[1] - coords[count - 2])
	end

	local len_s = s:GetLength()
	local ns = s:GetNormal(half_width / len_s)

	local q
	local r = Vec2(coords[1], coords[2])

	for i = 0, count - 4, 2 do
		q = r
		r = Vec2(coords[i + 3], coords[i + 4])
		s, len_s, ns = render_edge(mode, anchors, normals, s, len_s, ns, q, r, half_width)
	end

	q = r
	r = is_looping and Vec2(coords[3], coords[4]) or r + s
	s, len_s, ns = render_edge(mode, anchors, normals, s, len_s, ns, q, r, half_width)

	local vertex_count = #normals
	local extra_vertices = 0

	if draw_overdraw then
		--calc_overdraw_vertex_count(is_looping)
		if mode == "none" then
			overdraw_vertex_count = 4 * vertex_count - 2
		else
			overdraw_vertex_count = 2 * vertex_count + (is_looping and 0 or 2)
		end

		if draw_mode == "triangle_strip" then
			extra_vertices = 2
		end
	end

	local vertices = {}

	for i = 1, vertex_count do
		vertices[i] = anchors[i] + normals[i]
	end

	if draw_overdraw then
		local overdraw = vertices--- + vertex_count + extra_vertices
		overdraw_vertex_start = vertex_count + extra_vertices

		if mode == "none" then
			for i = 2, vertex_count + 3 - 1, 4 do
				local s = vertices[i+1] - vertices[i+3+1]
				local t = vertices[i+1] - vertices[i+1+1]
				s:Normalize(pixel_size)
				t:Normalize(pixel_size)

				local k = 4 * (- 2)
				k = k + overdraw_vertex_start
				k = k + 1
				i = i + 1
				overdraw[k] = vertices[i]
				overdraw[k+1] = vertices[i]   + s + t
				overdraw[k+2] = vertices[i+1] + s - t
				overdraw[k+3] = vertices[i+1]

				overdraw[k+4] = vertices[i+1]
				overdraw[k+5] = vertices[i+1] + s - t
				overdraw[k+6] = vertices[i+2] - s - t
				overdraw[k+7] = vertices[i+2]

				overdraw[k+8]  = vertices[i+2]
				overdraw[k+9]  = vertices[i+2] - s - t
				overdraw[k+10] = vertices[i+3] - s + t
				overdraw[k+11] = vertices[i+3]

				overdraw[k+12] = vertices[i+3]
				overdraw[k+13] = vertices[i+3] - s + t
				overdraw[k+14] = vertices[i]   + s + t
				overdraw[k+15] = vertices[i]
			end
		else
			for i = 0, vertex_count - 1 - 1, 2 do
				overdraw[overdraw_vertex_start + i+1] = vertices[i+1]
				overdraw[overdraw_vertex_start + i+1+1] = vertices[i+1] + normals[i+1] * (pixel_size / normals[i+1]:GetLength())
			end

			for i = 0, vertex_count - 1 - 1, 2 do
				local k = vertex_count - i - 1
				overdraw[overdraw_vertex_start + vertex_count + i+1] = vertices[k]
				overdraw[overdraw_vertex_start + vertex_count + i+1+1] = vertices[k+1] + normals[k+1] * (pixel_size / normals[i+1]:GetLength())
			end

			if not is_looping then
				local spacer = (overdraw[overdraw_vertex_start + 1+1] - overdraw[overdraw_vertex_start + 3+1])
				spacer:Normalize(pixel_size)
				overdraw[overdraw_vertex_start + 1+1] = overdraw[overdraw_vertex_start + 1+1] + spacer

				spacer = (overdraw[overdraw_vertex_start + vertex_count - 1] - overdraw[overdraw_vertex_start + vertex_count - 3])
				spacer:Normalize(pixel_size)
				overdraw[overdraw_vertex_start + vertex_count - 1+1] = overdraw[overdraw_vertex_start + vertex_count - 1+1]  + spacer
				overdraw[overdraw_vertex_start + vertex_count + 1+1] = overdraw[overdraw_vertex_start + vertex_count + 1+1]  + spacer

				overdraw[overdraw_vertex_start + overdraw_vertex_count - 2+1] = overdraw[overdraw_vertex_start + 0+1]
				overdraw[overdraw_vertex_start + overdraw_vertex_count - 1+1] = overdraw[overdraw_vertex_start + 1+1]
 			end
		end
	end

	if extra_vertices ~= 0 then
		vertices[vertex_count + 0 + 1] = vertices[vertex_count - 1 + 1]
		vertices[vertex_count + 1 + 1] = vertices[overdraw_vertex_start + 1]
	end

	return vertices, overdraw_vertex_start + overdraw_vertex_count
end

local function draw_line(mode, coords, width, pixel_size, draw_overdraw)
	width = width * 0.5
	local draw_mode
	if mode == "none" then
		draw_mode = "triangles"
	else
		draw_mode = "triangle_strip"
	end
	local count = #coords
	if mode == "miter" then
		return render(mode, coords, count, count, width, pixel_size, draw_overdraw, draw_mode), nil, draw_mode
	elseif mode == "bevel" then
		return render(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode), nil, draw_mode
	elseif mode == "none" then
		local vertices, overdraw_count = render(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode)
		for i = 0, #vertices - 4 - 1 do
			vertices[i + 1] = vertices[i + 2 + 1]
		end
		table.remove(vertices, #vertices)

		local total_vertex_count = #vertices
		if draw_overdraw then
			total_vertex_count = overdraw_count
		end
		local num_indices = (total_vertex_count / 4) * 6
		local indices = {}

		for i = 0, (num_indices / 6) - 1 do
			indices[(i * 6 + 0) + 1] = i * 4 + 0
			indices[(i * 6 + 1) + 1] = i * 4 + 1
			indices[(i * 6 + 2) + 1] = i * 4 + 2

			indices[(i * 6 + 3) + 1] = i * 4 + 0
			indices[(i * 6 + 4) + 1] = i * 4 + 2
			indices[(i * 6 + 5) + 1] = i * 4 + 3
		end

		return vertices, indices, draw_mode
	end
end
local function to_render2d_mesh(points)
	local temp = {}
	for i,v in ipairs(points) do
		temp[i] = {pos = v, color = Color(1,1,1,0.5)}
	end
	return temp
end

local dynamic = false
local mesh

event.AddListener("PreDrawGUI", "lol", function()
	local coords = {200,50, 400,50, 500,300, 100,300, 200,50}
	local vertices, indices, mode = draw_line("none", coords, 50, 1)

	mesh = mesh or dynamic and render2d.CreateMesh(100) or render2d.CreateMesh(to_render2d_mesh(vertices), indices)
	mesh:SetMode(mode)

	if dynamic then
		for i, v in ipairs(vertices) do
			mesh.Vertices.Pointer[i].pos.A = v.x
			mesh.Vertices.Pointer[i].pos.B = v.y

			mesh.Vertices.Pointer[i].color.A = 1
			mesh.Vertices.Pointer[i].color.B = 1
			mesh.Vertices.Pointer[i].color.C = 1
			mesh.Vertices.Pointer[i].color.D = 1
		end

		if indices then
			mesh:SetIndices(Array("uint16_t", #indices, indices))
		end

		mesh:UpdateBuffer()
	end

	render2d.SetColor(1,1,1,1)
	render2d.SetTexture()
	render2d.PushMatrix(350,350, 1,1)
	mesh:Draw()
	render2d.PopMatrix()
end)