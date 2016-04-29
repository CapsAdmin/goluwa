local structs = (...) or _G.structs

local META = {}

META.ClassName = "Ang3"

function Deg3(p, y, r)
	return Ang3(p, y, r):Rad()
end

META.NumberType = "float"
META.Args = {{"x", "p", "pitch"}, {"y", "yaw"}, {"z", "r", "roll"}}

structs.AddAllOperators(META)

local sin = math.sin
local cos = math.cos

function META.GetForward(a)
	return Vec3(
		cos(a.y) * cos(a.x),
		sin(a.y) * cos(a.x),
	   -sin(a.x)
	)
end

function META.GetUp(a)
	return Vec3(
		sin(a.y) * sin(a.z) + cos(a.y) * sin(a.x) * cos(a.z),
	   -cos(a.y) * sin(a.z) + sin(a.y) * sin(a.x) * cos(a.z),
		cos(a.x) * cos(a.z)
	)
end

function META.GetRight(a)
	return a:GetForward():Cross(a:GetUp())
end

local PI1 = math.pi
local PI2 = math.pi * 2
local function normalize(a)
	return (a + PI1) % PI2 - PI1
end

function META:Normalize()
	self.x = normalize(self.x)
	self.y = normalize(self.y)
	self.z = normalize(self.z)

	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")

function META.AngleDifference(a, b)
	a.x = normalize(a.x - b.x)
	a.y = normalize(a.y - b.y)
	a.z = normalize(a.z - b.z)

	a.x = a.x < PI2 and a.x or a.x - PI2
	a.y = a.y < PI2 and a.y or a.y - PI2
	a.z = a.z < PI2 and a.z or a.z - PI2

	return a
end

structs.AddGetFunc(META, "AngleDifference")

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z

	a:Normalize()

	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Rad()
	self.x = math.rad(self.x)
	self.y = math.rad(self.y)
	self.z = math.rad(self.z)

	return self
end

structs.AddGetFunc(META, "Rad")

function META:Deg()
	self.x = math.deg(self.x)
	self.y = math.deg(self.y)
	self.z = math.deg(self.z)

	return self
end

structs.AddGetFunc(META, "Deg")


-- LOL
function META:RotateAroundAxis(axis, rad)
	local mat = Matrix44():SetRotation(Quat():SetAngles(self))
	mat:Rotate(rad, axis:Unpack())
	self:Set(mat:GetRotation():GetAngles():Unpack())
	return self
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("ang3", function(var) return ("Ang3(%f, %f, %f)"):format(var:Unpack()) end, structs.Ang3, "Ang3")