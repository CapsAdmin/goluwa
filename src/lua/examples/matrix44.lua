local gl = require("libopengl") -- OpenGL

window.Open()

gl.PopMatrix()
local m = Matrix44()
gl.MatrixMode(gl.e.GL_MODELVIEW)
gl.PushMatrix()
gl.LoadIdentity()

local function test(lua_func, gl_func, ...)
	gl.LoadIdentity()
	m:LoadIdentity()
	m[lua_func](m, ...)

	local copy = m:Copy()

	local args = {}
	for k,v in pairs({...}) do
		if typex(v) == "matrix44" then
			v = ffi.cast("double *", v)
		end
		args[k] = v
	end

	gl_func(unpack(args))
	gl.GetDoublev("GL_MODELVIEW_MATRIX", ffi.cast("double *", m))

	local equal = true

	for i = 0, 15 do
		if math.round(copy:GetI(i), 3) ~= math.round(m:GetI(i), 3) then

			logf("%s member %i is not equal\n", lua_func, i)
			logn("lua: ", copy:GetI(i))
			logn("ogl: ", m:GetI(i))

			equal = false
		end
	end

	if equal then
	--	logf("%s results are equal\n", lua_func)

		return true
	end

	logf("%s results are not equal!\n", lua_func)

	logn("\nLua result:")
	logn(copy, "\n")

	logn("\nOpenGL result:")
	logn(m, "\n")

	return false
end

local function random_matrix()
	local m = Matrix44()

	for i = 0, 15 do
		m.ptr[i] = math.randomf(-100,100)
	end

	return m
end

for i = 1, 20 do
	if not test("Translate", gl.Translated, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Multiply", gl.MultMatrixd, random_matrix()) then break end
	if not test("Rotate", gl.Rotated, math.randomf(-360, 360), math.randomf(-1, 1), math.randomf(-1, 1), math.randomf(-1, 1)) then break end
	if not test("Multiply", gl.MultMatrixd, random_matrix()) then break end
	if not test("Scale", gl.Scaled, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Multiply", gl.MultMatrixd, random_matrix()) then break end
end

--test("Ortho", gl.Ortho, 0, 512, 0, 512, -1, 1)
