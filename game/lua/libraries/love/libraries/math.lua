local love = ... or _G.love
local ENV = love._line_env

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

	do
		local noise = require("noise")

		function love.math.noise(x,y,w,h)
			if x and y and z and w then
				math.randomseed(x)
				return math.random(), noise.Simplex3D(y, z, w)
			elseif x and y and z then
				return noise.Simplex3D(x, y, z)
			elseif x and y then
				return noise.Simplex2D(x, y)
			elseif x then
				math.randomseed(x)
				return math.random()
			end
		end
	end
end

do
	local RandomGenerator = line.TypeTemplate("RandomGenerator")

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
		local self = line.CreateObject("RandomGenerator")

		self.seed = 0

		return self
	end

	line.RegisterType(RandomGenerator)
end

do
	local BezierCurve = line.TypeTemplate("BezierCurve")

	function love.math.newBezierCurve(...)
		local self = line.CreateObject("BezierCurve")
		local points
		if ... and type(...) == "number" then
			points = {...}
		else
			points = ... or {}
		end

		local polygons = {}
		for i = 1, #points, 2 do
			table.insert(polygons, Vec2(points[i + 0], points[i + 1]))
		end

		self.obj = math2d.CreateBezierCurve(polygons)

		return self
	end

	function BezierCurve:translate(tx, ty)
		self.obj:Translate(Vec2(tx, ty))
	end

	function BezierCurve:rotate(phi, cx, cy)
		cx = cx or 0
		cy = cy or 0

		self.obj:Rotate(phi, Vec2(cx, cy))
	end

	function BezierCurve:scale(s, cx, cy)
		cx = cx or 0
		cy = cy or 0

		self.obj:Scale(s, Vec2(cx, cy))
	end

	function BezierCurve:setControlPoint(idx, x, y)
		self.obj:SetControlPoint(idx, Vec2(x, y))
	end

	function BezierCurve:getControlPoint(idx)
		return self.obj:GetControlPoint(idx):Unpack()
	end

	function BezierCurve:insertControlPoint(idx, x, y)
		self.obj:InsertControlPoint(idx, Vec2(x, y))
	end

	function BezierCurve:removeControlPoint(idx)
		self.obj:RemoveControlPoint(idx)
	end

	function BezierCurve:getControlPointCount()
		return self.obj:GetControlPointCount()
	end

	function BezierCurve:getDegree()
		return self.obj:GetDegree()
	end

	function BezierCurve:getDerivative()
		local self2 = love.math.newBezierCurve()
		self2.obj = self.obj:GetDerivative()
		return self2
	end

	function BezierCurve:evaluate(t)
		return self.obj:Evaluate(t):Unpack()
	end

	function BezierCurve:getSegment(t1, t2)
		local self = love.math.newBezierCurve()
		self.obj = self.obj:GetSegment(t1, t2)
		return self
	end

	function BezierCurve:render(accuracy)
		return self.obj:CreateCoordinates(accuracy)
	end

	function BezierCurve:renderSegment(start, stop, accuracy)
		return self.obj:CreateCoordinates(accuracy, start, stop)
	end

	line.RegisterType(BezierCurve)
end

function love.math.isConvex(...)
	local points

	if type(...) == "number" then
		points = {...}
	else
		points = ...
	end

	return math2d.IsCoordinatesConvex(points)
end

function love.math.triangulate(...)
	local points
	if type(...) == "number" then
		points = {...}
	else
		points = ...
	end

	return math2d.TriangulateCoordinates(points)
end
