local love = ... or _G.love
local ENV = love._line_env

love.physics = love.physics or {}

local Shape = {}

function Shape:computeAABB(tx, ty, tr, childIndex)
	return 0,0,0,0
end

function Shape:computeMass(density)
	return 0,0, 0, 0
end

function Shape:getChildCount()
	return 0
end

function Shape:getType()
	return self.ShapeType
end

function Shape:rayCast(x1, y1, x2, y2, maxFraction, tx, ty, tr, childIndex)
	return 0, 0, 0
end

function Shape:testPoint(tx, ty, tr, x, y)
	return false
end

function Shape:getRadius()
	return 0
end

local function shape_template(name)
	local meta = line.TypeTemplate(name .. "Shape")

	meta.ShapeType = name:lower()

	for k, v in pairs(Shape) do
		meta[k] = v
	end

	return meta
end

do
	local CircleShape = shape_template("Circle")

	function CircleShape:setRadius(r)
		self.radius = r
	end

	function CircleShape:getRadius()
		return self.radius
	end

	line.RegisterType(CircleShape)

	function love.physics.newCircleShape(a, b, c)
		local x, y
		local radius

		if not b and not c then
			y = 0
			x = 0
			radius = a
		else
			x = a
			y = b
			radius = c
		end

		local self = line.CreateObject("CircleShape")

		self.radius = radius
		self.x = x
		self.y = y

		return self
	end
end

do
	local EdgeShape = shape_template("Edge")

	function EdgeShape:getPoints(r)
		return unpack(self.points)
	end

	line.RegisterType(EdgeShape)

	function love.physics.newEdgeShape(x1, y1, x2, y2)

		local self = line.CreateObject("EdgeShape")

		self.points = {x1, y1, x2, y2}

		return self
	end
end

do
	local PolygonShape = shape_template("Polygon")

	function PolygonShape:getPoints(r)
		return unpack(self.points)
	end

	line.RegisterType(PolygonShape)

	function love.physics.newPolygonShape(...)

		local self = line.CreateObject("PolygonShape")

		self.points = {...}

		return self
	end

	function love.physics.newRectangleShape(...)

		local self = line.CreateObject("PolygonShape")

		self.points = {...}

		return self
	end
end