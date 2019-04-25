local structs = (...) or _G.structs

local META = prototype.CreateTemplate("Vec3")

META.NumberType = "double"
META.Args = {{"x", "r", "p"}, {"y", "g", "y"},  {"z", "b", "r"}}

structs.AddAllOperators(META)
structs.AddOperator(META, "generic_vector")

structs.Swizzle(META)
structs.Swizzle(META, 2, "structs.Vec2")


function META.Cross(a, b)
	local x, y, z = a.x, a.y, a.z

	a.x = y * b.z - z * b.y
	a.y = z * b.x - x * b.z
	a.z = x * b.y - y * b.x

	return a
end
structs.AddGetFunc(META, "Cross")

function META:GetAngles()
	local n = self:GetNormalized()

	local p = math.atan2(math.sqrt((n.x ^ 2) + (n.y ^ 2)), n.z)
	local y = math.atan2(self.y, self.x)

	return structs.Ang3(p, y, 0)
end

function META:GetRotated(axis, ang)
	local ca, sa = math.sin(ang), math.cos(ang)

	local zax = axis * self:GetDot(axis)
	local xax = self - zax
	local yax = axis:GetCross(zax)

	return xax * ca + yax * sa + zax
end

function META:GetReflected(normal)
	local proj = self:GetNormalized()
	local dot = proj:GetDot(normal)

	return Vec3(2 * (-dot) * normal.x + proj.x, 2 * (-dot) * normal.y + proj.y, 2 * (-dot) * normal.z + proj.z) * self:GetLength()
end

if GRAPHICS then
	META.ToScreen = math3d.WorldPositionToScreen
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("vec3", function(var) return ("Vec3(%f, %f, %f)"):format(var:Unpack()) end, structs.Vec3, "Vec3")
