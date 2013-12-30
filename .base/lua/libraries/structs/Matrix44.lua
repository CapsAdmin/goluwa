-- ported from https://github.com/evanw/lightgl.js/blob/master/src/matrix.js 

-- Represents a 4x4 matrix stored in row-major order that uses Float32Arrays
-- when available. Matrix operations can either be done using convenient
-- methods that return a new matrix for the result or optimized methods
-- that store the result in an existing matrix to avoid generating garbage.

-- ### .transformPoint(point)
-- 
-- Transforms the vector as a point with a w coordinate of 1. This
-- means translations will have an effect, for example.
local function matrix_transform_point(matrix, v)
	local m = matrix.m;
	
	return Vec3(
		m[0] * v.x + m[1] * v.y + m[2] * v.z + m[3],
		m[4] * v.x + m[5] * v.y + m[6] * v.z + m[7],
		m[8] * v.x + m[9] * v.y + m[10] * v.z + m[11]
	) / (m[12] * v.x + m[13] * v.y + m[14] * v.z + m[15]);
end

-- ### .transformPoint(vector)
-- 
-- Transforms the vector as a vector with a w coordinate of 0. This
-- means translations will have no effect, for example.
local function matrix_transform_vector(matrix, v)
	local m = matrix.m;
	
	return Vec3(
		m[0] * v.x + m[1] * v.y + m[2] * v.z,
		m[4] * v.x + m[5] * v.y + m[6] * v.z,
		m[8] * v.x + m[9] * v.y + m[10] * v.z
	);
end

-- ### GL.Matrix.inverse(matrix[, result])
-- 
-- Returns the matrix that when multiplied with `matrix` results in the
-- identity matrix. You can optionally pass an existing matrix in `result`
-- to avoid allocating a new matrix. This implementation is from the Mesa
-- OpenGL function `__gluInvertMatrixd()` found in `project.c`.
local function matrix_inverse(matrix, result)
	result = result or Matrix44();
	local m = matrix.m
	local r = result.m

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
	for i = 0, 15 do r[i] = r[i] / det end
	return result;
end

-- ### GL.Matrix.transpose(matrix[, result])
-- 
-- Returns `matrix`, exchanging columns for rows. You can optionally pass an
-- existing matrix in `result` to avoid allocating a new matrix.
local function matrix_transpose(matrix, result)
	result = result or Matrix44();
	local m = matrix.m
	local r = result.m;
	
	r[0] = m[0]; r[1] = m[4]; r[2] = m[8]; r[3] = m[12];
	r[4] = m[1]; r[5] = m[5]; r[6] = m[9]; r[7] = m[13];
	r[8] = m[2]; r[9] = m[6]; r[10] = m[10]; r[11] = m[14];
	r[12] = m[3]; r[13] = m[7]; r[14] = m[11]; r[15] = m[15];
	return result;
end

-- ### GL.Matrix.multiply(left, right[, result])
-- 
-- Returns the concatenation of the transforms for `left` and `right`. You can
-- optionally pass an existing matrix in `result` to avoid allocating a new
-- matrix. This emulates the OpenGL function `glMultMatrix()`.
local function matrix_multiply(left, right, result)
	result = result or Matrix44();
	local a = left.m
	local b = right.m
	local r = result.m;

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

	return result;
end

-- ### GL.Matrix.identity([result])
-- 
-- Returns an identity matrix. You can optionally pass an existing matrix in
-- `result` to avoid allocating a new matrix. This emulates the OpenGL function
-- `glLoadIdentity()`.
local function matrix_identity(result)
	result = result or Matrix44();
	local m = result.m;
	
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
	
	return result;
end

-- ### GL.Matrix.frustum(left, right, bottom, top, near, far[, result])
-- 
-- Sets up a viewing frustum, which is shaped like a truncated pyramid with the
-- camera where the point of the pyramid would be. You can optionally pass an
-- existing matrix in `result` to avoid allocating a new matrix. This emulates
-- the OpenGL function `glFrustum()`.
local function matrix_frustum(l, r, b, t, n, f, result)
	result = result or Matrix44();
	local m = result.m;
		
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
	
	return result;
end

-- ### GL.Matrix.perspective(fov, aspect, near, far[, result])
-- 
-- Returns a perspective transform matrix, which makes far away objects appear
-- smaller than nearby objects. The `aspect` argument should be the width
-- divided by the height of your viewport and `fov` is the top-to-bottom angle
-- of the field of view in degrees. You can optionally pass an existing matrix
-- in `result` to avoid allocating a new matrix. This emulates the OpenGL
-- function `gluPerspective()`.
local function matrix_perspective(fov, aspect, near, far, result)
	aspect=1280/720
	result = result or Matrix44();
	
    local yScale = 1.0 / math.tan((math.pi / 180.0) * fov / 2)
    local xScale = yScale / aspect
    local nearmfar = near - far
	
	local m = result.m
	
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
	
	return result
end

-- ### GL.Matrix.ortho(left, right, bottom, top, near, far[, result])
-- 
-- Returns an orthographic projection, in which objects are the same size no
-- matter how far away or nearby they are. You can optionally pass an existing
-- matrix in `result` to avoid allocating a new matrix. This emulates the OpenGL
-- function `glOrtho()`.

local function matrix_ortho(left, right, bottom, top, near, far, result)
	result = result or Matrix44()
	
	local m = result.m
	
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
				
	return result
end

-- ### GL.Matrix.scale(x, y, z[, result])
-- 
-- This emulates the OpenGL function `glScale()`. You can optionally pass an
-- existing matrix in `result` to avoid allocating a new matrix. 
local function matrix_scale(x, y, z, result)
	result = result or Matrix44();

	if x == 1 and y == 1 and z == 1 then return result end
	
	local m = result.m;

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

	return result;
end

-- ### GL.Matrix.translate(x, y, z[, result])
-- 
-- This emulates the OpenGL function `glTranslate()`. You can optionally pass
-- an existing matrix in `result` to avoid allocating a new matrix. 
local function matrix_translate(x, y, z, result)
	result = result or Matrix44();
	
	if x == 0 and y == 0 and (z == 0 or not z) then return result end

	local m = result.m;

	m[12] = m[0] * x + m[4] * y + m[8]  * z + m[12];
	m[13] = m[1] * x + m[5] * y + m[9]  * z + m[13];
	m[14] = m[2] * x + m[6] * y + m[10] * z + m[14];
	m[15] = m[3] * x + m[7] * y + m[11] * z + m[15];

	return result;
end

-- ### GL.Matrix.rotate(a, x, y, z[, result])
-- 
-- Returns a matrix that rotates by `a` degrees around the vector `x, y, z`.
-- You can optionally pass an existing matrix in `result` to avoid allocating
-- a new matrix. This emulates the OpenGL function `glRotate()`. 
local function matrix_rotate(a, x, y, z, result)
	if not a or (not x and not y and not z) then
		return matrix_identity(result)
	end
		
	result = result or Matrix44();
	
	if a == 0 then return result end

	local m = result.m

	local xx, yy, zz, xy, yz, zx, xs, ys, zs, one_c, s, c;
	local optimized = false

	local s = math.sin(math.rad(a))
	local c = math.cos(math.rad(a))

	if x == 0 then
		if y == 0 then
			if z ~= 0 then
				optimized = true

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

	return result
end

-- ### GL.Matrix.lookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz[, result])
-- 
-- Returns a matrix that puts the camera at the eye point `ex, ey, ez` looking
-- toward the center point `cx, cy, cz` with an up direction of `ux, uy, uz`.
-- You can optionally pass an existing matrix in `result` to avoid allocating
-- a new matrix. This emulates the OpenGL function `gluLookAt()`.
local function matrix_look_at(ex, ey, ez, cx, cy, cz, ux, uy, uz, result)
	result = result or Matrix44();
	local m = result.m;

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

	return result;
end

local MAT_SX = 0
local MAT_SY = 5
local MAT_SZ = 10
local MAT_TX = 12
local MAT_TY = 13
local MAT_TZ = 14

local function matrix_viewport(x, y, width, height, z_near, z_far, depth_max, result)
	result = result or Matrix44();
	local m = result.m;
	
	m[MAT_SX] = width / 2
	m[MAT_TX] = m[MAT_SX] + x
	m[MAT_SY] = height / 2	
	m[MAT_TY] = m[MAT_SY] + y
	
	if depth_max and z_far and z_near then
		m[MAT_SZ] = depth_max * ((z_far - z_near) / 2)
		m[MAT_TZ] = depth_max * ((z_far - z_near) / 2 + z_near)
	end
	
	return result
end

local META = {}

META.Type = "matrix44"

function META:OpenGLFunc(func, ...)
	func = gl[func] or glu[func]
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

function META:Identity()
	matrix_identity(self)
	
	return self
end

META.LoadIdentity = META.Identity

function META:GetInverse()
	return matrix_inverse(self, Matrix44())
end

function META:GetTranspose()
	return matrix_transpose(self, Matrix44())
end

function META:__mul(b)
	return matrix_multiply(self, b, Matrix44())
end

function META:Multiply(b)
	return matrix_multiply(self, b, Matrix44())
end

function META:TransformPoint(v)
	return matrix_transform_point(self, v)
end

function META:TransformVector(v)
	return matrix_transform_vector(self, v)
end

function META:Perspective(fov, aspect, near, far)
	return matrix_perspective(fov, aspect, near, far, self)
end

function META:Frustum(l, r, b, t, n, f)
	return matrix_frustum(l, r, b, t, n, f, self)
end

function META:Ortho(left, right, bottom, top, near, far)
	return matrix_ortho(left, right, bottom, top, near, far, self)
end

function META:Viewport(x, y, width, height, z_near, z_far, depth_max, result)
	return matrix_viewport(x, y, width, height, z_near, z_far, depth_max, result)
end

function META:LookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz)
	return matrix_look_at(ex, ey, ez, cx, cy, cz, ux, uy, uz, self)
end

function META:__index(key)
	return META[key] or self.m[key]
end

function META:Scale(x, y, z)
	return matrix_scale(x, y, z, self)
end

function META:Translate(x, y, z)
	return matrix_translate(x, y, z, self)
end

function META:Rotate(a, x, y, z)
	if not z then
				matrix_rotate(a, 1, 0, 0, self)
				matrix_rotate(x, 0, 1, 0, self)
		return 	matrix_rotate(y, 0, 0, 1, self)
	end	
	return matrix_rotate(a, x, y, z, self)
end

function META:__tostring()
	return string.format("matrix44[%p]:\n" .. ("%f %f %f %f\n"):rep(4), self.m,
		self[0], self[4], self[8], self[12],
		self[1], self[5], self[9], self[13],
		self[2], self[6], self[10], self[14],
		self[3], self[7], self[11], self[15])
end

function Matrix44(m)
	local self = setmetatable({}, META)
	
	if m then
		self.m = m
	else
		self.m = ffi.new("float[16]")
		matrix_identity(self)	
	end
	
	return self
end