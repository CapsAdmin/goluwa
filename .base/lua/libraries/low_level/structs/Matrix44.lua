local META = {}

META.Type = "matrix44"
META.TypeX = "matrix44"

function META:__index(key)
	return META[key] or self.m[key]
end

function META:__tostring()
	return string.format("matrix44[%p]:\n" .. ("%f %f %f %f\n"):rep(4), self.m,
		self[0], self[4], self[8], self[12],
		self[1], self[5], self[9], self[13],
		self[2], self[6], self[10], self[14],
		self[3], self[7], self[11], self[15])
end

function META:__mul(b)
	return self:GetMultiplied(b)
end

function META:Copy(m)
	if m then
		for i = 0, 16-1 do
			self.m[i] = m.m[i]
		end
		return self
	else
		local result = Matrix44()
		
		for i = 0, 16-1 do
			result.m[i] = self.m[i]
		end
		
		return result
	end
end

function META:Identity()
	local m = self.m;
	
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
	local r = out.m
	local m = self.m

	r[0] = m[5]*m[10]*m[15] - m[5]*m[14]*m[11] - m[6]*m[9]*m[15] + m[6]*m[13]*m[11] + m[7]*m[9]*m[14] - m[7]*m[13]*m[10];
	r[1] = -m[1]*m[10]*m[15] + m[1]*m[14]*m[11] + m[2]*m[9]*m[15] - m[2]*m[13]*m[11] - m[3]*m[9]*m[14] + m[3]*m[13]*m[10];
	r[2] = m[1]*m[6]*m[15] - m[1]*m[14]*m[7] - m[2]*m[5]*m[15] + m[2]*m[13]*m[7] + m[3]*m[5]*m[14] - m[3]*m[13]*m[6];
	r[3] = -m[1]*m[6]*m[11] + m[1]*m[10]*m[7] + m[2]*m[5]*m[11] - m[2]*m[9]*m[7] - m[3]*m[5]*m[10] + m[3]*m[9]*m[6];

	r[4] = -m[4]*m[10]*m[15] + m[4]*m[14]*m[11] + m[6]*m[8]*m[15] - m[6]*m[12]*m[11] - m[7]*m[8]*m[14] + m[7]*m[12]*m[10];
	r[5] = m[0]*m[10]*m[15] - m[0]*m[14]*m[11] - m[2]*m[8]*m[15] + m[2]*m[12]*m[11] + m[3]*m[8]*m[14] - m[3]*m[12]*m[10];
	r[6] = -m[0]*m[6]*m[15] + m[0]*m[14]*m[7] + m[2]*m[4]*m[15] - m[2]*m[12]*m[7] - m[3]*m[4]*m[14] + m[3]*m[12]*m[6];
	r[7] = m[0]*m[6]*m[11] - m[0]*m[10]*m[7] - m[2]*m[4]*m[11] + m[2]*m[8]*m[7] + m[3]*m[4]*m[10] - m[3]*m[8]*m[6];

	r[8] = m[4]*m[9]*m[15] - m[4]*m[13]*m[11] - m[5]*m[8]*m[15] + m[5]*m[12]*m[11] + m[7]*m[8]*m[13] - m[7]*m[12]*m[9];
	r[9] = -m[0]*m[9]*m[15] + m[0]*m[13]*m[11] + m[1]*m[8]*m[15] - m[1]*m[12]*m[11] - m[3]*m[8]*m[13] + m[3]*m[12]*m[9];
	r[10] = m[0]*m[5]*m[15] - m[0]*m[13]*m[7] - m[1]*m[4]*m[15] + m[1]*m[12]*m[7] + m[3]*m[4]*m[13] - m[3]*m[12]*m[5];
	r[11] = -m[0]*m[5]*m[11] + m[0]*m[9]*m[7] + m[1]*m[4]*m[11] - m[1]*m[8]*m[7] - m[3]*m[4]*m[9] + m[3]*m[8]*m[5];

	r[12] = -m[4]*m[9]*m[14] + m[4]*m[13]*m[10] + m[5]*m[8]*m[14] - m[5]*m[12]*m[10] - m[6]*m[8]*m[13] + m[6]*m[12]*m[9];
	r[13] = m[0]*m[9]*m[14] - m[0]*m[13]*m[10] - m[1]*m[8]*m[14] + m[1]*m[12]*m[10] + m[2]*m[8]*m[13] - m[2]*m[12]*m[9];
	r[14] = -m[0]*m[5]*m[14] + m[0]*m[13]*m[6] + m[1]*m[4]*m[14] - m[1]*m[12]*m[6] - m[2]*m[4]*m[13] + m[2]*m[12]*m[5];
	r[15] = m[0]*m[5]*m[10] - m[0]*m[9]*m[6] - m[1]*m[4]*m[10] + m[1]*m[8]*m[6] + m[2]*m[4]*m[9] - m[2]*m[8]*m[5];

	local det = m[0]*r[0] + m[1]*r[4] + m[2]*r[8] + m[3]*r[12];
	
	for i = 0, 15 do 
		r[i] = r[i] / det 
	end
	
	return out
end

function META:GetTranspose(out)
	out = out or Matrix44()
	local r = out.m
	local m = self.m
	
	r[0] = m[0]; 
	r[1] = m[4]; 
	r[2] = m[8]; 
	r[3] = m[12];
	
	r[4] = m[1]; 
	r[5] = m[5]; 
	r[6] = m[9]; 
	r[7] = m[13];
	
	r[8] = m[2]; 
	r[9] = m[6]; 
	r[10] = m[10]; 
	r[11] = m[14];
	
	r[12] = m[3];
	r[13] = m[7]; 
	r[14] = m[11]; 
	r[15] = m[15];
	
	return out
end

function META.GetMultiplied(a, b, out)
	out = out or Matrix44()
	local r = out.m;
	
	local a = a.m
	local b = b.m

	r[0] = a[0] * b[0] + a[1] * b[4] + a[2] * b[8] + a[3] * b[12];
	r[1] = a[0] * b[1] + a[1] * b[5] + a[2] * b[9] + a[3] * b[13];
	r[2] = a[0] * b[2] + a[1] * b[6] + a[2] * b[10] + a[3] * b[14];
	r[3] = a[0] * b[3] + a[1] * b[7] + a[2] * b[11] + a[3] * b[15];

	r[4] = a[4] * b[0] + a[5] * b[4] + a[6] * b[8] + a[7] * b[12];
	r[5] = a[4] * b[1] + a[5] * b[5] + a[6] * b[9] + a[7] * b[13];
	r[6] = a[4] * b[2] + a[5] * b[6] + a[6] * b[10] + a[7] * b[14];
	r[7] = a[4] * b[3] + a[5] * b[7] + a[6] * b[11] + a[7] * b[15];

	r[8] = a[8] * b[0] + a[9] * b[4] + a[10] * b[8] + a[11] * b[12];
	r[9] = a[8] * b[1] + a[9] * b[5] + a[10] * b[9] + a[11] * b[13];
	r[10] = a[8] * b[2] + a[9] * b[6] + a[10] * b[10] + a[11] * b[14];
	r[11] = a[8] * b[3] + a[9] * b[7] + a[10] * b[11] + a[11] * b[15];

	r[12] = a[12] * b[0] + a[13] * b[4] + a[14] * b[8] + a[15] * b[12];
	r[13] = a[12] * b[1] + a[13] * b[5] + a[14] * b[9] + a[15] * b[13];
	r[14] = a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14];
	r[15] = a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15];
	
	return out
end

META.Multiply = META.GetMultiplied

function META:Translate(x, y, z)
	if x == 0 and y == 0 and (z == 0 or not z) then return result end

	local m = self.m;

	m[12] = m[0] * x + m[4] * y + m[8]  * z + m[12];
	m[13] = m[1] * x + m[5] * y + m[9]  * z + m[13];
	m[14] = m[2] * x + m[6] * y + m[10] * z + m[14];
	m[15] = m[3] * x + m[7] * y + m[11] * z + m[15];

	return self;
end

function META:Rotate(a, x, y, z, out)
	if a == 0 then return self end
	
	if false and ELIAS then
		out = out or Matrix44()
		local m = out.m
		
		local d = math.sqrt(x*x + y*y + z*z)
		a = a * math.pi / 180;
		
		x = x / d 
		y = y / d
		z = z / d
		
		local c = math.cos(a)
		local s = math.sin(a)
		local t = 1 - c

		m[0] = x * x * t + c;
		m[1] = x * y * t - z * s;
		m[2] = x * z * t + y * s;
		m[3] = 0;

		m[4] = y * x * t + z * s;
		m[5] = y * y * t + c;
		m[6] = y * z * t - x * s;
		m[7] = 0;

		m[8] = z * x * t - y * s;
		m[9] = z * y * t + x * s;
		m[10] = z * z * t + c;
		m[11] = 0;

		m[12] = 0;
		m[13] = 0;
		m[14] = 0;
		m[15] = 1;
		
		self.GetMultiplied(self:Copy(), out, self)
		
		return self
	else

		out = out or Matrix44()
		local m = out.m

		local xx, yy, zz, xy, yz, zx, xs, ys, zs, one_c, s, c;
		local optimized = false

		local s = math.sin(math.rad(a))
		local c = math.cos(math.rad(a))

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
					optimized = true;
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
					m[2*4+1] = -s;
					m[1*4+2] = s;
				end
			end
		end

		if not optimized then
			local mag = math.sqrt(x * x + y * y + z * z)

			if mag <= 1.0e-4 then
				return
			end

			x = x / mag;
			y = y / mag;
			z = z / mag;

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

			m[0*4+0] = (one_c * xx) + c;
			m[1*4+0] = (one_c * xy) - zs;
			m[2*4+0] = (one_c * zx) + ys;

			m[0*4+1] = (one_c * xy) + zs;
			m[1*4+1] = (one_c * yy) + c;
			m[2*4+1] = (one_c * yz) - xs;

			m[0*4+2] = (one_c * zx) - ys;
			m[1*4+2] = (one_c * yz) + xs;
			m[2*4+2] = (one_c * zz) + c;

		end
		
		self.GetMultiplied(out, self:Copy(), self)
		
		return self
	end
end

function META:Scale(x, y, z)
	if x == 1 and y == 1 and z == 1 then return self end
	
	local m = self.m;

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

	return self;
end

do -- projection
	function META:Perspective(fov, near, far, aspect)
		local m = self.m

		local yScale = 1.0 / math.tan((math.pi / 180.0) * fov / 2)
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
		local m = self.m;
			
		local temp = 2.0 * n;
		local temp2 = r - l;
		local temp3 = t - b;
		local temp4 = f - n;
		
		m[0] = temp / temp2;
		m[1] = 0.0;
		m[2] = 0.0;
		m[3] = 0.0;
		m[4] = 0.0;
		m[5] = temp / temp3;
		m[6] = 0.0;
		m[7] = 0.0;
		m[8] = (r + l) / temp2;
		m[9] = (t + b) / temp3;
		m[10] = (-f - n) / temp4;
		m[11] = -1.0;
		m[12] = 0.0;
		m[13] = 0.0;
		m[14] = (-temp * f) / temp4;
		m[15] = 0.0;
		
		return self
	end

	function META:Ortho(left, right, bottom, top, near, far)
		local m = self.m
		
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

do -- helpers
	function META:OpenGLFunc(func, ...)
		func = gl[func]
		local old = ffi.new("GLint[1]")
		gl.GetIntegerv(e.GL_MATRIX_MODE, old)
		gl.MatrixMode(e.GL_MODELVIEW)
		
		gl.PushMatrix()
		gl.LoadIdentity()
		func(...)
		gl.GetFloatv(e.GL_MODELVIEW_MATRIX, self.m)
		gl.PopMatrix()
		
		gl.MatrixMode(old[0])
		
		return self
	end


	function META:LookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz)
		local m = self.m;

		local e = Vec3(ex, ey, ez);
		local c = Vec3(cx, cy, cz);
		local u = Vec3(ux, uy, uz);
		local f = (e - c):GetNormalized()
		local s = u:Cross(f):GetNormalized()
		local t = f:Cross(s):GetNormalized()

		m[0] = s.x;
		m[1] = s.y;
		m[2] = s.z;
		m[3] = -s:GetDot(e);

		m[4] = t.x;
		m[5] = t.y;
		m[6] = t.z;
		m[7] = -t:GetDot(e);

		m[8] = f.x;
		m[9] = f.y;
		m[10] = f.z;
		m[11] = -f:GetDot(e);

		m[12] = 0;
		m[13] = 0;
		m[14] = 0;
		m[15] = 1;

		return self;
	end
end

function META:TransformPoint(v)
	local m = self.m;
	
	return Vec3(
		m[0] * v.x + m[1] * v.y + m[2] * v.z + m[3],
		m[4] * v.x + m[5] * v.y + m[6] * v.z + m[7],
		m[8] * v.x + m[9] * v.y + m[10] * v.z + m[11]
	) / 
	(m[12] * v.x + m[13] * v.y + m[14] * v.z + m[15]);
end

function META:TransformVector(v)
	local m = self.m;
	
	return Vec3(
		m[0] * v.x + m[1] * v.y + m[2] * v.z,
		m[4] * v.x + m[5] * v.y + m[6] * v.z,
		m[8] * v.x + m[9] * v.y + m[10] * v.z
	);
end

local t = ffi.typeof("float[16]")
local new = ffi.new

function Matrix44(m)
	local self = setmetatable({}, META)
	
	if m then
		self.m = m
	else
		self.m = new(t)
		self:Identity()
	end
	
	return self
end
