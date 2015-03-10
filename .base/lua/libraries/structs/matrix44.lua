if MATRIX_CTYPE then 

	local structs = (...) or _G.structs
	local light_ctor
	--[[local META = {}

	function META:Constructor()
		self:LoadIdentity()
	end

	META.ClassName = "Matrix44"
	META.NumberType = "float"
	META.Args = {
		"m00", "m01", "m02", "m03",
		"m10", "m11", "m12", "m13",
		"m20", "m21", "m22", "m23",
		"m30", "m31", "m32", "m33",
	}

	structs.AddOperator(META, "==")
	structs.AddOperator(META, "copy")]]
	
	local META = {}
	META.__index = META

	META.Type = "matrix44"
	META.TypeX = "matrix44"

	function META.__eq(a, b)
		if getmetatable(b) == META then
			for i = 0, 15 do
				if a._[i] ~= b._[i] then
					return false
				end
			end
			
			return true
		end
		
		return false
	end

	local size = ffi.sizeof("float") * 16

	function META:Copy(matrix)
		if matrix then
			ffi.copy(self._, matrix._, 16)
			
			return self
		else
			local result = light_ctor()
			
			ffi.copy(result._, self._, size)
			
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

		local det = self.m00*out.m00 + self.m01*out.m10 + self.m02*out.m20 + self.m03*out.m30
		
		out.m00 = out.m00 / det 
		out.m01 = out.m01 / det 
		out.m02 = out.m02 / det 
		out.m03 = out.m03 / det 
		out.m10 = out.m10 / det 
		out.m11 = out.m11 / det 
		out.m12 = out.m12 / det 
		out.m13 = out.m13 / det 
		out.m20 = out.m20 / det 
		out.m21 = out.m21 / det 
		out.m22 = out.m22 / det 
		out.m23 = out.m23 / det 
		out.m30 = out.m30 / det 
		out.m31 = out.m31 / det 
		out.m32 = out.m32 / det 
		out.m33 = out.m33 / det 
		
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
		typedef union Matrix44 {
			struct { float m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33; };
			float _[16];
	} Matrix44;]]
	
	local meta = ffi.metatype("Matrix44", META)
	light_ctor = meta
	function Matrix44()
		local self = meta()
		self:Identity()		
		return self
	end
else
	local structs = (...) or _G.structs

	local META = {}
	META.__index = META

	META.Type = "matrix44"
	META.TypeX = "matrix44"

	function META.__eq(a, b)
		if getmetatable(b) == META then
			for i = 0, 15 do
				if a[i] ~= b[i] then
					return false
				end
			end
			
			return true
		end
		
		return false
	end

	local size = ffi.sizeof("float") * 16

	function META:Copy(matrix)
		if matrix then
			ffi.copy(self._, matrix._, 16)
			
			return self
		else
			local result = Matrix44()
			
			ffi.copy(result._, self._, size)
			
			return result
		end
	end

	META.__copy = META.Copy
	
	function META:__tostring()
		return string.format("matrix44[%p]:\n" .. ("%f %f %f %f\n"):rep(4), self._,
			--self[0], self[4], self[8], self[12],
			--self[1], self[5], self[9], self[13],
			--self[2], self[6], self[10], self[14],
			--self[3], self[7], self[11], self[15]
			
			self[0], self[1], self[2], self[3],
			self[4], self[5], self[6], self[7],
			self[8], self[9], self[10], self[11],
			self[12], self[13], self[14], self[15] 
		)
	end

	function META:__mul(b)
		return self:GetMultiplied(b)
	end

	function META:Identity()
		local m = self._
		
		m[0] = 1 
		m[5] = 1
		m[10] = 1
		m[15] = 1
		
		m[1] = 0
		m[2] = 0
		m[3] = 0
		m[4] = 0
		m[6] = 0
		m[7] = 0
		m[8] = 0
		m[9] = 0
		m[11] = 0
		m[12] = 0
		m[13] = 0
		m[14] = 0
		
		return self
	end

	META.LoadIdentity = META.Identity

	function META:GetInverse(out)
		out = out or Matrix44()
		local r = out._
		local m = self._

		r[0] = m[5]*m[10]*m[15] - m[5]*m[14]*m[11] - m[6]*m[9]*m[15] + m[6]*m[13]*m[11] + m[7]*m[9]*m[14] - m[7]*m[13]*m[10]
		r[1] = -m[1]*m[10]*m[15] + m[1]*m[14]*m[11] + m[2]*m[9]*m[15] - m[2]*m[13]*m[11] - m[3]*m[9]*m[14] + m[3]*m[13]*m[10]
		r[2] = m[1]*m[6]*m[15] - m[1]*m[14]*m[7] - m[2]*m[5]*m[15] + m[2]*m[13]*m[7] + m[3]*m[5]*m[14] - m[3]*m[13]*m[6]
		r[3] = -m[1]*m[6]*m[11] + m[1]*m[10]*m[7] + m[2]*m[5]*m[11] - m[2]*m[9]*m[7] - m[3]*m[5]*m[10] + m[3]*m[9]*m[6]

		r[4] = -m[4]*m[10]*m[15] + m[4]*m[14]*m[11] + m[6]*m[8]*m[15] - m[6]*m[12]*m[11] - m[7]*m[8]*m[14] + m[7]*m[12]*m[10]
		r[5] = m[0]*m[10]*m[15] - m[0]*m[14]*m[11] - m[2]*m[8]*m[15] + m[2]*m[12]*m[11] + m[3]*m[8]*m[14] - m[3]*m[12]*m[10]
		r[6] = -m[0]*m[6]*m[15] + m[0]*m[14]*m[7] + m[2]*m[4]*m[15] - m[2]*m[12]*m[7] - m[3]*m[4]*m[14] + m[3]*m[12]*m[6]
		r[7] = m[0]*m[6]*m[11] - m[0]*m[10]*m[7] - m[2]*m[4]*m[11] + m[2]*m[8]*m[7] + m[3]*m[4]*m[10] - m[3]*m[8]*m[6]

		r[8] = m[4]*m[9]*m[15] - m[4]*m[13]*m[11] - m[5]*m[8]*m[15] + m[5]*m[12]*m[11] + m[7]*m[8]*m[13] - m[7]*m[12]*m[9]
		r[9] = -m[0]*m[9]*m[15] + m[0]*m[13]*m[11] + m[1]*m[8]*m[15] - m[1]*m[12]*m[11] - m[3]*m[8]*m[13] + m[3]*m[12]*m[9]
		r[10] = m[0]*m[5]*m[15] - m[0]*m[13]*m[7] - m[1]*m[4]*m[15] + m[1]*m[12]*m[7] + m[3]*m[4]*m[13] - m[3]*m[12]*m[5]
		r[11] = -m[0]*m[5]*m[11] + m[0]*m[9]*m[7] + m[1]*m[4]*m[11] - m[1]*m[8]*m[7] - m[3]*m[4]*m[9] + m[3]*m[8]*m[5]

		r[12] = -m[4]*m[9]*m[14] + m[4]*m[13]*m[10] + m[5]*m[8]*m[14] - m[5]*m[12]*m[10] - m[6]*m[8]*m[13] + m[6]*m[12]*m[9]
		r[13] = m[0]*m[9]*m[14] - m[0]*m[13]*m[10] - m[1]*m[8]*m[14] + m[1]*m[12]*m[10] + m[2]*m[8]*m[13] - m[2]*m[12]*m[9]
		r[14] = -m[0]*m[5]*m[14] + m[0]*m[13]*m[6] + m[1]*m[4]*m[14] - m[1]*m[12]*m[6] - m[2]*m[4]*m[13] + m[2]*m[12]*m[5]
		r[15] = m[0]*m[5]*m[10] - m[0]*m[9]*m[6] - m[1]*m[4]*m[10] + m[1]*m[8]*m[6] + m[2]*m[4]*m[9] - m[2]*m[8]*m[5]

		local det = m[0]*r[0] + m[1]*r[4] + m[2]*r[8] + m[3]*r[12]
		
		
		r[0] = r[0] / det 
		r[1] = r[1] / det 
		r[2] = r[2] / det 
		r[3] = r[3] / det 
		r[4] = r[4] / det 
		r[5] = r[5] / det 
		r[6] = r[6] / det 
		r[7] = r[7] / det 
		r[8] = r[8] / det 
		r[9] = r[9] / det 
		r[10] = r[10] / det 
		r[11] = r[11] / det 
		r[12] = r[12] / det 
		r[13] = r[13] / det 
		r[14] = r[14] / det 
		r[15] = r[15] / det 
		
		
		return out
	end

	function META:GetTranspose(out)
		out = out or Matrix44()
		local r = out._
		local m = self._
		
		r[0] = m[0] 
		r[1] = m[4] 
		r[2] = m[8] 
		r[3] = m[12]
		
		r[4] = m[1] 
		r[5] = m[5] 
		r[6] = m[9] 
		r[7] = m[13]
		
		r[8] = m[2] 
		r[9] = m[6] 
		r[10] = m[10] 
		r[11] = m[14]
		
		r[12] = m[3]
		r[13] = m[7] 
		r[14] = m[11] 
		r[15] = m[15]
		
		return out
	end

	function META.GetMultiplied(a, b, out)
		out = out or Matrix44()
		local r = out._
			
		local a = a._
		local b = b._

		r[0] = a[0] * b[0] + a[1] * b[4] + a[2] * b[8] + a[3] * b[12]
		r[1] = a[0] * b[1] + a[1] * b[5] + a[2] * b[9] + a[3] * b[13]
		r[2] = a[0] * b[2] + a[1] * b[6] + a[2] * b[10] + a[3] * b[14]
		r[3] = a[0] * b[3] + a[1] * b[7] + a[2] * b[11] + a[3] * b[15]

		r[4] = a[4] * b[0] + a[5] * b[4] + a[6] * b[8] + a[7] * b[12]
		r[5] = a[4] * b[1] + a[5] * b[5] + a[6] * b[9] + a[7] * b[13]
		r[6] = a[4] * b[2] + a[5] * b[6] + a[6] * b[10] + a[7] * b[14]
		r[7] = a[4] * b[3] + a[5] * b[7] + a[6] * b[11] + a[7] * b[15]

		r[8] = a[8] * b[0] + a[9] * b[4] + a[10] * b[8] + a[11] * b[12]
		r[9] = a[8] * b[1] + a[9] * b[5] + a[10] * b[9] + a[11] * b[13]
		r[10] = a[8] * b[2] + a[9] * b[6] + a[10] * b[10] + a[11] * b[14]
		r[11] = a[8] * b[3] + a[9] * b[7] + a[10] * b[11] + a[11] * b[15]

		r[12] = a[12] * b[0] + a[13] * b[4] + a[14] * b[8] + a[15] * b[12]
		r[13] = a[12] * b[1] + a[13] * b[5] + a[14] * b[9] + a[15] * b[13]
		r[14] = a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14]
		r[15] = a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15]
		
		return out
	end

	META.Multiply = META.GetMultiplied

	function META:GetTranslation()
		local m = self._
		
		return m[12], m[13], m[14]
	end

	function META:GetClipCoordinates()
		local m = self._
		
		return m[12] / m[15], m[13] / m[15], m[14] / m[15]
	end

	function META:Translate(x, y, z)
		if x == 0 and y == 0 and (z == 0 or not z) then return self end

		local m = self._

		m[12] = m[0] * x + m[4] * y + m[8]  * z + m[12]
		m[13] = m[1] * x + m[5] * y + m[9]  * z + m[13]
		m[14] = m[2] * x + m[6] * y + m[10] * z + m[14]
		m[15] = m[3] * x + m[7] * y + m[11] * z + m[15]

		return self
	end

	function META:SetTranslation(x, y, z)
		local m = self._
		
		m[12] = x
		m[13] = y
		m[14] = z
		
		return self
	end

	function META:Rotate(a, x, y, z, out)
		if a == 0 then return self end
		
		out = out or Matrix44()
		local m = out._

		local xx, yy, zz, xy, yz, zx, xs, ys, zs, one_c, s, c
		local optimized = false

		local s = math.sin(a)
		local c = math.cos(a)

		if x == 0 then
			if y == 0 then
				if z ~= 0 then
					optimized = true
					-- rotate only around z axis
					
					m[0*4+0] = c
					m[1*4+1] = c

					if z < 0 then
						m[1*4+0] = s
						m[0*4+1] = -s
					else
						m[1*4+0] = -s
						m[0*4+1] = s
					end
				elseif z == 0 then
					optimized = true
					-- rotate only around y axis
					
					m[0*4+0] = c
					m[2*4+2] = c

					if y < 0 then
						m[2*4+0] = -s
						m[0*4+2] = s
					else
						m[2*4+0] = s
						m[0*4+2] = -s
					end
				end
			end
		elseif y == 0 then
			if z == 0 then
				optimized = true
				-- rotate only around x axis
				
				m[1*4+1] = c
				m[2*4+2] = c

				if x < 0 then
					m[2*4+1] = s
					m[1*4+2] = -s
				else
					m[2*4+1] = -s
					m[1*4+2] = s
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

			m[0*4+0] = (one_c * xx) + c
			m[1*4+0] = (one_c * xy) - zs
			m[2*4+0] = (one_c * zx) + ys

			m[0*4+1] = (one_c * xy) + zs
			m[1*4+1] = (one_c * yy) + c
			m[2*4+1] = (one_c * yz) - xs

			m[0*4+2] = (one_c * zx) - ys
			m[1*4+2] = (one_c * yz) + xs
			m[2*4+2] = (one_c * zz) + c

		end
		
		self.GetMultiplied(out, self:Copy(), self)
		
		return self
	end

	function META:Scale(x, y, z)
		if x == 1 and y == 1 and z == 1 then return self end
		
		local m = self._

		m[0] = m[0] * x 
		m[4] = m[4] * y
		m[8] = m[8] * z
		
		m[1] = m[1] * x
		m[5] = m[5] * y
		m[9] = m[9] * z
		
		m[2] = m[2] * x
		m[6] = m[6] * y
		m[10] = m[10] * z
		
		m[3] = m[3] * x
		m[7] = m[7] * y
		m[11] = m[11] * z

		return self
	end

	do -- projection
		function META:Perspective(fov, near, far, aspect)
			local m = self._

			local yScale = 1.0 / math.tan(fov / 2)
			local xScale = yScale / aspect
			local nearmfar =  far - near
			
			m[0] = xScale
			m[1] = 0 
			m[2] = 0 
			m[3] = 0 
			
			m[4] = 0
			m[5] = yScale
			m[6] = 0 
			m[7] = 0 
			
			m[8] = 0 
			m[9] = 0
			m[10] = (far + near) / nearmfar
			m[11] = -1 

			m[12] = 0 
			m[13] = 0
			m[14] = 2*far*near / nearmfar
			m[15] = 0
			
			return self
		end

		function META:Frustum(l, r, b, t, n, f)
			local m = self._
				
			local temp = 2.0 * n
			local temp2 = r - l
			local temp3 = t - b
			local temp4 = f - n
			
			m[0] = temp / temp2
			m[1] = 0.0
			m[2] = 0.0
			m[3] = 0.0
			m[4] = 0.0
			m[5] = temp / temp3
			m[6] = 0.0
			m[7] = 0.0
			m[8] = (r + l) / temp2
			m[9] = (t + b) / temp3
			m[10] = (-f - n) / temp4
			m[11] = -1.0
			m[12] = 0.0
			m[13] = 0.0
			m[14] = (-temp * f) / temp4
			m[15] = 0.0
			
			return self
		end

		function META:Ortho(left, right, bottom, top, near, far)
			local m = self._
			
			m[0*4] = 2 / (right - left)
			--m[1*4] = 0
			--m[2*4] = 0
			m[3*4] = -(right + left) / (right - left)

		--	m[0*4+1] = 0
			m[1*4+1] = 2 / (top - bottom)
		--	m[2*4+1] = 0
			m[3*4+1] = -(top + bottom) / (top - bottom)

		--	m[0*4+2] = 0
		--	m[1*4+2] = 0
			m[2*4+2] = -2 / (far - near)
			m[3*4+2] = -(far + near) / (far - near)

		--	m[0*4+3] = 0
		--	m[1*4+3] = 0
		--	m[2*4+3] = 0
		--	m[3*4+3] = 1
						
			return self
		end
	end

	if CLIENT then -- helpers
		function META:LookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz)
			local m = self._

			local e = Vec3(ex, ey, ez)
			local c = Vec3(cx, cy, cz)
			local u = Vec3(ux, uy, uz)
			local f = (e - c):GetNormalized()
			local s = u:Cross(f):GetNormalized()
			local t = f:Cross(s):GetNormalized()

			m[0] = s.x
			m[1] = s.y
			m[2] = s.z
			m[3] = -s:GetDot(e)

			m[4] = t.x
			m[5] = t.y
			m[6] = t.z
			m[7] = -t:GetDot(e)

			m[8] = f.x
			m[9] = f.y
			m[10] = f.z
			m[11] = -f:GetDot(e)

			m[12] = 0
			m[13] = 0
			m[14] = 0
			m[15] = 1

			return self
		end
	end

	function META:TransformPoint(v)
		local m = self._
		
		return Vec3(
			m[0] * v.x + m[1] * v.y + m[2] * v.z + m[3],
			m[4] * v.x + m[5] * v.y + m[6] * v.z + m[7],
			m[8] * v.x + m[9] * v.y + m[10] * v.z + m[11]
		) / 
		(m[12] * v.x + m[13] * v.y + m[14] * v.z + m[15])
	end

	function META:TransformVector(v)
		local m = self._
		local x, y, z = v.x - m[12], v.y - m[13], v.z - m[14]
		return Vec3(
			(m[0] * x + m[1] * y + m[2] * z),
			(m[4] * x + m[5] * y + m[6] * z),
			(m[8] * x + m[9] * y + m[10] * z)
		)
	end

	function META:TransformVector(x, y, z)
		local m = self._
		
		local div = x * m[3] + y * m[7] + z * m[11] + m[15]
			
		return
			(x * m[0] + y * m[4] + z * m[8] + m[12]) / div,
			(x * m[1] + y * m[5] + z * m[9] + m[13]) / div,
			(x * m[2] + y * m[6] + z * m[10] + m[14]) / div
	end

	function META:Shear(v)
		local m = self._
		
		 for i = 0, 3 do
			m[i + 2] = m[i + 2] + y * m[i] + v.z * m[i + 1]
			m[i + 1] = m[i + 1] + v.x * m[i]
		end
	end

	function META:Lerp(alpha, other)
		local m = self._
		for i = 1, 16 do
			math.lerp(alpha, m[i-1], other._[i-1])
		end
	end

	function META:GetRotation(out)
		local m = self._
		
		local w = math.sqrt(1 + m[0] + m[5] + m[10]) / 2
		local w2 = w * 4
		
		x = (m[9] - m[6]) / w2
		y = (m[2] - m[8]) / w2
		z = (m[4] - m[1]) / w2
		
		out = out or structs.Quat()
		out:Set(x,y,z,w)
		
		return out
	end

	function META:SetRotation(q)
		local m = self._

		local sqw = q.w*q.w
		local sqx = q.x*q.x
		local sqy = q.y*q.y
		local sqz = q.z*q.z

		-- invs (inverse square length) is only required if quaternion is not already normalised
		local invs = 1 / (sqx + sqy + sqz + sqw)
		
		m[0] = ( sqx - sqy - sqz + sqw)*invs -- since sqw + sqx + sqy + sqz =1/invs*invs
		m[5] = (-sqx + sqy - sqz + sqw)*invs
		m[10] = (-sqx - sqy + sqz + sqw)*invs

		local tmp1, tmp2
		
		tmp1 = q.x*q.y;
		tmp2 = q.z*q.w;
		m[4] = 2.0 * (tmp1 + tmp2)*invs
		m[1] = 2.0 * (tmp1 - tmp2)*invs

		tmp1 = q.x*q.z
		tmp2 = q.y*q.w
		m[8] = 2.0 * (tmp1 - tmp2)*invs
		m[2] = 2.0 * (tmp1 + tmp2)*invs
		
		tmp1 = q.y*q.z
		tmp2 = q.x*q.w
		m[9] = 2.0 * (tmp1 + tmp2)*invs
		m[6] = 2.0 * (tmp1 - tmp2)*invs
		
		return self
	end

	function META:SetAngles(ang)
		self:SetRotation(Quat():SetAngles(ang))
	end

	function META:GetAngles()
		return self:GetRotation():GetAngles()
	end

	local t = ffi.typeof("float[16]")
	local new = ffi.new

	function Matrix44()
		local self = setmetatable({}, META)
		
		self._ = new(t)
		self:Identity()
	
		return self
	end

	prototype.Register(META)
end