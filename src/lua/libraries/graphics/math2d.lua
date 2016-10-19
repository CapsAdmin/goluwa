local math2d = _G.math2d or {}

function math2d.IsCoordinatesConvex(points)
	local polygons = {}
	for i = 1, #points, 2 do
		table.insert(polygons, Vec2(points[i + 0], points[i + 1]))
	end

	if #polygons < 3 then
		return false
	end

	local i = #polygons - 2
	local j = #polygons - 1
	local k = 0

	local p = polygons[j+1] - polygons[i+1]
	local q = polygons[k+1] - polygons[j+1]

	local winding = p.x * q.y - p.y * q.x

	while k+1 < #polygons do
		i = j
		j = k
		k = k + 1

		p = polygons[j+1] - polygons[i+1]
		q = polygons[k+1] - polygons[j+1]

		if (p.x * q.y - p.y * q.x) * winding < 0 then
			return false
		end
	end

	return true
end

do
	local function is_oriented_ccw(a, b, c)
		return ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) >= 0
	end

	local function on_same_side(a, b, c, d)
		local px = d.x - c.x
		local py = d.y - c.y
		local l = px * (a.y - c.y) - py * (a.x - c.x)
		local m = px * (b.y - c.y) - py * (b.x - c.x)
		return l * m >= 0
	end

	local function point_in_triangle(p, a, b, c)
		return on_same_side(p,a, b,c) and on_same_side(p,b, a,c) and on_same_side(p,c, a,b)
	end

	local function any_point_in_triangle(vertices, a, b, c)
		for i, p in ipairs(vertices) do
			if p ~= a and p ~= b and p ~= c and point_in_triangle(p, a, b, c) then
				return true
			end
		end

		return false
	end

	local function is_ear(a, b, c, vertices)
		return is_oriented_ccw(a, b, c) and not any_point_in_triangle(vertices, a, b, c)
	end

	function math2d.TriangulateCoordinates(points)
		local polygons = {}
		for i = 1, #points, 2 do
			table.insert(polygons, Vec2(points[i + 0], points[i + 1]))
		end

		if #polygons < 3 then
			return error("Not a polygon", 2)
		elseif #polygons == 3 then
			return points
		end

		local next_idx = {}
		local prev_idx = {}
		local idx_lm = 0

		for i = 0, #polygons - 1 do
			local p = polygons[i + 1]
			local lm = polygons[idx_lm + 1]

			if p.x < lm.x or (p.x == lm.x and p.y < lm.y) then
				idx_lm = i
			end

			next_idx[i] = i + 1
			prev_idx[i] = i - 1
		end

		next_idx[table.count(next_idx) - 1] = 0
		prev_idx[0] = table.count(prev_idx) - 1

		if not is_oriented_ccw(polygons[prev_idx[idx_lm] + 1], polygons[idx_lm + 1], polygons[next_idx[idx_lm] + 1]) then
			local temp = next_idx
			next_idx = prev_idx
			prev_idx = temp
		end

		local concave = {}
		for i = 0, #polygons - 1 do
			if not is_oriented_ccw(polygons[prev_idx[i] + 1], polygons[i + 1], polygons[next_idx[i] + 1]) then
				table.insert(concave, polygons[i + 1])
			end
		end

		local triangles = {}
		local n_vertices = #polygons
		local current = 1
		local skipped = 0
		local next = 0
		local prev = 0

		while n_vertices > 3 do
			next = next_idx[current]
			prev = prev_idx[current]

			local a = polygons[prev + 1]
			local b = polygons[current + 1]
			local c = polygons[next + 1]

			if is_ear(a, b, c, concave) then
				table.insert(triangles, {a.x,a.y, b.x,b.y, c.x,c.y})
				next_idx[prev] = next
				prev_idx[next] = prev
				table.removevalue(concave, b)
				n_vertices = n_vertices - 1
				skipped = 0
			else
				skipped = skipped + 1
				if skipped > n_vertices then
					error("Cannot triangulate polygon.", 2)
				end
			end
			current = next
		end

		next = next_idx[current]
		prev = prev_idx[current]

		local a = polygons[prev + 1]
		local b = polygons[current + 1]
		local c = polygons[next + 1]

		table.insert(triangles, {a.x,a.y, b.x,b.y, c.x,c.y})

		return triangles
	end
end

function math2d.RoundedRectangleToCoordinates(x, y, w, h, radius_x, radius_y, resolution)
	radius_x = radius_x or 0
	radius_y = radius_y or radius_x

	if not resolution then
		if math.max(radius_x, radius_y) > 20 then
			resolution = math.ceil(math.max(radius_x, radius_y) / 2)
		else
			resolution = 10
		end
	end

	if w >= 0.02 then
		radius_x = math.min(radius_x, w / 2 - 0.01)
	end

	if h >= 0.02 then
		radius_y = math.min(radius_y, h / 2 - 0.01)
	end

	local points = math.max(resolution, 1)
	local half_pi = math.pi / 2
	local angle_shift = half_pi / (points + 1)

	local coords = {}

	local phi

	phi = 0
	for i = 0, points + 2 do
		coords[(2 * i + 0) + 1] = x + radius_x * (1 - math.cos(phi))
		coords[(2 * i + 1) + 1] = y + radius_y * (1 - math.sin(phi))
		phi = phi + angle_shift
	end

	phi = half_pi
	for i = points + 2, 2 * (points + 2) do
		coords[(2 * i + 0) + 1] = x + w - radius_x * (1 + math.cos(phi))
		coords[(2 * i + 1) + 1] = y + radius_y * (1 - math.sin(phi))
		phi = phi + angle_shift
	end

	phi = 2 * half_pi
	for i = 2 * (points + 2), 3 * (points + 2) do
		coords[(2 * i + 0) + 1] = x + w - radius_x * (1 + math.cos(phi))
		coords[(2 * i + 1) + 1] = y + h - radius_y * (1 + math.sin(phi))
		phi = phi + angle_shift
	end

	phi = 3 * half_pi
	for i = 3 * (points + 2), 4 * (points + 2) do
		coords[(2 * i + 0) + 1] = x + radius_x * (1 - math.cos(phi))
		coords[(2 * i + 1) + 1] = y + h - radius_y * (1 + math.sin(phi))
		phi = phi + angle_shift
	end

	--coords[#coords - 1] = coords[3]
	--coords[#coords - 0] = coords[4]

	return coords
end

function math2d.EllipseToCoordinates(x, y, w, h, points)
	if not points then
		if w and h and (w + h) > 30 then
			points = math.ceil((w + h) / 2)
		else
			points = 15
		end
	end

	local two_pi = math.pi * 2
	if points <= 0 then points = 1 end
	local angle_shift = two_pi / points
	local phi = 0

	local coords = {}
	for i = 0, points - 1 do
		coords[(2*i+0) + 1] = x + w * math.cos(phi)
		coords[(2*i+1) + 1] = y + h * math.sin(phi)
		phi = phi + angle_shift
	end

	coords[(2*points+0) + 1] = coords[1]
	coords[(2*points+1) + 1] = coords[2]

	return coords
end

do
	local function create_points(coords, points, x, y, radius, phi, angle_shift, offset)
		for i = offset, points-1 do
			coords[(2 * i + 0) + 1] = x + radius * math.cos(phi)
			coords[(2 * i + 1) + 1] = y + radius * math.sin(phi)
			phi = phi + angle_shift
		end
	end

	function math2d.ArcToCoordinates(arc_mode, x, y, radius, angle1, angle2, points)
		points = points or radius
		local angle = math.abs(angle1 - angle2)

		if angle < math.pi * 2 then
			points = points * angle / (2 * math.pi)
		end

		points = math.ceil(points)

		if points <= 0 or angle1 == angle2 then
			--return
		end

		if math.abs(angle1 - angle2) >= 2 * math.pi then
			return -- draw circle
		end

		local angle_shift = (angle2 - angle1) / points

		if angle_shift  == 0  then
			return
		end

		local phi = angle1
		local coords = {}
		local num_coords = 0

		if arc_mode == "pie" then
			coords[1] = x
			coords[2] = y

			create_points(coords, points + 3, x, y, radius, phi, angle_shift, 1)

			coords[#coords - 1] = x
			coords[#coords - 0] = y
		elseif arc_mode == "open" then
			create_points(coords, points + 1, x, y, radius, phi, angle_shift, 0)
		else -- if arc_mode == "closed" then
			create_points(coords, points + 2, x, y, radius, phi, angle_shift, 0)
			coords[#coords - 1] = coords[1]
			coords[#coords - 0] = coords[2]
		end

		return coords
	end
end

do
	local function edge(anchors, normals, s, len_s, ns, q, r, half_width, mode)
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

			local det = s:GetCrossed(t)
			if math.abs(det) / (len_s * len_t) < 0.05 and s:GetDot(t) > 0 then
				table.insert(normals, ns)
				table.insert(normals, -ns)
			else
				local lambda = (nt - ns):GetCrossed(t) / det
				local d = ns + s * lambda

				--logf("normal = %i\nlambda = %f\nnt= Vec2(%f, %f)\nns= Vec2(%f, %f)\nt = Vec2(%f, %f)\ndet = %f\ns = Vec2(%f, %f)\n", #normals, lambda, nt.x,nt.y, ns.x,ns.y, t.x,t.y, det, s.x, s.y);

				table.insert(normals, d)
				table.insert(normals, -d)
			end

			s = t
			ns = nt
			len_s = len_t

		elseif mode == "bevel" then
			local t = r - q
			local len_t = t:GetLength()

			local det = s:GetCrossed(t)
			if math.abs(det) / (len_s * len_t) < 0.05 and s:GetDot(t) > 0 then
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
			local lambda = (nt - ns):GetCrossed(t) / det
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

	local function line_(mode, coords, count, size_hint, half_width, pixel_size, draw_overdraw, draw_mode, join)
		local overdraw_vertex_count = 0
		local overdraw_vertex_start = 0

		local anchors = table.new(size_hint, 1)
		local normals = table.new(size_hint, 1)

		if draw_overdraw then
			half_width = half_width - pixel_size * 0.3
		end

		if join then
			table.insert(coords, coords[1])
			table.insert(coords, coords[2])
			count = count + 2
		end

		local is_looping = (coords[1] == coords[count - 1]) and (coords[2] == coords[count])
		local s

		if is_looping then
			s = Vec2(coords[1] - coords[count - 3], coords[2] - coords[count - 2])
		else
			s = Vec2(coords[3] - coords[1], coords[4] - coords[2])
		end

		local len_s = s:GetLength()
		local ns = s:GetNormal(half_width / len_s)

		local q
		local r = Vec2(coords[1], coords[2])

		for i = 0, count - 2, 2 do
			q = r
			if i < count - 2 then
				r = Vec2(coords[i + 3], coords[i + 4])
			elseif is_looping then
				r = Vec2(coords[3], coords[4])
			else
				r = r + s
			end
			s, len_s, ns = edge(anchors, normals, s, len_s, ns, q, r, half_width, mode)
		end

		if join then
			table.remove(coords)
			table.remove(coords)
		end

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

	function math2d.CoordinatesToLines(coords, width, join, mode, pixel_size, draw_overdraw)
		width = width * 0.5
		local draw_mode
		if mode == "none" then
			draw_mode = "triangles"
		else
			draw_mode = "triangle_strip"
		end
		local count = #coords
		if mode == "miter" then
			return draw_mode, line_(mode, coords, count, count, width, pixel_size, draw_overdraw, draw_mode, join), nil
		elseif mode == "bevel" then
			return draw_mode, line_(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode, join), nil
		elseif mode == "none" then
			local vertices, overdraw_count = line_(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode, join)
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

			return draw_mode, vertices, indices
		end
	end
end

do
	local META = prototype.CreateTemplate("bezier_curve")

	function math2d.CreateBezierCurve(coordinates)
		local self = META:CreateObject()
		self.polygons = coordinates
		return self
	end

	function META:Translate(t)
		for i, p in ipairs(self.polygons) do
			p.x = p.x + t.x
			p.y = p.y + t.x
		end
	end

	function META:Rotate(phi, center)
		center = center or Vec2(0, 0)

		local c = math.cos(phi)
		local s = math.sin(phi)

		for i, p in ipairs(self.polygons) do
			local vx = p.x - center.x
			local vy = p.y - center.y

			p.x = center.x * vx - s * vy + center.x
			p.y = s * vx + c * vy + center.y
		end
	end

	function META:Scale(scale, center)
		center = center or Vec2(0, 0)

		for i, p in ipairs(self.polygons) do
			p.x = (p.x - center.x) * scale.x + center.x
			p.y = (p.y - center.y) * scale.y + center.y
		end
	end

	function META:SetControlPoint(idx, point)
		self.polygons[idx] = point
	end

	function META:GetControlPoint(idx)
		return self.polygons[idx]
	end

	function META:InsertControlPoint(idx, point)
		table.insert(self.polygons, idx, point)
	end

	function META:RemoveControlPoint(idx)
		table.remove(self.polygons, idx)
	end

	function META:GetControlPointCount()
		return #self.polygons
	end

	function META:GetDegree()
		return #self.polygons
	end

	function META:GetDerivative()
		local diff = {}

		local degree = self:GetDegree()

		for i = 1, #self.polygons - 1 do
			diff[i] = (self.polygons[i + 1] - self.polygons[i]) * degree
		end

		return math2d.CreateBezierCurve(diff)
	end

	function META:Evaluate(t)
		if t < 0 or t > 1 then
			error("Invalid evaluation parameter: must be between 0 and 1", 2)
		end
		if self.polygons < 2 then
			error("Invalid Bezier curve: Not enough control points.", 2)
		end

		local points = table.copy(self.polygons)

		for step = 2, #points do
			for i = 1, #self.polygons - step do
				points[i] = points[i] * (1 - t) + points[i + 1] * t
			end
		end

		return points[1]
	end

	function META:GetSegment(start, stop)
		local points = table.copy(self.polygons)
		local left = {}
		local right = {}

		for step = 2, #points do
			table.insert(left, points[i])
			for i = 1, #self.polygons - step do
				points[i] = points[i] + (points[i + 1] - points[i]) * stop
			end
		end

		table.insert(left, points[1])

		local s = start/stop

		for step = 2, #left do
			table.insert(right, left[#left - step])
			for i = 1, #self.polygons - step do
				left[i] = left[i] + (left[i + 1] - left[i]) * stop
			end
		end
		table.insert(right, left[1])

		local rev = {}

		local i2 = #right
		for i = 1, #right do
			rev[i2] = right[i]
			i2 = i2 - 1
		end

		return math2d.CreateBezierCurve(rev)
	end

	local function subdivide(polygons, k)
		if k <= 0 then
			return polygons
		end
		local left = {}
		local right = {}

		for step = 1, #polygons - 1 do
			table.insert(left, polygons[1])
			table.insert(right, polygons[#polygons - step + 1])

			for i = 0, #polygons - step - 1 do
				i = i + 1
				polygons[i] = (polygons[i] + polygons[i + 1]) * 0.5
			end
		end
		table.insert(left, polygons[1])
		table.insert(right, polygons[1])

		subdivide(left, k - 1)
		subdivide(right, k - 1)

		for i = 1, #left do
			polygons[i] = left[i]
		end

		for i = 1, #right - 1 do
			polygons[(i-1 + #left) + 1] = right[(#right - i - 1) + 1]
		end

		return polygons
	end

	function META:CreateCoordinates(accuracy, start, stop)
		accuracy = accuracy or 5
		local vertices = table.copy(self.polygons)
		subdivide(vertices, accuracy)

		if not start and not stop then
			local out = {}
			for i, p in ipairs(vertices) do
				table.insert(out, p.x)
				table.insert(out, p.y)
			end
			return out
		end

		if start == stop then
			table.clear(vertices)
			return vertices
		end

		local count = #vertices

		local start_idx
		local stop_idx

		if start < stop then
			start_idx = math.clamp(math.round(start * count), 1, count)
			stop_idx = math.clamp(math.round(stop * count + 0.5), 1, count)
		elseif start > stop then
			start_idx = math.clamp(math.round(stop * count + 0.5), 1, count)
			stop_idx = math.clamp(math.round(start * count), 1, count)
		end

		local out = {}
		for i = start_idx, stop_idx do
			table.insert(out, vertices[i].x)
			table.insert(out, vertices[i].y)
		end

		return out
	end

	META:Register()
end

return math2d