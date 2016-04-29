local structs = (...) or _G.structs

local META = {}

META.ClassName = "Quat"

META.NumberType = "float"
META.Args = {"x", "y", "z", "w"}

structs.AddAllOperators(META)

function QuatDeg3(...)
    return Quat():SetAngles(Deg3(...))
end

function META:Identity()
	self.x = 0
	self.y = 0
	self.z = 0
	self.w = 1
end

function META:SetAxis(rad, axis)
	rad = rad * 0.5
	local s = math.sin(rad)
	self:Set(axis.x * s, axis.y * s, axis.z * s, math.cos(rad))

	return self
end

function META.HamRight(a, b)

	if type(b) == "number" then
		a.x = a.x * b
		a.y = a.y * b
		a.z = a.z * b
		a.w = a.w * b
	elseif type(a) == "number" then
		return META.HamRight(b, a)
	else
		a.x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y
		a.y = a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z
		a.z = a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x
		a.w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z
	end

	return a
end


function META.VecMul(a, b)
    local vec, quat
    if typex(a) == "vec3" then
        vec, quat = a, b
    else
        vec, quat = b, a
    end
	local qvec = Vec3(quat.x, quat.y, quat.z)
	local uvec = qvec:GetCross(vec)
	local uuvec = qvec:GetCross(uvec)
	uvec, uuvec = uvec*2*a.x, uuvec*2
	return vec+uvec+uuvec
end

function META:Right() return self:VecMul(Vec3( 0, -1, 0)) end META.GetRight = META.Right
function META:Left () return self:VecMul(Vec3( 0, 1, 0)) end META.GetLeft  = META.Left
function META:Up   () return self:VecMul(Vec3( 0, 0, 1)) end META.GetUp    = META.Up
function META:Down () return self:VecMul(Vec3( 0, 0, -1)) end META.GetDown  = META.Down
function META:Front() return self:VecMul(Vec3( 1, 0, 0)) end META.GetFront = META.Front
function META:Back () return self:VecMul(Vec3( -1, 0,0)) end META.GetBack = META.Back
META.Forward = META.Front
META.GetForward = META.Front
META.Backward = META.Back
META.GetBackward = META.Back

function META.Divide(a, b)

	if type(b) == "number" then
		a.x = a.x / b
		a.y = a.y / b
		a.z = a.z / b
		a.w = a.w / b
	elseif type(a) == "number" then
		return META.Multiply(b, a)
	else
		--return self:GetConjugated():Multiply(self:Dot(self))
	end

	return a
end

function META:Conjugate()
	self.x = -self.x
	self.y = -self.y
	self.z = -self.z
end

structs.AddGetFunc(META, "Conjugate", "Conjugated")

function META.Lerp(a, mult, b)

	a.x = (b.x - a.x) * mult + a.x
	a.y = (b.y - a.y) * mult + a.y
	a.z = (b.z - a.z) * mult + a.z
	a.w = (b.w - a.w) * mult + a.w

	return a
end

structs.AddGetFunc(META, "Lerp", "Lerped")

function META:Dot(vec)
	return self.w*vec.w + self.x*vec.x + self.y*vec.y + self.z*vec.z
end

function META:GetLength()
	return math.sqrt(self:Dot(self))
end

function META:Normalize()
	local len = self:GetLength()

	if len > 0 then
		local div = 1 / len
		self.x = self.x * div
		self.y = self.y * div
		self.z = self.z * div
		self.w = self.w * div
	else
		self:Identity()
	end

	return self
end

structs.AddGetFunc(META, "Normalize", "Normalized")


-- https://github.com/grrrwaaa/gct753/blob/master/modules/quat.lua#L193

function META:SetAngles(ang)
	local c1 = math.cos(ang.z * 0.5)
	local c2 = math.cos(ang.x * 0.5)
	local c3 = math.cos(ang.y * 0.5)

	local s1 = math.sin(ang.z * 0.5)
	local s2 = math.sin(ang.x * 0.5)
	local s3 = math.sin(ang.y * 0.5)

	-- equiv Q1 = Qy * Qx; -- since many terms are zero
	local tw = c1*c2
	local tx = c1*s2
	local ty = s1*c2
	local tz =-s1*s2

	-- equiv Q2 = Q1 * Qz; -- since many terms are zero
	self.x = tx*c3 + ty*s3
	self.y = ty*c3 - tx*s3
	self.z = tw*s3 + tz*c3
	self.w = tw*c3 - tz*s3

	return self
end

-- https://github.com/grrrwaaa/gct753/blob/master/modules/quat.lua#L465

local function twoaxisrot(r11, r12, r21, r31, r32)
	return Ang3(math.atan2(r11, r12), math.acos(r21), math.atan2(r31, r32))
end

local function threeaxisrot(r11, r12, r21, r31, r32)
	return Ang3(math.atan2(r31, r32), math.asin(r21), math.atan2(r11, r12))
end

function META.GetAngles(q, seq)
	--seq = seq or "xzy"

	if not seq then
		local sqw = q.w*q.w
		local sqx = q.x*q.x
		local sqy = q.y*q.y
		local sqz = q.z*q.z

		return
			Ang3(
				math.asin (-2.0 * (q.x*q.z - q.w*q.y)),
				math.atan2( 2.0 * (q.x*q.y + q.w*q.z), (sqw + sqx - sqy - sqz)),
				math.atan2( 2.0 * (q.y*q.z + q.w*q.x), (sqw - sqx - sqy + sqz))
			)
	elseif seq == "zyx" then
		return threeaxisrot(
			2*(q.x*q.y + q.w*q.z),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z,
			-2*(q.x*q.z - q.w*q.y),
			2*(q.y*q.z + q.w*q.x),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z
		)
	elseif seq == "zyz" then
		return twoaxisrot(
			2*(q.y*q.z - q.w*q.x),
			2*(q.x*q.z + q.w*q.y),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z,
			2*(q.y*q.z + q.w*q.x),
			-2*(q.x*q.z - q.w*q.y)
		)
	elseif seq == "zxy" then
		return threeaxisrot(
			-2*(q.x*q.y - q.w*q.z),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z,
			2*(q.y*q.z + q.w*q.x),
			-2*(q.x*q.z - q.w*q.y),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z
		)
	elseif seq == "zxz" then
		return twoaxisrot(
			2*(q.x*q.z + q.w*q.y),
			-2*(q.y*q.z - q.w*q.x),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z,
			2*(q.x*q.z - q.w*q.y),
			2*(q.y*q.z + q.w*q.x)
		)
	elseif seq == "yxz" then
		return threeaxisrot(
			2*(q.x*q.z + q.w*q.y),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z,
			-2*(q.y*q.z - q.w*q.x),
			2*(q.x*q.y + q.w*q.z),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z
		)
	elseif seq == "yxy" then
		return twoaxisrot(
			2*(q.x*q.y - q.w*q.z),
			2*(q.y*q.z + q.w*q.x),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z,
			2*(q.x*q.y + q.w*q.z),
			-2*(q.y*q.z - q.w*q.x)
		)
	elseif seq == "yzx" then
		return threeaxisrot(
			-2*(q.x*q.z - q.w*q.y),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z,
			2*(q.x*q.y + q.w*q.z),
			-2*(q.y*q.z - q.w*q.x),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z
		)
	elseif seq == "yzy" then
		return twoaxisrot(
			2*(q.y*q.z + q.w*q.x),
			-2*(q.x*q.y - q.w*q.z),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z,
			2*(q.y*q.z - q.w*q.x),
			2*(q.x*q.y + q.w*q.z)
		)
	elseif seq == "xyz" then
		return threeaxisrot(
			-2*(q.y*q.z - q.w*q.x),
			q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z,
			2*(q.x*q.z + q.w*q.y),
			-2*(q.x*q.y - q.w*q.z),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z
		)
	elseif seq == "xyx" then
		return twoaxisrot(
			2*(q.x*q.y + q.w*q.z),
			-2*(q.x*q.z - q.w*q.y),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z,
			2*(q.x*q.y - q.w*q.z),
			2*(q.x*q.z + q.w*q.y)
		)
	elseif seq == "xzy" then
		return threeaxisrot(
			2*(q.y*q.z + q.w*q.x),
			q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z,
			-2*(q.x*q.y - q.w*q.z),
			2*(q.x*q.z + q.w*q.y),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z
		)
	elseif seq == "xzx" then
		return twoaxisrot(
			2*(q.x*q.z - q.w*q.y),
			2*(q.x*q.y + q.w*q.z),
			q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z,
			2*(q.x*q.z + q.w*q.y),
			-2*(q.x*q.y - q.w*q.z)
		)
	end
end

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("quat", function(var) return ("Quat(%f, %f, %f, %f)"):format(var:Unpack()) end, structs.Quat, "Quat")