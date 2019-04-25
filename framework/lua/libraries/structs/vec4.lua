local structs = (...) or _G.structs

local META = prototype.CreateTemplate("Vec4")

META.NumberType = "double"
META.Args = {"x", "y", "z", "w"}

structs.AddAllOperators(META)

-- length stuff
do
	function META:GetLengthSquared()
		return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
	end

	function META:SetLength(num)
		if num == 0 then
			self.x = 0
			self.y = 0
			self.z = 0
			self.w = 0
			return
		end

		local scale = math.sqrt(self:GetLengthSquared()) * num

		self.x = self.x / scale
		self.y = self.y / scale
		self.z = self.z / scale
		self.w = self.w / scale

		return self
	end

	function META:GetLength()
		return math.sqrt(self:GetLengthSquared())
	end

	META.__len = META.GetLength

	function META.__lt(a, b)
		if structs.IsType(a, b) and type(b) == "number" then
			return a:GetLength() < b
		elseif structs.IsType(b, a) and type(a) == "number" then
			return b:GetLength() < a
		end
	end

	function META.__le(a, b)
		if structs.IsType(a, b) and type(b) == "number" then
			return a:GetLength() <= b
		elseif structs.IsType(b, a) and type(a) == "number" then
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
			self.w = self.w / scale
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
	self.w = self.w / len

	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("vec4", function(var) return ("Vec4(%f, %f, %f)"):format(var:Unpack()) end, structs.Vec4, "Vec4")
