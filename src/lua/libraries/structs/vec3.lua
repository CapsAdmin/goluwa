local structs = (...) or _G.structs

local META = {}

META.ClassName = "Vec3"

META.NumberType = "float"
META.Args = {"x", "y", "z"}

structs.AddAllOperators(META)

-- length stuff
do
	function META:GetLengthSquared()
		return self.x * self.x + self.y * self.y + self.z * self.z
	end

	function META:SetLength(num)
		if num == 0 then
			self.x = 0
			self.y = 0
			self.z = 0
			return
		end

		local scale = math.sqrt(self:GetLengthSquared()) * num

		self.x = self.x / scale
		self.y = self.y / scale
		self.z = self.z / scale

		return self
	end

	function META:GetLength()
		return math.sqrt(self:GetLengthSquared())
	end

	META.__len = META.GetLength

	function META.__lt(a, b)
		if ffi.istype(a, b) and type(b) == "number" then
			return a:GetLength() < b
		elseif ffi.istype(b, a) and type(a) == "number" then
			return b:GetLength() < a
		end
	end

	function META.__le(a, b)
		if ffi.istype(a, b) and type(b) == "number" then
			return a:GetLength() <= b
		elseif ffi.istype(b, a) and type(a) == "number" then
			return b:GetLength() <= a
		end
	end

	function META:SetMaxLength(num)
		local length = self:GetLengthSquared()

		if length * length > num then
			local scale = math.sqrt(length) * num

			self.x = self.x / scale
			self.y = self.y / scale
			self.z = self.z / scale
		end

		return self
	end

	function META.Distance(a, b)
		return (a - b):GetLength()
	end
end

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z

	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Normalize()
	local sqr = self:GetLengthSquared()

	if sqr == 0 then return self end

	local len = math.sqrt(sqr)

	self.x = self.x / len
	self.y = self.y / len
	self.z = self.z / len

	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")

function META.Cross(a, b)
	local x, y, z = a.x, a.y, a.z
	a.x = y * b.z - z * b.y
	a.y = z * b.x - x * b.z
	a.z = x * b.y - y * b.x
	return a
end

structs.AddGetFunc(META, "Cross")

function META.GetDot(a, b)
	return
		a.x * b.x +
		a.y * b.y +
		a.z * b.z
end

function META:GetVolume()
	return self.x * self.y * self.z
end

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

META.ToScreen = math3d.WorldPositionToScreen

structs.Register(META)