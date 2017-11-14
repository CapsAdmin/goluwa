local structs = (...) or _G.structs

local function matrix_template(X, Y, identity)

	local function generate_generic(cb, no_newline)
		local str = ""
		local i = 0

		for x = 0, X-1 do
			for y = 0, Y-1 do
				str = str .. cb(x, y, i)
				i = i + 1
			end
			if not no_newline then
				str = str .. "\n"
			end
		end

		return str
	end

	local code = [==[
local structs = ...
local META = prototype.CreateTemplate("matrix]==] .. X .. Y .. [==[")
META.__index = META

META.NumberType = "double"

META.Args = {
	]==] .. generate_generic(function(x, y) return "\"m" .. x .. y .. "\", " end) .. [==[
}

function META:GetI(i)
	return self[META.Args[i+1]]
end

function META:SetI(i, val)
	self[META.Args[i+1]] = val

	return self
end

do
	local tr = {}

	for x = 0, ]==]..X..[==[-1 do
		tr[x] = tr[x] or {}
		for y = 0, ]==]..Y..[==[-1 do
			tr[x][y] = "m" .. y .. x
		end
	end

	function META:GetField(r, c)
		return self[tr[r][c]]
	end

	function META:SetField(r, c, v)
		self[tr[r][c]] = v
		return self
	end
end

function META:SetColumn(i, ]==] .. (function() local str = {} for i = 1, Y do str[i] = "_" .. i end return table.concat(str, ", ") end)() .. [==[)
	]==]..(function()
		local str = ""

		for i = 0, Y - 1 do
			str = str .. "self:SetField(" .. i .. ", i, _" .. i+1 ..")\n"
		end

		return str
	end)()..[==[

	return self
end

function META:GetColumn(i)
	return
	]==]..(function()
		local str = {}

		for i = 0, Y - 1 do
			str[i] = "self:GetField(" .. i .. ", i)"
		end

		return table.concat(str, ",\n")
	end)()..[==[
end

function META:GetRow(i)
	return
	]==]..(function()
		local str = {}

		for i = 0, X - 1 do
			str[i] = "self:GetField(i, " .. i .. ")"
		end

		return table.concat(str, ",\n")
	end)()..[==[
end

function META:SetRow(i, ]==] .. (function() local str = {} for i = 1, X do str[i] = "_" .. i end return table.concat(str, ", ") end)() .. [==[)
	]==]..(function()
		local str = ""

		for i = 0, X - 1 do
			str = str .. "self:SetField(i, " .. i .. ", _" .. i+1 ..")\n"
		end

		return str
	end)()..[==[

	return self
end

function META.Identity(m)
	]==]..(function()
		local str = ""

		local i = 1

		for x = 0, X - 1 do
			for y = 0, Y - 1 do
				str = str .. "m.m" .. x .. y .. " = " .. identity[i] .. " "
				i = i + 1
			end
			str = str .. "\n"
		end

		return str
	end)()..[==[
	return m
end

META.LoadIdentity = META.Identity

structs.AddOperator(META, "==")

local _, ffi = pcall(require, "ffi")

if ffi then
	META.Constructor = ffi.typeof("struct { $ ]==] .. generate_generic(function(x, y) return "m" .. x .. y .. ", " end, true):sub(0, -3)  .. [==[; }", ffi.typeof(META.NumberType))

	local ctype = ffi.typeof("float[]==]..X*Y..[==[]")
	local o = ctype()

	function META.GetFloatPointer(m)
		]==] .. generate_generic(function(x, y, i) return "o[" .. i .. "] = m.m" .. x .. y .. " " end) .. [==[
		return o
	end

	function META.GetFloatCopy(m)
		return ctype(
			]==] .. generate_generic(function(x, y) return "m.m" .. x .. y .. ", " end):sub(0, -4)  .. [==[
		)
	end
else
	local setmetatable = setmetatable
	function META.Constructor(
			]==] .. generate_generic(function(x, y) return "m" .. x .. y .. ", " end):sub(0, -4)  .. [==[
		)

		return setmetatable({
			]==] .. generate_generic(function(x, y) return "m" .. x .. y .. " = m" .. x .. y .. ", " end)  .. [==[
		}, META)
	end

end
	function META.Unpack(m)
		return
			]==] .. generate_generic(function(x, y) return "m.m" .. x .. y .. ", " end):sub(0, -4)  .. [==[
	end

function META.CopyTo(a, b)
	]==] .. generate_generic(function(x, y) return "b.m" .. x .. y .. " = a.m" .. x .. y .. " " end)  .. [==[
	return a
end

function META.Copy(m)
	return META.Constructor(
		]==] .. generate_generic(function(x, y) return "m.m" .. x .. y .. ", " end):sub(0, -4)  .. [==[
	)
end

META.__copy = META.Copy

function META.__tostring(m)
	return string.format("matrix]==]..X..Y..[==[[%p]:\n" .. (("%f "):rep(]==]..X..[==[) .. "\n"):rep(]==]..Y..[==[), m,
		]==] .. generate_generic(function(x, y) return "m.m" .. x .. y .. ", " end):sub(0, -4)  .. [==[
	)
end

function META:Lerp(alpha, other)
	for i = 0, ]==] .. (X*Y)-1 .. [==[ do
		self:SetI(i, math.lerp(alpha, self:GetI(i), other:GetI(i)))
	end
end

function META.GetMultiplied(a, b, o)
	o = o or META.Constructor(]==] .. table.concat(identity, ", ") .. [==[)

	]==] .. (function()
	local str = ""

	for x = 0, X-1 do
		for y = 0, Y-1 do
			str = str .. "o.m" .. x .. y .. " = b.m" .. x .. "0 * a.m0" .. y
			for n = 1, Y-1 do
				str = str .. " + b.m" .. x .. n .. " * a.m" .. n .. y
			end
			str = str .. "\n"
		end
	end

	return str
end)() .. [==[

	return o
end

function META:__mul(b)
	return self:GetMultiplied(b)
end

function META:Multiply(b, out)
	return self:GetMultiplied(b, out or self)
end

function META.GetTransposed(m, o)
	o = o or META.Constructor(]==] .. table.concat(identity, ", ") .. [==[)

	]==] .. (function()
			local str = ""

			for x = 0, X-1 do
				for y = 0, Y-1 do
					str = str .. "o.m" .. x .. y .. " = m.m" .. y .. x .. " "

				end
				str = str .. "\n"
			end

			return str
		end)()
 .. [==[

	return o
end

local old = META.Register

function META:Register()
	if ffi then
		ffi.metatype(META.Constructor, META)
	end

	function _G.Matrix]==]..X..Y..[==[(x, y, z)
		if x or y or z then error() end
		return META.Constructor(]==] .. table.concat(identity, ", ") .. [==[)
	end

	old(META)
end

return META
	]==]

	return assert(loadstring(code, "matrix_" .. X .. Y))(structs)
end

for X = 2, 4 do
	for Y = 2, 4 do
		if not (X == 4 and Y == 4) then
			local identity = {}
			local i = 1
			for x = 1, X do
				for y = 1, Y do
					identity[i] = i%(Y+1)-1 == 0 and 1 or 0
					i = i + 1
				end
			end
			matrix_template(X,Y, identity):Register()
		end
	end
end

local META = matrix_template(4,4, {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1})

function META.GetInverse(m, o)
	o = o or META.Constructor(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

	o.m00 =  m.m11 * m.m22 * m.m33 - m.m11 * m.m32 * m.m23 - m.m12 * m.m21 * m.m33 + m.m12 * m.m31 * m.m23 + m.m13 * m.m21 * m.m32 - m.m13 * m.m31 * m.m22
	o.m01 = -m.m01 * m.m22 * m.m33 + m.m01 * m.m32 * m.m23 + m.m02 * m.m21 * m.m33 - m.m02 * m.m31 * m.m23 - m.m03 * m.m21 * m.m32 + m.m03 * m.m31 * m.m22
	o.m02 =  m.m01 * m.m12 * m.m33 - m.m01 * m.m32 * m.m13 - m.m02 * m.m11 * m.m33 + m.m02 * m.m31 * m.m13 + m.m03 * m.m11 * m.m32 - m.m03 * m.m31 * m.m12
	o.m03 = -m.m01 * m.m12 * m.m23 + m.m01 * m.m22 * m.m13 + m.m02 * m.m11 * m.m23 - m.m02 * m.m21 * m.m13 - m.m03 * m.m11 * m.m22 + m.m03 * m.m21 * m.m12

	o.m10 = -m.m10 * m.m22 * m.m33 + m.m10 * m.m32 * m.m23 + m.m12 * m.m20 * m.m33 - m.m12 * m.m30 * m.m23 - m.m13 * m.m20 * m.m32 + m.m13 * m.m30 * m.m22
	o.m11 =  m.m00 * m.m22 * m.m33 - m.m00 * m.m32 * m.m23 - m.m02 * m.m20 * m.m33 + m.m02 * m.m30 * m.m23 + m.m03 * m.m20 * m.m32 - m.m03 * m.m30 * m.m22
	o.m12 = -m.m00 * m.m12 * m.m33 + m.m00 * m.m32 * m.m13 + m.m02 * m.m10 * m.m33 - m.m02 * m.m30 * m.m13 - m.m03 * m.m10 * m.m32 + m.m03 * m.m30 * m.m12
	o.m13 =  m.m00 * m.m12 * m.m23 - m.m00 * m.m22 * m.m13 - m.m02 * m.m10 * m.m23 + m.m02 * m.m20 * m.m13 + m.m03 * m.m10 * m.m22 - m.m03 * m.m20 * m.m12

	o.m20 =  m.m10 * m.m21 * m.m33 - m.m10 * m.m31 * m.m23 - m.m11 * m.m20 * m.m33 + m.m11 * m.m30 * m.m23 + m.m13 * m.m20 * m.m31 - m.m13 * m.m30 * m.m21
	o.m21 = -m.m00 * m.m21 * m.m33 + m.m00 * m.m31 * m.m23 + m.m01 * m.m20 * m.m33 - m.m01 * m.m30 * m.m23 - m.m03 * m.m20 * m.m31 + m.m03 * m.m30 * m.m21
	o.m22 =  m.m00 * m.m11 * m.m33 - m.m00 * m.m31 * m.m13 - m.m01 * m.m10 * m.m33 + m.m01 * m.m30 * m.m13 + m.m03 * m.m10 * m.m31 - m.m03 * m.m30 * m.m11
	o.m23 = -m.m00 * m.m11 * m.m23 + m.m00 * m.m21 * m.m13 + m.m01 * m.m10 * m.m23 - m.m01 * m.m20 * m.m13 - m.m03 * m.m10 * m.m21 + m.m03 * m.m20 * m.m11

	o.m30 = -m.m10 * m.m21 * m.m32 + m.m10 * m.m31 * m.m22 + m.m11 * m.m20 * m.m32 - m.m11 * m.m30 * m.m22 - m.m12 * m.m20 * m.m31 + m.m12 * m.m30 * m.m21
	o.m31 =  m.m00 * m.m21 * m.m32 - m.m00 * m.m31 * m.m22 - m.m01 * m.m20 * m.m32 + m.m01 * m.m30 * m.m22 + m.m02 * m.m20 * m.m31 - m.m02 * m.m30 * m.m21
	o.m32 = -m.m00 * m.m11 * m.m32 + m.m00 * m.m31 * m.m12 + m.m01 * m.m10 * m.m32 - m.m01 * m.m30 * m.m12 - m.m02 * m.m10 * m.m31 + m.m02 * m.m30 * m.m11
	o.m33 =  m.m00 * m.m11 * m.m22 - m.m00 * m.m21 * m.m12 - m.m01 * m.m10 * m.m22 + m.m01 * m.m20 * m.m12 + m.m02 * m.m10 * m.m21 - m.m02 * m.m20 * m.m11

	local det = 1 / (m.m00 * o.m00 + m.m01 * o.m10 + m.m02 * o.m20 + m.m03 * o.m30)

	o.m00 = o.m00 * det o.m01 = o.m01 * det o.m02 = o.m02 * det o.m03 = o.m03 * det
	o.m10 = o.m10 * det o.m11 = o.m11 * det o.m12 = o.m12 * det o.m13 = o.m13 * det
	o.m20 = o.m20 * det o.m21 = o.m21 * det o.m22 = o.m22 * det o.m23 = o.m23 * det
	o.m30 = o.m30 * det o.m31 = o.m31 * det o.m32 = o.m32 * det o.m33 = o.m33 * det

	return o
end

function META:MultiplyVector(x,y,z,w, out)
	out = out or META.Constructor(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

	out.m00 = self.m00 * x + self.m10 * y + self.m20 * z + self.m30 * w
	out.m01 = self.m01 * x + self.m11 * y + self.m21 * z + self.m31 * w
	out.m02 = self.m02 * x + self.m12 * y + self.m22 * z + self.m32 * w
	out.m03 = self.m03 * x + self.m13 * y + self.m23 * z + self.m33 * w

	return out
end

function META:Skew(x, y)
	y = y or x
	x = math.rad(x)
	y = math.rad(y)

	local skew = META.Constructor(1,math.tan(x),0,0, math.tan(y),1,0,0, 0,0,1,0, 0,0,0,1)

	self:CopyTo(skew)

	return self
end

function META:GetTranslation()
	return self.m30, self.m31, self.m32
end

function META:GetClipCoordinates()
	return self.m30 / self.m33, self.m31 / self.m33, self.m32 / self.m33
end

function META:Translate(x, y, z)
	if x == 0 and y == 0 and z == 0 then return self end

	self.m30 = self.m00 * x + self.m10 * y + self.m20 * z + self.m30
	self.m31 = self.m01 * x + self.m11 * y + self.m21 * z + self.m31
	self.m32 = self.m02 * x + self.m12 * y + self.m22 * z + self.m32
	self.m33 = self.m03 * x + self.m13 * y + self.m23 * z + self.m33

	return self
end

function META:SetShear(x, y, z)
	self.m01 = x
	self.m10 = y
	-- z?
end

function META:SetTranslation(x, y, z)
	self.m30 = x
	self.m31 = y
	self.m32 = z

	return self
end

do
	local sin = math.sin
	local cos = math.cos
	local sqrt = math.sqrt

	function META:Rotate(a, x, y, z, out)
		if a == 0 then return self end

		out = out or META.Constructor(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

		local s = sin(a)
		local c = cos(a)

		if x == 0 and y == 0 then
			if z == 0 then
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
			else
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
			end
		elseif y == 0 and z == 0 then
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
		else
			local mag = sqrt(x * x + y * y + z * z)

			if mag <= 1.0e-4 then
				return self
			end

			x = x / mag
			y = y / mag
			z = z / mag

			out.m00 = (1 - c * x*x) + c
			out.m10 = (1 - c * x*y) - z * s
			out.m20 = (1 - c * z*x) + y * s

			out.m01 = (1 - c * x*y) + z * s
			out.m11 = (1 - c * y*y) + c
			out.m21 = (1 - c * y*z) - x * s

			out.m02 = (1 - c * z*x) - y * s
			out.m12 = (1 - c * y*z) + x * s
			out.m22 = (1 - c * z*z) + c

		end

		self.GetMultiplied(self:Copy(), out, self)

		return self
	end
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
	local tan = math.tan

	function META:Perspective(fov, near, far, aspect)
		local yScale = 1.0 / tan(fov / 2)
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
		self.m00 = 2 / (right - left)
		--self.m10 = 0
		--self.m20 = 0
		self.m30 = -(right + left) / (right - left)

	--	self.m01 = 0
		self.m11 = 2 / (top - bottom)
	--	self.m21 = 0
		self.m31 = -(top + bottom) / (top - bottom)

	--	self.m02 = 0
	--	self.m12 = 0
		self.m22 = -2 / (far - near)
		self.m32 = -(far + near) / (far - near)

	--	self.m03 = 0
	--	self.m13 = 0
	--	self.m23 = 0
	--	self.m33 = 1

		return self
	end
end

function META:TransformVector(x, y, z)
	local div = x * self.m03 + y * self.m13 + z * self.m23 + self.m33

	return
		(x * self.m00 + y * self.m10 + z * self.m20 + self.m30) / div,
		(x * self.m01 + y * self.m11 + z * self.m21 + self.m31) / div,
		(x * self.m02 + y * self.m12 + z * self.m22 + self.m32) / div
end

function META:TransformPoint(x, y, z)
	return
		self.m00 * x + self.m01 * y + self.m02 * z + self.m03,
		self.m10 * x + self.m11 * y + self.m12 * z + self.m13,
		self.m20 * x + self.m21 * y + self.m22 * z + self.m23
end

function META:GetRotation(out)
	local w = math.sqrt(1 + self.m00 + self.m11 + self.m22) / 2
	local w2 = w * 4

	local x = (self.m21 - self.m12) / w2
	local y = (self.m02 - self.m20 ) / w2
	local z = (self.m10 - self.m01) / w2

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

META:Register()