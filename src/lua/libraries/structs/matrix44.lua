local structs = (...) or _G.structs
local light_ctor
--[[local META = {}

function META:Constructor()
	self:LoadIdentity()
end

structs.AddOperator(META, "==")
structs.AddOperator(META, "copy")]]

local META = {}
META.__index = META

META.Type = "matrix44"
META.TypeX = "matrix44"

META.ClassName = "Matrix44"
META.NumberType = "float"
META.Args = {
	"m00", "m01", "m02", "m03",
	"m10", "m11", "m12", "m13",
	"m20", "m21", "m22", "m23",
	"m30", "m31", "m32", "m33",
}

structs.AddOperator(META, "==")

local size = ffi.sizeof("float") * 16

function META:Copy(matrix)
	if matrix then
		ffi.copy(self, matrix, 16)

		return self
	else
		local result = light_ctor()

		ffi.copy(result, self, size)

		return result
	end
end

META.__copy = META.Copy

function META:__tostring()
	return string.format("matrix44[%p]:\n" .. ("%f %f %f %f\n"):rep(4), self,
		self.m00, self.m01, self.m02, self.m03,
		self.m10, self.m11, self.m12, self.m13,
		self.m20, self.m21, self.m22, self.m23,
		self.m30, self.m31, self.m32, self.m33
	)
end

function META:__mul(b)
	return self:GetMultiplied(b)
end

function META:Identity()
	self.m00 = 1
	self.m11 = 1
	self.m22 = 1
	self.m33 = 1

	self.m01 = 0
	self.m02 = 0
	self.m03 = 0
	self.m10 = 0
	self.m12 = 0
	self.m13 = 0
	self.m20 = 0
	self.m21 = 0
	self.m23 = 0
	self.m30 = 0
	self.m31 = 0
	self.m32 = 0

	return self
end

META.LoadIdentity = META.Identity

function META:GetInverse(out)
	out = out or light_ctor()

	out.m00 = self.m11*self.m22*self.m33 - self.m11*self.m32*self.m23 - self.m12*self.m21*self.m33 + self.m12*self.m31*self.m23 + self.m13*self.m21*self.m32 - self.m13*self.m31*self.m22
	out.m01 = -self.m01*self.m22*self.m33 + self.m01*self.m32*self.m23 + self.m02*self.m21*self.m33 - self.m02*self.m31*self.m23 - self.m03*self.m21*self.m32 + self.m03*self.m31*self.m22
	out.m02 = self.m01*self.m12*self.m33 - self.m01*self.m32*self.m13 - self.m02*self.m11*self.m33 + self.m02*self.m31*self.m13 + self.m03*self.m11*self.m32 - self.m03*self.m31*self.m12
	out.m03 = -self.m01*self.m12*self.m23 + self.m01*self.m22*self.m13 + self.m02*self.m11*self.m23 - self.m02*self.m21*self.m13 - self.m03*self.m11*self.m22 + self.m03*self.m21*self.m12

	out.m10 = -self.m10*self.m22*self.m33 + self.m10*self.m32*self.m23 + self.m12*self.m20 *self.m33 - self.m12*self.m30*self.m23 - self.m13*self.m20 *self.m32 + self.m13*self.m30*self.m22
	out.m11 = self.m00*self.m22*self.m33 - self.m00*self.m32*self.m23 - self.m02*self.m20 *self.m33 + self.m02*self.m30*self.m23 + self.m03*self.m20 *self.m32 - self.m03*self.m30*self.m22
	out.m12 = -self.m00*self.m12*self.m33 + self.m00*self.m32*self.m13 + self.m02*self.m10*self.m33 - self.m02*self.m30*self.m13 - self.m03*self.m10*self.m32 + self.m03*self.m30*self.m12
	out.m13 = self.m00*self.m12*self.m23 - self.m00*self.m22*self.m13 - self.m02*self.m10*self.m23 + self.m02*self.m20 *self.m13 + self.m03*self.m10*self.m22 - self.m03*self.m20 *self.m12

	out.m20 = self.m10*self.m21*self.m33 - self.m10*self.m31*self.m23 - self.m11*self.m20 *self.m33 + self.m11*self.m30*self.m23 + self.m13*self.m20 *self.m31 - self.m13*self.m30*self.m21
	out.m21 = -self.m00*self.m21*self.m33 + self.m00*self.m31*self.m23 + self.m01*self.m20 *self.m33 - self.m01*self.m30*self.m23 - self.m03*self.m20 *self.m31 + self.m03*self.m30*self.m21
	out.m22 = self.m00*self.m11*self.m33 - self.m00*self.m31*self.m13 - self.m01*self.m10*self.m33 + self.m01*self.m30*self.m13 + self.m03*self.m10*self.m31 - self.m03*self.m30*self.m11
	out.m23 = -self.m00*self.m11*self.m23 + self.m00*self.m21*self.m13 + self.m01*self.m10*self.m23 - self.m01*self.m20 *self.m13 - self.m03*self.m10*self.m21 + self.m03*self.m20 *self.m11

	out.m30 = -self.m10*self.m21*self.m32 + self.m10*self.m31*self.m22 + self.m11*self.m20 *self.m32 - self.m11*self.m30*self.m22 - self.m12*self.m20 *self.m31 + self.m12*self.m30*self.m21
	out.m31 = self.m00*self.m21*self.m32 - self.m00*self.m31*self.m22 - self.m01*self.m20 *self.m32 + self.m01*self.m30*self.m22 + self.m02*self.m20 *self.m31 - self.m02*self.m30*self.m21
	out.m32 = -self.m00*self.m11*self.m32 + self.m00*self.m31*self.m12 + self.m01*self.m10*self.m32 - self.m01*self.m30*self.m12 - self.m02*self.m10*self.m31 + self.m02*self.m30*self.m11
	out.m33 = self.m00*self.m11*self.m22 - self.m00*self.m21*self.m12 - self.m01*self.m10*self.m22 + self.m01*self.m20 *self.m12 + self.m02*self.m10*self.m21 - self.m02*self.m20 *self.m11

	local det = 1 / (self.m00*out.m00 + self.m01*out.m10 + self.m02*out.m20 + self.m03*out.m30)

	out.m00 = out.m00 * det
	out.m01 = out.m01 * det
	out.m02 = out.m02 * det
	out.m03 = out.m03 * det
	out.m10 = out.m10 * det
	out.m11 = out.m11 * det
	out.m12 = out.m12 * det
	out.m13 = out.m13 * det
	out.m20 = out.m20 * det
	out.m21 = out.m21 * det
	out.m22 = out.m22 * det
	out.m23 = out.m23 * det
	out.m30 = out.m30 * det
	out.m31 = out.m31 * det
	out.m32 = out.m32 * det
	out.m33 = out.m33 * det

	return out
end

function META:GetTranspose(out)
	out = out or light_ctor()

	out.m00 = self.m00
	out.m01 = self.m10
	out.m02 = self.m20
	out.m03 = self.m30

	out.m10 = self.m01
	out.m11 = self.m11
	out.m12 = self.m21
	out.m13 = self.m31

	out.m20 = self.m02
	out.m21 = self.m12
	out.m22 = self.m22
	out.m23 = self.m32

	out.m30 = self.m03
	out.m31 = self.m13
	out.m32 = self.m23
	out.m33 = self.m33

	return out
end

function META.GetMultiplied(a, b, out)
	out = out or light_ctor()

	out.m00 = a.m00 * b.m00 + a.m01 * b.m10 + a.m02 * b.m20 + a.m03 * b.m30
	out.m01 = a.m00 * b.m01 + a.m01 * b.m11 + a.m02 * b.m21 + a.m03 * b.m31
	out.m02 = a.m00 * b.m02 + a.m01 * b.m12 + a.m02 * b.m22 + a.m03 * b.m32
	out.m03 = a.m00 * b.m03 + a.m01 * b.m13 + a.m02 * b.m23 + a.m03 * b.m33

	out.m10 = a.m10 * b.m00 + a.m11 * b.m10 + a.m12 * b.m20 + a.m13 * b.m30
	out.m11 = a.m10 * b.m01 + a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31
	out.m12 = a.m10 * b.m02 + a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32
	out.m13 = a.m10 * b.m03 + a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33

	out.m20 = a.m20 * b.m00 + a.m21 * b.m10 + a.m22 * b.m20 + a.m23 * b.m30
	out.m21 = a.m20 * b.m01 + a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31
	out.m22 = a.m20 * b.m02 + a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32
	out.m23 = a.m20 * b.m03 + a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33

	out.m30 = a.m30 * b.m00 + a.m31 * b.m10 + a.m32 * b.m20 + a.m33 * b.m30
	out.m31 = a.m30 * b.m01 + a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31
	out.m32 = a.m30 * b.m02 + a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32
	out.m33 = a.m30 * b.m03 + a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33

	return out
end

META.Multiply = META.GetMultiplied

function META:GetTranslation()
	return self.m30, self.m31, self.m32
end

function META:GetClipCoordinates()
	return self.m30 / self.m33, self.m31 / self.m33, self.m32 / self.m33
end

function META:Translate(x, y, z)
	if x == 0 and y == 0 and (z == 0 or not z) then return self end

	self.m30 = self.m00 * x + self.m10 * y + self.m20 * z + self.m30
	self.m31 = self.m01 * x + self.m11 * y + self.m21 * z + self.m31
	self.m32 = self.m02 * x + self.m12 * y + self.m22 * z + self.m32
	self.m33 = self.m03 * x + self.m13 * y + self.m23 * z + self.m33

	return self
end

function META:SetTranslation(x, y, z)
	self.m30 = x
	self.m31 = y
	self.m32 = z

	return self
end

function META:Rotate(a, x, y, z, out)
	if a == 0 then return self end

	out = out or light_ctor()

	local xx, yy, zz, xy, yz, zx, xs, ys, zs, one_c, s, c
	local optimized = false

	local s = math.sin(a)
	local c = math.cos(a)

	if x == 0 then
		if y == 0 then
			if z ~= 0 then
				optimized = true
				-- rotate only around z axis

				out.m00 = c
				out.m11 = c

				if z < 0 then
					out.m10 = s
					out.m01 = -s
				else
					out.m10 = -s
					out.m01 = s
				end
			elseif z == 0 then
				optimized = true
				-- rotate only around y axis

				out.m00 = c
				out.m22 = c

				if y < 0 then
					out.m20 = -s
					out.m02 = s
				else
					out.m20 = s
					out.m02 = -s
				end
			end
		end
	elseif y == 0 then
		if z == 0 then
			optimized = true
			-- rotate only around x axis

			out.m11 = c
			out.m22 = c

			if x < 0 then
				out.m21 = s
				out.m12 = -s
			else
				out.m21 = -s
				out.m12 = s
			end
		end
	end

	if not optimized then
		local mag = math.sqrt(x * x + y * y + z * z)

		if mag <= 1.0e-4 then
			return
		end

		x = x / mag
		y = y / mag
		z = z / mag

		xx = x * x
		yy = y * y
		zz = z * z
		xy = x * y
		yz = y * z
		zx = z * x
		xs = x * s
		ys = y * s
		zs = z * s
		one_c = 1 - c

		out.m00 = (one_c * xx) + c
		out.m10 = (one_c * xy) - zs
		out.m20 = (one_c * zx) + ys

		out.m01 = (one_c * xy) + zs
		out.m11 = (one_c * yy) + c
		out.m21 = (one_c * yz) - xs

		out.m02 = (one_c * zx) - ys
		out.m12 = (one_c * yz) + xs
		out.m22 = (one_c * zz) + c

	end

	self.GetMultiplied(out, self:Copy(), self)

	return self
end

function META:Scale(x, y, z)
	if x == 1 and y == 1 and z == 1 then return self end

	self.m00 = self.m00 * x
	self.m10 = self.m10 * y
	self.m20 = self.m20 * z

	self.m01 = self.m01 * x
	self.m11 = self.m11 * y
	self.m21 = self.m21 * z

	self.m02 = self.m02 * x
	self.m12 = self.m12 * y
	self.m22 = self.m22 * z

	self.m03 = self.m03 * x
	self.m13 = self.m13 * y
	self.m23 = self.m23 * z

	return self
end

do -- projection
	function META:Perspective(fov, near, far, aspect)
		local yScale = 1.0 / math.tan(fov / 2)
		local xScale = yScale / aspect
		local nearmfar =  far - near

		self.m00 = xScale
		self.m01 = 0
		self.m02 = 0
		self.m03 = 0

		self.m10 = 0
		self.m11 = yScale
		self.m12 = 0
		self.m13 = 0

		self.m20 = 0
		self.m21 = 0
		self.m22 = (far + near) / nearmfar
		self.m23 = -1

		self.m30 = 0
		self.m31 = 0
		self.m32 = 2*far*near / nearmfar
		self.m33 = 0

		return self
	end

	function META:Frustum(l, r, b, t, n, f)
		local temp = 2.0 * n
		local temp2 = r - l
		local temp3 = t - b
		local temp4 = f - n

		self.m00 = temp / temp2
		self.m01 = 0.0
		self.m02 = 0.0
		self.m03 = 0.0
		self.m10 = 0.0
		self.m11 = temp / temp3
		self.m12 = 0.0
		self.m13 = 0.0
		self.m20 = (r + l) / temp2
		self.m21 = (t + b) / temp3
		self.m22 = (-f - n) / temp4
		self.m23 = -1.0
		self.m30 = 0.0
		self.m31 = 0.0
		self.m32 = (-temp * f) / temp4
		self.m33 = 0.0

		return self
	end

	function META:Ortho(left, right, bottom, top, near, far)
		local out = self

		out.m00 = 2 / (right - left)
		--out.m10 = 0
		--out.m20 = 0
		out.m30 = -(right + left) / (right - left)

	--	out.m01 = 0
		out.m11 = 2 / (top - bottom)
	--	out.m21 = 0
		out.m31 = -(top + bottom) / (top - bottom)

	--	out.m02 = 0
	--	out.m12 = 0
		out.m22 = -2 / (far - near)
		out.m32 = -(far + near) / (far - near)

	--	out.m03 = 0
	--	out.m13 = 0
	--	out.m23 = 0
	--	out.m33 = 1

		return self
	end
end

function META:TransformVector(x, y, z)
	local out = self

	local div = x * out.m03 + y * out.m13 + z * out.m23 + out.m33

	return
		(x * out.m00 + y * out.m10 + z * out.m20 + out.m30) / div,
		(x * out.m01 + y * out.m11 + z * out.m21 + out.m31) / div,
		(x * out.m02 + y * out.m12 + z * out.m22 + out.m32) / div
end

function META:Shear(v)
	local out = self

	 for i = 0, 3 do
		out[i + 2] = out[i + 2] + y * out[i] + v.z * out[i + 1]
		out[i + 1] = out[i + 1] + v.x * out[i]
	end
end

function META:Lerp(alpha, other)
	local out = self
	for i = 1, 16 do
		math.lerp(alpha, out[i-1], other[i-1])
	end
end

function META:GetRotation(out)
	local w = math.sqrt(1 + self.m00 + self.m11 + self.m22) / 2
	local w2 = w * 4

	x = (self.m21 - self.m12) / w2
	y = (self.m02 - self.m20 ) / w2
	z = (self.m10 - self.m01) / w2

	out = out or structs.Quat()
	out:Set(x,y,z,w)

	return out
end

function META:SetRotation(q)
	local sqw = q.w*q.w
	local sqx = q.x*q.x
	local sqy = q.y*q.y
	local sqz = q.z*q.z

	-- invs (inverse square length) is only required if quaternion is not already normalised
	local invs = 1 / (sqx + sqy + sqz + sqw)

	self.m00 = ( sqx - sqy - sqz + sqw)*invs -- since sqw + sqx + sqy + sqz =1/invs*invs
	self.m11 = (-sqx + sqy - sqz + sqw)*invs
	self.m22 = (-sqx - sqy + sqz + sqw)*invs

	local tmp1, tmp2

	tmp1 = q.x*q.y;
	tmp2 = q.z*q.w;
	self.m10 = 2.0 * (tmp1 + tmp2)*invs
	self.m01 = 2.0 * (tmp1 - tmp2)*invs

	tmp1 = q.x*q.z
	tmp2 = q.y*q.w
	self.m20 = 2.0 * (tmp1 - tmp2)*invs
	self.m02 = 2.0 * (tmp1 + tmp2)*invs

	tmp1 = q.y*q.z
	tmp2 = q.x*q.w
	self.m21 = 2.0 * (tmp1 + tmp2)*invs
	self.m12 = 2.0 * (tmp1 - tmp2)*invs

	return self
end

function META:SetAngles(ang)
	self:SetRotation(Quat():SetAngles(ang))
end

function META:GetAngles()
	return self:GetRotation():GetAngles()
end

--structs.Register(META)

ffi.cdef[[
	typedef struct Matrix44 {
		float m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33;
} Matrix44;]]

local meta = ffi.metatype("Matrix44", META)
light_ctor = function() return meta(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1) end
function Matrix44(x, y, z)
	local self = meta(1,0,0,0, 0,1,0,0, 0,0,1,0, x or 0, y or 0, z or 0,1)
	return self
end

prototype.Register(META)