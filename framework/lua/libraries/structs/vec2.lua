local structs = (...) or _G.structs

local META = prototype.CreateTemplate("Vec2")

META.NumberType = "double"
META.Args = {{"x", "w", "p", "r"}, {"y", "h", "y", "g"}}

structs.AddAllOperators(META)
structs.AddOperator(META, "generic_vector")

structs.Swizzle(META)

function META:Rotate(angle)
	local cs = math.cos(angle);
	local sn = math.sin(angle);

	local xx = self.x * cs - self.y * sn;
	local yy = self.x * sn + self.y * cs;

	self.x = xx
	self.y = yy

	return self
end

structs.AddGetFunc(META, "Rotate", "Rotated")

function META.GetDot(a, b)
	return
		a.x * b.x +
		a.y * b.y
end


function META:GetNormal(scale)
	return Vec2(-self.y * scale, self.x * scale)
end

function META.GetCrossed(a, b)
	return a.x * b.y - a.y * b.x
end

function META:GetReflected(normal)
	local proj = self:GetNormalized()
	local dot = proj:GetDot(normal)

  return Vec2(2 * (-dot) * normal.x + proj.x, 2 * (-dot) * normal.y + proj.y) * self:GetLength()
end

function META:Rotate90CCW()
	local x, y = self:Unpack()

	self.x = -y
	self.y = x

	return self
end

function META:Rotate90CW()
	local x, y = self:Unpack()

	self.x = y
	self.y = -x

	return self
end

function META:GetRad()
	return math.atan2(self.x, self.y)
end

function META:GetDeg()
	return math.deg(self:GetRad())
end

if GRAPHICS then
	META.ToWorld = math3d.ScreenToWorldDirection
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("vec2", function(var) return ("Vec2(%f, %f)"):format(var:Unpack()) end, structs.Vec2, "Vec2")
