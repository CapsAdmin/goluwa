local gfx = (...) or _G.gfx

local META = prototype.CreateTemplate("quadric_bezier_curve")

META:GetSet("JoinLast", true)
META:GetSet("MaxLines", 0)

function gfx.CreateQuadricBezierCurve(count)
	local self = META:CreateObject()

	self.nodes = {}
	self.MaxLines = count

	return self
end

function META:Add(point, control)
	self:Set(#self.nodes + 1, point, control)
	self.MaxLines = #self.nodes
end

function META:Set(i, point, control)
	self.nodes[i] = self.nodes[i] or {}
	if point then
		self.nodes[i].point = self.nodes[i].point or Vec2()
		self.nodes[i].point.x = point.x
		self.nodes[i].point.y = point.y
	end
	if control then
		self.nodes[i].control = self.nodes[i].control or Vec2()
		self.nodes[i].control.x = control.x
		self.nodes[i].control.y = control.y
	else
		self.nodes[i].control = nil
	end
end

local function quadratic_bezier(a, b, control, t)
	return (1 - t) * (1 - t) * a + (2 - 2 * t) * t * control + b * t * t
end

function META:ConvertToPoints(quality)
	quality = quality or 60

	local points = {}
	local precision = 1 / quality

	for i = 1, self.MaxLines do
		local current = self.nodes[i]
		local next = self.nodes[i + 1]
		if self.JoinLast then
			if i == self.MaxLines then
				next = self.nodes[1]
			end
		else
			if i ~= self.MaxLines then
				break
			end
		end
		local current_control = current.control or current.point:GetLerped(0.5, next.point)

		for step = 0, 1, precision do
			table.insert(points, quadratic_bezier(current.point, next.point, current_control, step))
		end
	end

	return points
end

local function line_segment_normal(a, b)
	return Vec2(b.y - a.y, a.x - b.x):Normalize()
end

function META:CreateOffsetedCurve(offset)
	local offseted = gfx.CreateQuadricBezierCurve()

	for i = 1, self.MaxLines do
		local current = self.nodes[i]
		local next = self.nodes[i+1]
		if self.JoinLast then
			if i == self.MaxLines then
				next = self.nodes[1]
			end
		else
			if i ~= self.MaxLines then
				break
			end
		end
		local prev = self.nodes[i-1] or self.nodes[self.MaxLines]
		local current_control = current.control or current.point:GetLerped(0.5, next.point)
		local prev_control = prev.control or prev.point:GetLerped(0.5, current.point)

		local normal = line_segment_normal(current.point, current_control)
		normal = normal + line_segment_normal(prev_control, current.point)
		normal:Normalize()

		local surface_normal = line_segment_normal(current.point, next.point)

		offseted:Add(current.point + normal * offset, current_control + surface_normal * offset)
	end

	return offseted
end

function META:ConstructPoly(width, quality, stretch, poly)
	width = width or 30
	stretch = stretch or 1

	local negative_points = self:CreateOffsetedCurve(-width):ConvertToPoints(quality)
	local positive_points = self:CreateOffsetedCurve(width):ConvertToPoints(quality)

	local poly = poly or gfx.CreatePolygon(#positive_points * 2)
	local distance_positive = 0

	for i in ipairs(positive_points) do
		if i > 1 then
			distance_positive = distance_positive +
			(negative_points[i - 1]:Distance(negative_points[i]) + positive_points[i - 1]:Distance(positive_points[i])) / stretch / 2
		end

		poly:SetVertex((i - 1) * 2, negative_points[i].x, negative_points[i].y, distance_positive, 0)
		poly:SetVertex((i - 1) * 2 + 1, positive_points[i].x, positive_points[i].y, distance_positive, 1)
	end

	return poly
end

META:Register()