local love = ... or _G.love
local ENV = love._lovemu_env

love.math = love.math or {}

for k,v in pairs(math) do
	love.math[k] = v
end

do
	local SEED = 0

	function love.math.setRandomSeed(seed)
		SEED = seed
	end

	function love.math.getRandomSeed(seed)
		return SEED
	end

	function love.math.random(min, max)
		math.randomseed(SEED)
		local val

		if min and max then
			val = math.random(min, max)
		elseif min and not max then
			val = math.random(1, min)
		else
			val = math.random()
		end

		SEED = SEED + val
		return val
	end
end

do
	local RandomGenerator = lovemu.TypeTemplate("RandomGenerator")

	function RandomGenerator:setSeed(seed)
		self.seed = seed
	end

	function RandomGenerator:getSeed()
		return self.seed
	end

	function RandomGenerator:setState(state)
		self.seed = tonumber(state)
	end

	function RandomGenerator:getState()
		return tostring(self.seed)
	end

	function RandomGenerator:random(min, max)
		math.randomseed(self.seed)
		local val
		if min and max then
			val = math.random(min, max)
		elseif min and not max then
			val = math.random(1, min)
		else
			val = math.random()
		end
		math.randomseed(os.clock())
		return val
	end

	function RandomGenerator:randomNormal()

	end

	function love.math.newRandomGenerator()
		local self = lovemu.CreateObject("RandomGenerator")

		self.seed = 0

		return self
	end

	lovemu.RegisterType(RandomGenerator)
end

do
	local BezierCurve = lovemu.TypeTemplate("BezierCurve")

	function love.math.newBezierCurve(...)
		local self = lovemu.CreateObject("BezierCurve")
		local points
		if type(...) == "number" then
			points = {...}
		else
			points = ...
		end

		local polygons = {}
		for i = 1, #points, 2 do
			table.insert(polygons, Vec2(points[i + 0], points[i + 1]))
		end

		self.polygons = polygons
		return self
	end

	function BezierCurve:translate(tx, ty)
		for i, p in ipairs(self.polygons) do
			p.x = p.x + tx
			p.y = p.y + tx
		end
	end

	function BezierCurve:rotate(phi, cx, cy)
		cx = cx or 0
		cy = cy or 0
		local c = math.cos(phi)
		local s = math.sin(phi)

		for i, p in ipairs(self.polygons) do
			local vx = p.x - cx
			local vy = p.y - cy

			p.x = cx * vx - s * vy + cx
			p.y = s * vx + c * vy + cy
		end
	end

	function BezierCurve:scale(s, cx, cy)
		cx = cx or 0
		cy = cy or 0
		for i, p in ipairs(self.polygons) do
			p.x = (p.x - cx) * s + cx
			p.y = (p.y - cy) * s + cy
		end
	end

	function BezierCurve:setControlPoint(idx, x, y)
		self.polygons[idx].x = x
		self.polygons[idx].y = y
	end

	function BezierCurve:getControlPoint(idx)
		return self.polygons[idx]:Unpack()
	end

	function BezierCurve:insertControlPoint(idx, x, y)
		table.insert(self.polygons, idx, Vec2(x, y))
	end

	function BezierCurve:removeControlPoint(idx)
		table.remove(self.polygons, idx)
	end

	function BezierCurve:getControlPointCount()
		return #self.polygons
	end

	function BezierCurve:getDegree()
		return #self.polygons
	end

	function BezierCurve:getDerivative()
		local diff = {}

		local degree = self:getDegree()
		for i = 1, #self.polygons - 1 do
			diff[i] = (self.polygons[i + 1] - self.polygons[i]) * degree
		end

		return love.graphics.newBezierCurve(diff)
	end

	function BezierCurve:evaluate(t)
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

	function BezierCurve:getSegment(t1, t2)
		local points = table.copy(self.polygons)
		local left = {}
		local right = {}

		for step = 2, #points do
			table.insert(left, points[i])
			for i = 1, #self.polygons - step do
				points[i] = points[i] + (points[i + 1] - points[i]) * t2
			end
		end

		table.insert(left, points[1])

		local s = t1/t2

		for step = 2, #left do
			table.insert(right, left[#left - step])
			for i = 1, #self.polygons - step do
				left[i] = left[i] + (left[i + 1] - left[i]) * t2
			end
		end
		table.insert(right, left[1])

		local rev = {}

		local i2 = #right
		for i = 1, #right do
			rev[i2] = right[i]
			i2 = i2 - 1
		end

		return love.graphics.newBezierCurve(rev)
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

	function BezierCurve:render(accuracy)
		accuracy = accuracy or 5
		local vertices = table.copy(self.polygons)
		subdivide(vertices, accuracy)
		local out = {}
		for i, p in ipairs(vertices) do
			table.insert(out, p.x)
			table.insert(out, p.y)
		end
		return out
	end

	function BezierCurve:renderSegment(start, stop, accuracy)
		accuracy = accuracy or 5
		local vertices = table.copy(self.polygons)
		subdivide(vertices, accuracy)

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

	lovemu.RegisterType(BezierCurve)
end

function love.math.isConvex(...)
	local points

	if type(...) == "number" then
		points = {...}
	else
		points = ...
	end

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

	function love.math.triangulate(...)
		local points
		if type(...) == "number" then
			points = {...}
		else
			points = ...
		end

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
				table.insert(triangles, a.x)
				table.insert(triangles, a.y)
				table.insert(triangles, b.x)
				table.insert(triangles, b.y)
				table.insert(triangles, c.x)
				table.insert(triangles, c.y)
				next_idx[prev] = next
				prev_idx[next] = prev
				table.remove(concave, current + 1)
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

		table.insert(triangles, a.x)
		table.insert(triangles, a.y)
		table.insert(triangles, b.x)
		table.insert(triangles, b.y)
		table.insert(triangles, c.x)
		table.insert(triangles, c.y)

		return triangles
	end
end